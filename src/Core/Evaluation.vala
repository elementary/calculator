/* Copyright 2014 Marvin Beckers <beckersmarvin@gmail.com>
*
* This file is part of Pantheon Calculator
*
* Pantheon Calculator is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Pantheon Calculator is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Pantheon Calculator. If not, see http://www.gnu.org/licenses/.
*/

using GLib.Math;

namespace PantheonCalculator.Core {
    private errordomain EVAL_ERROR {
        NO_FUNCTION,
        NO_OPERATOR,
        NO_CONSTANT
    }
    private errordomain SHUNTING_ERROR {
        DUMMY,
        NO_OPERATOR,
        NO_FUNCTION,
        NO_CONSTANT,
        MISMATCHED_P,
        UNKNOWN_TOKEN,
        STACK_EMPTY
    }
    public errordomain OUT_ERROR {
        EVAL_ERROR,
        CHECK_ERROR,
        SHUNTING_ERROR,
        SCANNER_ERROR
    }
    public class Evaluation : Object {

        [CCode (has_target = false)]
        private delegate double Eval (double a = 0, double b = 0);

        private struct Operator { string symbol; int inputs; int prec; string fixity; Eval eval;}
        private Operator[] operators = {   Operator () { symbol = "+", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => { return a + b; } },
                                            Operator () { symbol = "-", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => { return a - b; } },
                                            Operator () { symbol = "−", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => { return a - b; } },
                                            Operator () { symbol = "*", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => { return a * b; } }, 
                                            Operator () { symbol = "×", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => { return a * b; } },
                                            Operator () { symbol = "/", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => { return a / b; } },
                                            Operator () { symbol = "÷", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => { return a / b; } },
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
                                            Function () { symbol = "sqrt", inputs = 1, eval = (a) => { return Math.sqrt (a); } },
                                            Function () { symbol = "√", inputs = 1, eval = (a) => { return Math.sqrt (a); } } };

        private struct Constant { string symbol; Eval eval; }
        private Constant[] constants = {   Constant () { symbol = "pi", eval = () => { return Math.PI; } },
                                            Constant () { symbol = "π", eval = () => { return Math.PI; } }  };

        public static string evaluate (string str, int d_places) throws OUT_ERROR {
            try {
                var tokenlist = Scanner.scan (str);
                var d = 0.0;
                var e = new Evaluation ();

                try {
                    tokenlist = e.shunting_yard (tokenlist);
                    try {
                        d = e.eval_postfix (tokenlist);
                    } catch (Error e) { throw new OUT_ERROR.EVAL_ERROR (e.message); }
                } catch (Error e) { throw new OUT_ERROR.SHUNTING_ERROR (e.message); }
                return e.cut (d, d_places);
            } catch (Error e) { throw new OUT_ERROR.SCANNER_ERROR (e.message); }
        }

        //Djikstra's Shunting Yard algorithm for ordering a tokenized list into Reverse Polish Notation
        private List<Token> shunting_yard (List<Token> token_list) throws SHUNTING_ERROR {
            List<Token> output = new List<Token> ();
            Stack<Token> opStack = new Stack<Token> ();

            foreach (Token t in token_list) {
                //debug (t.content);
                switch (t.token_type) {
                case TokenType.NUMBER:
                    output.append (t);
                    break;
                case TokenType.CONSTANT:
                    output.append (t);
                    break;
                case TokenType.FUNCTION:
                    opStack.push (t);
                    break;

                case TokenType.SEPARATOR:
                    while (opStack.peek ().token_type != TokenType.P_LEFT && !opStack.empty ()) {
                        output.append (opStack.pop ());
                    }

                    if (opStack.peek ().token_type != TokenType.P_LEFT)
                        throw new SHUNTING_ERROR.MISMATCHED_P ("Content of parentheses is mismatched.");
                    break;

                case TokenType.OPERATOR:
                    if (!opStack.empty ()) {
                        Operator op1 = get_operator (t);
                        Operator op2 = Operator ();

                        try {
                            op2 = get_operator (opStack.peek ());
                        } catch (SHUNTING_ERROR e) { }

                        while (!opStack.empty () && opStack.peek ().token_type == TokenType.OPERATOR &&
                        ((op2.fixity == "LEFT" && op1.prec <= op2.prec) ||
                        (op2.fixity == "RIGHT" && op1.prec < op2.prec))) {
                            output.append (opStack.pop ());

                            if (!opStack.empty ()) {
                                try {
                                    op2 = get_operator (opStack.peek ());
                                } catch (SHUNTING_ERROR e) { }
                            }
                        }
                    }
                    opStack.push (t);
                    break;

                case TokenType.P_LEFT:
                    opStack.push (t);
                    break;

                case TokenType.P_RIGHT:
                    do {
                        if (!opStack.empty () && !(opStack.peek ().token_type == TokenType.P_LEFT))
                            output.append (opStack.pop ());
                        else
                            break;
                    } while (!opStack.empty ());

                    if (!(opStack.empty ()) && opStack.peek ().token_type == TokenType.P_LEFT)
                        opStack.pop ();

                    if (!opStack.empty () && opStack.peek ().token_type == TokenType.FUNCTION)
                        output.append (opStack.pop ());

                    break;
                default:
                        throw new SHUNTING_ERROR.UNKNOWN_TOKEN ("'%s' is unknown.", t.content);
                }
            }

            while (!opStack.empty ()) {
                if (opStack.peek ().token_type == TokenType.P_LEFT || opStack.peek ().token_type == TokenType.P_RIGHT)
                    throw new SHUNTING_ERROR.MISMATCHED_P ("Mismatched parenthesis.");
                else
                    output.append (opStack.pop ());
            }

            return output;
        }

        private double eval_postfix (List<Token> token_list) throws EVAL_ERROR {
            Stack<Token> stack = new Stack<Token> ();

            foreach (Token t in token_list) {
                if (t.token_type == TokenType.NUMBER) {
                    stack.push (t);
                } else if (t.token_type == TokenType.CONSTANT) {
                    try {
                        Constant c = get_constant (t);
                        stack.push (new Token (c.eval ().to_string (), TokenType.NUMBER));
                    } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_CONSTANT (""); }
                } else if (t.token_type == TokenType.OPERATOR) {
                    try {
                        Operator o = get_operator (t);
                        Token t1 = stack.pop ();
                        Token t2 = new Token ("0", TokenType.NUMBER);

                        if (!stack.is_length (0) && o.inputs == 2)
                            t2 = stack.pop ();
                        stack.push (compute_tokens (t, t1, t2));
                    } catch (SHUNTING_ERROR e) { throw new EVAL_ERROR.NO_OPERATOR (""); }
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
        public bool is_operator (Token t) {
            foreach (Operator o in operators) {
                if (t.content == o.symbol)
                    return true;
            }
            return false;
        }

        public bool is_function (Token t) {
            foreach (Function f in functions) {
                if (t.content == f.symbol)
                    return true;
            }
            return false;
        }

        public bool is_constant (Token t) {
            foreach (Constant c in constants) {
                if (t.content == c.symbol)
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

        private Constant get_constant (Token t) throws SHUNTING_ERROR {
            foreach (Constant c in constants) {
                if (t.content == c.symbol)
                    return c;
            }
            throw new SHUNTING_ERROR.NO_CONSTANT ("");
        }

        private Token compute_tokens (Token t_op, Token t1, Token t2) throws EVAL_ERROR {
            try { 
                Operator op = get_operator (t_op);
                var d = (double)(op.eval (double.parse (t2.content), double.parse (t1.content)));
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

        private string cut (double d, int d_places) {
            var s = ("%.5f".printf (d)).replace (",", ".");
            while (s.last_index_of ("0") == s.length - 1)
                s = s.slice (0, s.length - 1);
            if (s.last_index_of (".") == s.length - 1)
                s = s.slice (0, s.length - 1);
            return s;
        }
    }
}
