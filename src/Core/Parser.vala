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

namespace Calculus.Core {
    public errordomain TOKENIZE_ERROR {
        UNKNOWN_SYMBOL,
        NUMBER_INVALID,
        FUNC_INVALID,
        OPERATOR_INVALID
    }
    public errordomain SHUNTING_ERROR {
        DUMMY,
        NO_OPERATOR,
        NO_FUNCTION
    }
    public errordomain EVAL_ERROR {
        DUMMY,
        NO_OPERATOR,
        NO_FUNCTION
    }
    
    public errordomain PARSER_ERROR {
        TOKENIZE,
        SHUNTING,
        EVAL
    }
    
    public class Parser : Object {
        public Parser () { }
    
        [CCode (has_target = false)]
        private delegate double Evaluation (double a, double b = 0);
        
        private struct Operator { string symbol; int prec; string fixity; Evaluation eval;}
        private Operator[] operators = {   Operator () { symbol = "+", prec = 1, fixity = "LEFT", eval = (a, b) => { return a + b; } },
                                            Operator () { symbol = "-", prec = 1, fixity = "LEFT", eval = (a, b) => { return a - b; } },
                                            Operator () { symbol = "*", prec = 2, fixity = "LEFT", eval = (a, b) => { return a * b; } }, 
                                            Operator () { symbol = "/", prec = 2, fixity = "LEFT", eval = (a, b) => { return a / b; } },
                                            Operator () { symbol = "^", prec = 3, fixity = "RIGHT", eval = (a, b) => { return Math.pow (a, b); } },
                                            Operator () { symbol = "mod", prec = 3, fixity = "LEFT", eval = (a, b) => { return 0; } }  };
                                            
        private struct Function { string symbol; int inputs; Evaluation eval; }
        private Function[] functions = {   Function () { symbol = "sin", inputs = 1, eval = (a) => { return Math.sin (a); } },
                                            Function () { symbol = "cos", inputs = 1, eval = (a) => { return Math.cos (a); } },
                                            Function () { symbol = "tan", inputs = 1, eval = (a) => { return Math.tan (a); } },
                                            Function () { symbol = "sinh", inputs = 1, eval = (a) => { return Math.sinh (a); } },
                                            Function () { symbol = "cosh", inputs = 1, eval = (a) => { return Math.cosh (a); } },
                                            Function () { symbol = "tanh", inputs = 1, eval = (a) => { return Math.tanh (a); } } }; 
                                        
        public static double parse (string exp) throws PARSER_ERROR {
            Parser parser = new Parser ();
            List<Token> tokenized_list = new List<Token> ();
            try { tokenized_list = parser.tokenize_string (exp); 
            } catch (TOKENIZE_ERROR e) { throw new PARSER_ERROR.TOKENIZE (e.message); }
            
            List<Token> sorted_token_list = new List<Token> ();
            try { sorted_token_list = parser.shunting_yard (tokenized_list);
            } catch (SHUNTING_ERROR e) { throw new PARSER_ERROR.SHUNTING (e.message); }
            
            double d = 0;
            try { d = parser.eval_postfix (sorted_token_list); 
            } catch (EVAL_ERROR e) { throw new PARSER_ERROR.EVAL (e.message); }
            
            return d;
        }
        
        // slice input string into logical tokens to work with after.
        public List<Token> tokenize_string (string exp) throws TOKENIZE_ERROR {
            List<Token> token_list = new List<Token> ();
            string numbers = "";
            string chars = "";
            string temp = exp.replace (" ","");
            string symbol = "";
            bool is_negative = false;
            
            while (temp != "") {
                
                symbol = temp.slice (0, 1);
                temp = temp.slice (1, temp.length);
                
                if (is_digit (symbol) || symbol == ".") {
                    if (chars != "" && is_function (chars)) {
                        try { token_list.append (create_func_token (chars));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                    }
                    numbers = numbers + symbol.to_string ();
                } else if (is_alpha (symbol)) {
                    chars = chars + symbol.to_string ();
                } else if (is_operator (symbol) || is_operator (chars)) {
                    if (numbers != "") {
                        try { token_list.append (create_number_token (numbers, is_negative));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                        
                        numbers = "";
                        if (is_operator (chars))
                            chars = "";
                        is_negative = false;
                        
                        try { token_list.append (create_operator_token (symbol));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                    } else if (numbers == "" && symbol == "-") {
                        is_negative = true;
                        continue;
                    }
                } else if (symbol == "(") {
                    if (numbers != "") {
                        try { token_list.append (create_number_token (numbers));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                        
                        numbers = "";
                        token_list.append (new Token ("*", TokenType.OPERATOR));
                    } else if (chars != "" && is_function (chars)) {
                        try { token_list.append (create_func_token (chars)); 
                        } catch (TOKENIZE_ERROR e) { throw e; }
                        chars = "";
                    } else if (chars != "" && is_operator (chars)) {
                        try { token_list.append (create_operator_token (chars));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                    }   
                    
                    token_list.append (new Token (symbol.to_string (), TokenType.PARENTHESIS_LEFT));
                } else if (symbol == ")") {
                    if (numbers != "") {
                        try { token_list.append (create_number_token (numbers)); 
                        } catch (TOKENIZE_ERROR e) { throw e; }
                        numbers = "";
                    }
                    
                    token_list.append (new Token (symbol.to_string (), TokenType.PARENTHESIS_RIGHT));
                } else 
                    throw new TOKENIZE_ERROR.UNKNOWN_SYMBOL ("Encountered unknown symbol '" + symbol+ "'.");
            }
            
            if (numbers != "") {
                try { token_list.append (create_number_token (numbers, is_negative));
                } catch (TOKENIZE_ERROR e) { throw e; }
            }
            
            return token_list;
        }
        
        //Djikstra's Shunting Yard algorithm for reordering a tokenized list into Reverse Polish Notation
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
                    while (opStack.peek ().token_type != TokenType.PARENTHESIS_LEFT && opStack.is_length (0) == false) 
                        output.append (opStack.pop ());
                    
                    if (opStack.peek ().token_type != TokenType.PARENTHESIS_LEFT)
                        throw new SHUNTING_ERROR.DUMMY ("Either the seperatotor was misplaced or parentheses were mismatched.");
                    break;
                 
                case TokenType.OPERATOR:
                    if (!opStack.empty ()) {
                        Operator op1 = get_operator (t.content);
                        Operator op2 = Operator ();
                        try { op2 = get_operator (opStack.peek ().content);
                        } catch (SHUNTING_ERROR e) { }

                        while (!opStack.empty () &&              
                        ((op2.fixity == "LEFT" && op1.prec <= op2.prec) ||   
                        (op2.fixity == "RIGHT" && op1.prec < op2.prec)))
                        {   
                            output.append (opStack.pop ());
                            if (!opStack.empty ())
                                try { op2 = get_operator (opStack.peek ().content);
                                } catch (SHUNTING_ERROR e) { }
                        }
                    }  
                    opStack.push (t);
                    break;
                
                case TokenType.PARENTHESIS_LEFT:
                    opStack.push (t);
                    break;
                        
                case TokenType.PARENTHESIS_RIGHT:
                    while (!(opStack.peek ().token_type == TokenType.PARENTHESIS_LEFT) && !opStack.empty ())
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
            return output;
        }
        
        public double eval_postfix (List<Token> token_list) throws EVAL_ERROR {
            Stack<Token> stack = new Stack<Token> ();
        
            foreach (Token t in token_list) {
                if (t.token_type == TokenType.NUMBER) {
                    stack.push (t);
                } else if (t.token_type == TokenType.OPERATOR) {
                    Token right = stack.pop ();
                    Token left = stack.pop ();
                    stack.push (compute_tokens (left, t, right));
                } else if (t.token_type == TokenType.FUNCTION) {
                    try {
                        Function f = get_function (t.content);
                        Token t1 = stack.pop ();
                        Token t2 = new Token ("0", TokenType.NUMBER);
                        
                        if (f.inputs == 2)
                            t2 = stack.pop ();
                      
                        stack.push (process_tokens (t, t1, t2));
                    } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_FUNCTION (""); }
                }                
            }
        
            double out_d = double.parse (stack.pop ().content);
            return out_d;
        }
        
        private bool is_operator (string s) {
            foreach (Operator o in operators) {
                if (s == o.symbol) 
                    return true;
            }
            return false;
        }
        private Operator get_operator (string s) throws SHUNTING_ERROR {
            foreach (Operator o in operators) {
                if (o.symbol == s)
                    return o;
            }
            throw new SHUNTING_ERROR.NO_OPERATOR ("");
        }
        
        private Function get_function (string s) throws SHUNTING_ERROR {
            foreach (Function f in functions) {
                if (f.symbol == s)
                    return f;
            }
            throw new SHUNTING_ERROR.NO_FUNCTION ("");
        }
        
        private bool is_function (string s) {
            foreach (Function f in functions) {
                if (f.symbol == s) 
                    return true;
            }
            return false;
        }
        
        private bool is_number (string s) {
            if (/^\d*\.?\d*$/.match (s)) 
                return true;
            return false;
        }
        
        private bool is_digit (string s) {
            if (/^\d$/.match (s))
                return true;
            return false;
        }
        
        public static bool is_alpha (string s) {
            if (/^\w$/.match (s)) {
                return true;
                //stdout.printf ("match %s.", s);
                }
            return false;
        }
        
        private Token create_number_token (string token_string, bool is_negative = false) throws TOKENIZE_ERROR {
            if (is_number (token_string)) {
                var token_string_output = token_string;
                if (is_negative)
                    token_string_output = ((-1) * double.parse (token_string)).to_string ();
                
                return new Token (token_string_output, TokenType.NUMBER);
            } else
                throw new TOKENIZE_ERROR.NUMBER_INVALID ("'%s' is no valid number.", token_string);
        }
        
        private Token create_func_token (string token_string) throws TOKENIZE_ERROR {
            if (is_function (token_string)) 
                return new Token (token_string, TokenType.FUNCTION);
            else
                throw new TOKENIZE_ERROR.FUNC_INVALID ("'%s' is no valid function.", token_string);
        }
        
        private Token create_operator_token (string token_string) throws TOKENIZE_ERROR {
            if (is_operator (token_string))
                return new Token (token_string, TokenType.OPERATOR);
            else
                throw new TOKENIZE_ERROR.OPERATOR_INVALID ("'%s' is no valid operator", token_string);
        }
        
        private Token compute_tokens (Token t1, Token t_op, Token t2) throws EVAL_ERROR {
            try { 
                Operator op = get_operator (t_op.content);
                var d = op.eval (double.parse (t1.content), double.parse (t2.content));
                return new Token (d.to_string (), TokenType.NUMBER);
            } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_OPERATOR ("The given token was no operator."); }
        }
        
        private Token process_tokens (Token tf, Token t1, Token t2) throws EVAL_ERROR {
            try {
                var f = get_function (tf.content);
                var d = 0.0;
                if (f.inputs == 1)
                    d = f.eval (double.parse (t1.content));
                else
                    d = f.eval (double.parse (t1.content), double.parse (t2.content));
                return new Token (d.to_string (), TokenType.NUMBER);
            } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_FUNCTION ("The given token was no function."); }
        
        }
    }
}
