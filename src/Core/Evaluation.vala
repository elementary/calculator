/* Copyright 2014 Marvin Beckers <beckersmarvin@gmail.com>
*
* This file is part of Calculus.
*
* Calculus is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Calculus is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Calculus. If not, see http://www.gnu.org/licenses/.
*/

using GLib.Math;

namespace Calculus.Core {
    public errordomain EVAL_ERROR {
        NO_FUNCTION,
        NO_OPERATOR
    }
    public errordomain CHECK_ERROR {
        ALPHA_INVALID
    }
    public errordomain SHUNTING_ERROR {
        DUMMY,
        NO_OPERATOR,
        NO_FUNCTION
    }
    public class Evaluation : Object {
    
        [CCode (has_target = false)]
        private delegate double Eval (double a, double b = 0);
        
        private struct Operator { string symbol; int inputs; int prec; string fixity; Eval eval;}
        private Operator[] operators = {   Operator () { symbol = "+", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => { return a + b; } },
                                            Operator () { symbol = "-", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => { return a - b; } },
                                            Operator () { symbol = "*", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => { return a * b; } }, 
                                            Operator () { symbol = "/", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => { return a / b; } },
                                            Operator () { symbol = "mod", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => { return a % b; } },
                                            Operator () { symbol = "^", inputs = 2, prec = 3, fixity = "RIGHT", eval = (a, b) => { return Math.pow (a, b); } },
                                            Operator () { symbol = "e", inputs = 2, prec = 4, fixity = "RIGHT", eval = (a, b) => { return a*Math.pow (10, b); } },
                                            Operator () { symbol = "%", inputs = 1, prec = 5, fixity = "LEFT", eval = (a, b) => { return b / 100.0;} } };
                                            
        private struct Function { string symbol; int inputs; Eval eval;}
        private Function[] functions = {  Function () { symbol = "sin", inputs = 1, eval = (a) => { return Math.sin (a); } },
                                            Function () { symbol = "cos", inputs = 1, eval = (a) => { return Math.cos (a); } },
                                            Function () { symbol = "tan", inputs = 1, eval = (a) => { return Math.tan (a); } },
                                            Function () { symbol = "sinh", inputs = 1, eval = (a) => { return Math.sinh (a); } },
                                            Function () { symbol = "cosh", inputs = 1, eval = (a) => { return Math.cosh (a); } },
                                            Function () { symbol = "tanh", inputs = 1, eval = (a) => { return Math.tanh (a); } },
                                            Function () { symbol = "log", inputs = 1, eval = (a) => { return Math.log (a); } },
                                            Function () { symbol = "exp", inputs = 1, eval = (a) => { return Math.exp (a); } },
                                            Function () { symbol = "sqrt", inputs = 1, eval = (a) => { return Math.sqrt (a); } } }; 
        
        public static string evaluate (string str, int round) {
            List<Token> tokenlist = Scanner.scan (str);
            var d = 0.0;
            Evaluation e = new Evaluation ();
            
            try {
                tokenlist = e.check_tokens (tokenlist);
                try {
                    tokenlist = e.shunting_yard (tokenlist);
                    try {
                        d = e.eval_postfix (tokenlist);
                    } catch (EVAL_ERROR e) { }
                } catch (SHUNTING_ERROR e) { }
            } catch (CHECK_ERROR e) { }
           
            return d.to_string ();
        }
        
        //doing some fixes and working on special cases after the Scanner did his basic work
        private List<Token> check_tokens (List<Token> input_tokenlist) throws CHECK_ERROR {
            var tokenlist = new List<Token> ();
            var next_number_negative = false;
            
            foreach (Token t in input_tokenlist) {
                if (t.content == "-" && t.token_type == TokenType.OPERATOR) {
                
                    //determines whether the next number is negative ('-' as a sign in front)
                    unowned List<Token>? element = tokenlist.last ();
                    if (element == null || (element != null && element.data.token_type != TokenType.NUMBER)) 
                        next_number_negative = true;
                    else
                        tokenlist.append (t);
                } else if (t.token_type == TokenType.ALPHA) {
                    if (is_operator (t))
                        tokenlist.append (new Token (t.content, TokenType.OPERATOR));
                    else if (is_function (t))
                        tokenlist.append (new Token (t.content, TokenType.FUNCTION));
                    else
                        throw new CHECK_ERROR.ALPHA_INVALID ("Token '%s' is no valid function or operator", t.content);
                } else if (t.token_type == TokenType.NUMBER && next_number_negative) {
                    var d = double.parse (t.content) * (-1);
                    tokenlist.append (new Token (d.to_string (), t.token_type));
                    next_number_negative = false;
                } else 
                    tokenlist.append (t);
            }
            
            /*foreach (Token t in tokenlist)
                stdout.printf ("%s - %s \n", t.content, t.token_type.to_string ());*/
            return tokenlist;
        }
        
        //Djikstra's Shunting Yard algorithm for ordering a tokenized list into Reverse Polish Notation
        public List<Token> shunting_yard (List<Token> token_list) throws SHUNTING_ERROR {
            List<Token> output = new List<Token> ();
            Stack<Token> opStack = new Stack<Token> ();
        
            foreach (Token t in token_list) {
                switch (t.token_type) {
                case TokenType.NUMBER:
                    output.append (t);
                    break;

               case TokenType.FUNCTION:
                    opStack.push (t);
                    break;

                case TokenType.SEPARATOR:
                    while (opStack.peek ().token_type != TokenType.P_LEFT && opStack.is_length (0) == false) 
                        output.append (opStack.pop ());
                    
                    if (opStack.peek ().token_type != TokenType.PARENTHESIS_LEFT)
                        throw new SHUNTING_ERROR.DUMMY ("Either the seperator was misplaced or parentheses were mismatched.");
                    break;
                 
                case TokenType.OPERATOR:
                    if (!opStack.empty ()) {
                        Operator op1 = get_operator (t);
                        Operator op2 = Operator ();
                        try { op2 = get_operator (opStack.peek ());
                        } catch (SHUNTING_ERROR e) { }

                        while (!opStack.empty () &&              
                        ((op2.fixity == "LEFT" && op1.prec <= op2.prec) ||   
                        (op2.fixity == "RIGHT" && op1.prec < op2.prec)))
                        {   
                            output.append (opStack.pop ());
                            if (!opStack.empty ())
                                try { op2 = get_operator (opStack.peek ());
                                } catch (SHUNTING_ERROR e) { }
                        }
                    }  
                    opStack.push (t);
                    break;
                
                case TokenType.P_LEFT:
                    opStack.push (t);
                    break;
                        
                case TokenType.P_RIGHT:
                    while (!(opStack.peek ().token_type == TokenType.P_LEFT) && !opStack.empty ())
                        output.append (opStack.pop ());
                        
                    if (!(opStack.empty ())) 
                        opStack.pop ();
                        
                    if (!opStack.empty () && opStack.peek ().token_type == TokenType.FUNCTION) 
                        output.append (opStack.pop ());
                    break;
                default:
                    /* TODO Throw error (you should never get here, but better throw one) */
                    break;
                }
            }
            while (!opStack.empty ()) {
                if (opStack.peek ().token_type == TokenType.PARENTHESIS_LEFT) {
                    /* TODO Throw mismatched error! */
                    break;
                } else {
                    output.append (opStack.pop ());
                }
            }
            
            foreach (Token t in output)
                stdout.printf ("%s - %s \n", t.content, t.token_type.to_string ());
            return output;
        }
        
        private double eval_postfix (List<Token> token_list) throws EVAL_ERROR {
            Stack<Token> stack = new Stack<Token> ();
            
            foreach (Token t in token_list) {
                if (t.token_type == TokenType.NUMBER) {
                    stack.push (t);
                } else if (t.token_type == TokenType.OPERATOR) {
                    try {
                        Operator o = get_operator (t);
                        Token t1 = stack.pop ();
                        Token t2 = new Token ("0", TokenType.NUMBER);
                        if (!stack.is_length (0) && o.inputs == 2)
                            t2 = stack.pop ();
                        stack.push (compute_tokens (t, t1, t2));
                    } catch (SHUNTING_ERROR e) { }
                } else if (t.token_type == TokenType.FUNCTION) {
                    try {
                        Function f = get_function (t);
                        Token t1 = stack.pop ();
                        Token t2 = new Token ("0", TokenType.NUMBER);
                        
                        if (f.inputs == 2)
                            t2 = stack.pop ();
                      
                        stack.push (process_tokens (t, t1, t2));
                    } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_FUNCTION (""); }
                }                
            }
        
            return double.parse (stack.pop ().content);
        }
        
        //checks for real TokenType (which are TokenType.ALPHA at the moment)
        private bool is_operator (Token t) {
            foreach (Operator o in operators) {
                if (t.content == o.symbol) 
                    return true;
            }
            return false;
        }
        
        private bool is_function (Token t) {
            foreach (Function f in functions) {
                if (t.content == f.symbol) 
                    return true;
            }
            return false;
        }
        
        private Operator get_operator (Token t) throws SHUNTING_ERROR {
            foreach (Operator o in operators) {
                if (t.content == o.symbol)
                    return o;
            }
            throw new SHUNTING_ERROR.NO_OPERATOR ("");
        }
        
        private Function get_function (Token t) throws SHUNTING_ERROR {
            foreach (Function f in functions) {
                if (t.content == f.symbol)
                    return f;
            }
            throw new SHUNTING_ERROR.NO_FUNCTION ("");
        }
        
        private Token compute_tokens (Token t_op, Token t1, Token t2) throws EVAL_ERROR {
            try { 
                Operator op = get_operator (t_op);
                //stdout.printf ("Testing parsing. '%s' - '%s' \n", (double.parse (t2.content)).to_string (), (double.parse (t1.content)).to_string ());
                var d = (double)(op.eval (double.parse (t2.content), double.parse (t1.content)));
                stdout.printf ("Computed Tokens '%s' '%s' '%s' to '%s'. \n", t2.content, t_op.content, t1.content, d.to_string ());
                return new Token (d.to_string (), TokenType.NUMBER);
            } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_OPERATOR ("The given token was no operator."); }
        }
        
        private Token process_tokens (Token tf, Token t1, Token t2) throws EVAL_ERROR {
            try {
                var f = get_function (tf);
                var d = (double)(f.eval (double.parse (t1.content), double.parse (t2.content)));
                return new Token (d.to_string (), TokenType.NUMBER);
            } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_FUNCTION ("The given token was no function."); }
        
        }
    }
}
