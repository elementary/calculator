/* Copyright 2014 Marvin Beckers <ma-be@posteo.de>
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
        FUNC_INVALID
    }
    public errordomain SHUNTING_ERROR {
        DUMMY,
        NO_OPERATOR
    }
    public errordomain EVAL_ERROR {
        DUMMY,
        NO_OPERATOR
    }
    
    public errordomain PARSER_ERROR {
        TOKENIZE,
        SHUNTING,
        EVAL
    }
    
    public class Parser : Object {
        public Parser () { }
    
        private delegate double Evaluation (double a, double b = 0);
        
        private struct Operator { string symbol; int prec; string fixity; Evaluation eval;}
        private Operator[] operators = {   Operator () { symbol = "+", prec = 1, fixity = "LEFT", eval = (a, b) => { return a + b; } },
                                            Operator () { symbol = "-", prec = 1, fixity = "LEFT", eval = (a, b) => { return a - b; } },
                                            Operator () { symbol = "*", prec = 2, fixity = "LEFT", eval = (a, b) => { return a * b; } }, 
                                            Operator () { symbol = "/", prec = 2, fixity = "LEFT", eval = (a, b) => { return a / b; } },
                                            Operator () { symbol = "^", prec = 3, fixity = "RIGHT", eval = (a, b) => { return Math.pow (a, b); } }  };
                                            
        private struct Function { string symbol; Evaluation eval; }
        private Function[] functions = {   Function () { symbol = "sin", eval = (a) => { return Math.sin (a); } },
                                            Function () { symbol = "cos", eval = (a) => { return Math.cos (a); } }  }; 
                                        
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
            string func = "";
            string temp = exp.replace (" ","");
            string symbol = "";
            
            while (temp != "") {
                symbol = temp.slice (0, 1);
                temp = temp.slice (1, temp.length);
                
                if (is_digit (symbol) || symbol == ".") {
                    numbers = numbers + symbol.to_string ();
                    
                /*} else if (symbol.isalpha ()) {
                    func = func + symbol.to_string ();*/
                    
                } else if (is_operator (symbol)) {
                    if (numbers != "") {
                        try { token_list.append (create_number_token (numbers));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                        numbers = "";
                    } else if (numbers == "" && symbol == "-") {
                        try { token_list.append (create_number_token ("0"));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                    }
                    
                    token_list.append (new Token (symbol.to_string (), TokenType.OPERATOR));
                } else if (symbol == "(") {
                    if (numbers != "") {
                        try { token_list.append (create_number_token (numbers));
                        } catch (TOKENIZE_ERROR e) { throw e; }
                        numbers = "";
                        
                        token_list.append (new Token ("*", TokenType.OPERATOR));
                    } else if (func != "") {
                        try { token_list.append (create_func_token (func)); 
                        } catch (TOKENIZE_ERROR e) { throw e; }
                        func = "";
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
                    throw new TOKENIZE_ERROR.UNKNOWN_SYMBOL ("Encountered unknown symbol '" + symbol+ "'");
            }
            
            if (numbers != "") {
                try { token_list.append (create_number_token (numbers));
                } catch (TOKENIZE_ERROR e) { throw e; }
            }
            
            return token_list;
        }
        
        public List<Token> shunting_yard (List<Token> token_list) {
            List<Token> output = new List<Token> ();
            Stack<Token> opStack = new Stack<Token> ();
        
            foreach (Token t in token_list) {
                switch (t.get_token_type ()) {
                case TokenType.NUMBER:
                    output.append (t);
                    break;

               case TokenType.FUNCTION:
                    opStack.push (t);
                    break;

                case TokenType.SEPARATOR:
                    while (opStack.peek ().get_token_type () != TokenType.PARENTHESIS_LEFT && opStack.is_length (0) == false) 
                        output.append (opStack.pop ());
                    
                    if (opStack.peek ().get_token_type () != TokenType.PARENTHESIS_LEFT)
                        throw new SHUNTING_ERROR.DUMMY ("Either the seperatotor was misplaced or parentheses were mismatched.");
                    break;
                 
                case TokenType.OPERATOR:
                    if (!opStack.empty ()) {
                        Operator op1 = get_operator (t.get_content ());
                        Operator op2 = Operator ();
                        try { op2 = get_operator (opStack.peek ().get_content ());
                        } catch (SHUNTING_ERROR e) { }

                        while (!opStack.empty () &&              
                        ((op2.fixity == "LEFT" && op1.prec <= op2.prec) ||   
                        (op2.fixity == "RIGHT" && op1.prec < op2.prec)))
                        {   
                            output.append (opStack.pop ());
                            if (!opStack.empty ())
                                try { op2 = get_operator (opStack.peek ().get_content ());
                                } catch (SHUNTING_ERROR e) { }
                        }
                    }  
                    opStack.push (t);
                    break;
                
                case TokenType.PARENTHESIS_LEFT:
                    opStack.push (t);
                    break;
                        
                case TokenType.PARENTHESIS_RIGHT:
                    while (!(opStack.peek ().get_token_type () == TokenType.PARENTHESIS_LEFT) && !opStack.empty ())
                        output.append (opStack.pop ());
                        
                    if (!(opStack.empty ())) 
                        opStack.pop ();
                        
                    if (!opStack.empty () && opStack.peek ().get_token_type () == TokenType.FUNCTION) 
                        output.append (opStack.pop ());
                    break;
                default:
                    /* TODO Throw error (you should never get here, but better throw one) */
                    break;
                }
            }
            while (!opStack.empty ()) {
                if (opStack.peek ().get_token_type () == TokenType.PARENTHESIS_LEFT) {
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
                if (t.get_token_type () == TokenType.NUMBER) {
                    stack.push (t);
                } else if (t.get_token_type () == TokenType.OPERATOR) {
                    Token right = stack.pop ();
                    Token left = stack.pop ();
                    stack.push (compute_tokens (left, t, right));
                } else if (t.get_token_type () == TokenType.FUNCTION) {
                    
                }                
            }
        
            double out_d = double.parse (stack.pop ().get_content ());
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
        
        private Token create_number_token (string token_string) throws TOKENIZE_ERROR {
            if (is_number (token_string))
                return new Token (token_string, TokenType.NUMBER);
            else
                throw new TOKENIZE_ERROR.NUMBER_INVALID ("The number string is not valid.");
        }
        
        private Token create_func_token (string token_string) throws TOKENIZE_ERROR {
            if (is_function (token_string)) 
                return new Token (token_string, TokenType.FUNCTION);
            else
                throw new TOKENIZE_ERROR.FUNC_INVALID ("The function is not valid or not known.");
        }
        
        private Token compute_tokens (Token t1, Token t_op, Token t2) throws EVAL_ERROR {
            try { 
                Operator op = get_operator (t_op.get_content ());
                double d = op.eval (double.parse (t1.get_content ()), double.parse (t2.get_content ()));
                return new Token (d.to_string (), TokenType.NUMBER);
            } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_OPERATOR ("The given token was no operator."); }
        }
    }
}
