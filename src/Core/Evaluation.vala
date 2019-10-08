/*-
 * Copyright (c) 2018 elementary LLC. (https://elementary.io)
 *               2014 Marvin Beckers <beckersmarvin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Marvin Beckers <beckersmarvin@gmail.com>
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
        static Operator[] operators = {
            Operator () { symbol = "+", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => a + b },
            Operator () { symbol = "-", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => a - b },
            Operator () { symbol = "−", inputs = 2, prec = 1, fixity = "LEFT", eval = (a, b) => a - b },
            Operator () { symbol = "*", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => a * b },
            Operator () { symbol = "×", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => a * b },
            Operator () { symbol = "/", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => a / b },
            Operator () { symbol = "÷", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => a / b },
            Operator () { symbol = "mod", inputs = 2, prec = 2, fixity = "LEFT", eval = (a, b) => a % b },
            Operator () { symbol = "^", inputs = 2, prec = 3, fixity = "RIGHT", eval = (a, b) => Math.pow (a, b) },
            Operator () { symbol = "E", inputs = 2, prec = 4, fixity = "RIGHT", eval = (a, b) => a * Math.pow (10, b) },
            Operator () { symbol = "%", inputs = 1, prec = 5, fixity = "LEFT", eval = (a, b) => b / 100.0 }
        };

        private struct Function { string symbol; int inputs; Eval eval;}
        static Function[] functions = {
            Function () { symbol = "sin", inputs = 1, eval = (a) => Math.sin (a) },
            Function () { symbol = "cos", inputs = 1, eval = (a) => Math.cos (a) },
            Function () { symbol = "tan", inputs = 1, eval = (a) => Math.tan (a) },
            Function () { symbol = "sinh", inputs = 1, eval = (a) => Math.sinh (a) },
            Function () { symbol = "cosh", inputs = 1, eval = (a) => Math.cosh (a) },
            Function () { symbol = "tanh", inputs = 1, eval = (a) => Math.tanh (a) },
            Function () { symbol = "log", inputs = 1, eval = (a) => Math.log (a) },
            Function () { symbol = "exp", inputs = 1, eval = (a) => Math.exp (a) },
            Function () { symbol = "sqrt", inputs = 1, eval = (a) => Math.sqrt (a) },
            Function () { symbol = "√", inputs = 1, eval = (a) => Math.sqrt (a) }
        };

        private struct Constant { string symbol; Eval eval; }
        static Constant[] constants = {
            Constant () { symbol = "pi", eval = () => Math.PI },
            Constant () { symbol = "π", eval = () => Math.PI },
            Constant () { symbol = "e", eval = () => Math.E }
        };


        public Scanner scanner = new Scanner ();

        public Evaluation () { }

        public string evaluate (string str, int d_places) throws OUT_ERROR {
            try {
                var tokenlist = scanner.scan (str);
                var d = 0.0;

                try {
                    tokenlist = shunting_yard (tokenlist);
                    try {
                        d = eval_postfix (tokenlist);
                    } catch (Error e) {
                        throw new OUT_ERROR.EVAL_ERROR (e.message);
                    }
                } catch (Error e) {
                    throw new OUT_ERROR.SHUNTING_ERROR (e.message);
                }
                return number_to_string (d, d_places);
            } catch (Error e) {
                throw new OUT_ERROR.SCANNER_ERROR (e.message);
            }
        }

        /* Djikstra's Shunting Yard algorithm for ordering a tokenized list into Reverse Polish Notation */
        private List<Token> shunting_yard (List<Token> token_list) throws SHUNTING_ERROR {
            List<Token> output = new List<Token> ();
            Queue<Token> op_stack = new Queue<Token> ();

            foreach (Token t in token_list) {
                switch (t.token_type) {
                    case TokenType.NUMBER:
                        output.append (t);
                        break;
                    case TokenType.CONSTANT:
                        output.append (t);
                        break;
                    case TokenType.FUNCTION:
                        op_stack.push_tail (t);
                        break;
                    case TokenType.SEPARATOR:
                        while (!op_stack.is_empty () && op_stack.peek_tail ().token_type != TokenType.P_LEFT) {
                            output.append (op_stack.pop_tail ());
                        }

                        if (op_stack.peek_tail ().token_type != TokenType.P_LEFT) {
                            throw new SHUNTING_ERROR.MISMATCHED_P ("Content of parentheses is mismatched.");
                        }
                        break;
                    case TokenType.OPERATOR:
                        if (!op_stack.is_empty ()) {
                            Operator op1 = get_operator (t);
                            Operator op2 = Operator ();

                            try {
                                op2 = get_operator (op_stack.peek_tail ());
                            } catch (SHUNTING_ERROR e) { }

                            while (!op_stack.is_empty () && op_stack.peek_tail ().token_type == TokenType.OPERATOR &&
                            ((op2.fixity == "LEFT" && op1.prec <= op2.prec) ||
                            (op2.fixity == "RIGHT" && op1.prec < op2.prec))) {
                                output.append (op_stack.pop_tail ());

                                if (!op_stack.is_empty ()) {
                                    try {
                                        op2 = get_operator (op_stack.peek_tail ());
                                    } catch (SHUNTING_ERROR e) { }
                                }
                            }
                        }
                        op_stack.push_tail (t);
                        break;
                    case TokenType.P_LEFT:
                        op_stack.push_tail (t);
                        break;
                    case TokenType.P_RIGHT:
                        while (!op_stack.is_empty ()) {
                            if (op_stack.peek_tail ().token_type != TokenType.P_LEFT) {
                                output.append (op_stack.pop_tail ());
                            } else {
                                break;
                            }
                        }

                        if (!op_stack.is_empty () && op_stack.peek_tail ().token_type == TokenType.P_LEFT) {
                            op_stack.pop_tail ();
                        }

                        if (!op_stack.is_empty () && op_stack.peek_tail ().token_type == TokenType.FUNCTION) {
                            output.append (op_stack.pop_tail ());
                        }

                        break;
                    default:
                        throw new SHUNTING_ERROR.UNKNOWN_TOKEN ("'%s' is unknown.", t.content);
                }
            }

            while (!op_stack.is_empty ()) {
                if (op_stack.peek_tail ().token_type == TokenType.P_LEFT ||
                    op_stack.peek_tail ().token_type == TokenType.P_RIGHT
                ) {
                    throw new SHUNTING_ERROR.MISMATCHED_P ("Mismatched parenthesis.");
                } else {
                    output.append (op_stack.pop_tail ());
                }
            }

            return output;
        }

        private double eval_postfix (List<Token> token_list) throws EVAL_ERROR {
            Queue<Token> stack = new Queue<Token> ();

            foreach (Token t in token_list) {
                if (t.token_type == TokenType.NUMBER) {
                    stack.push_tail (t);
                } else if (t.token_type == TokenType.CONSTANT) {
                    try {
                        Constant c = get_constant (t);
                        stack.push_tail (new Token (c.eval ().to_string (), TokenType.NUMBER));
                    } catch (SHUNTING_ERROR e) {
                        throw new EVAL_ERROR.NO_CONSTANT ("");
                    }
                } else if (t.token_type == TokenType.OPERATOR) {
                    try {
                        Operator o = get_operator (t);
                        Token t1 = stack.pop_tail ();
                        Token t2 = new Token ("0", TokenType.NUMBER);

                        if (!stack.is_empty () && o.inputs == 2) {
                            t2 = stack.pop_tail ();
                        }
                        stack.push_tail (compute (o.eval, t2, t1));
                    } catch (SHUNTING_ERROR e) {
                        throw new EVAL_ERROR.NO_OPERATOR ("");
                    }
                } else if (t.token_type == TokenType.FUNCTION) {
                    try {
                        Function f = get_function (t);
                        Token t1 = stack.pop_tail ();
                        Token t2 = new Token ("0", TokenType.NUMBER);

                        if (!stack.is_empty () && f.inputs == 2) {
                            t2 = stack.pop_tail ();
                        }
                        stack.push_tail (compute (f.eval, t1, t2));
                    } catch (SHUNTING_ERROR e) {
                        throw new EVAL_ERROR.NO_FUNCTION ("");
                    }
                }
            }
            return double.parse (stack.pop_tail ().content);
        }

        /* Checks for real TokenType (which are TokenType.ALPHA at the moment) */
        public static bool is_operator (Token t) {
            foreach (Operator o in operators) {
                if (t.content == o.symbol) {
                    return true;
                }
            }
            return false;
        }

        public static bool is_function (Token t) {
            foreach (Function f in functions) {
                if (t.content == f.symbol) {
                    return true;
                }
            }
            return false;
        }

        public static bool is_constant (Token t) {
            foreach (Constant c in constants) {
                if (t.content == c.symbol) {
                    return true;
                }
            }
            return false;
        }

        private Operator get_operator (Token t) throws SHUNTING_ERROR {
            foreach (Operator o in operators) {
                if (t.content == o.symbol) {
                    return o;
                }
            }
            throw new SHUNTING_ERROR.NO_OPERATOR ("");
        }

        private Function get_function (Token t) throws SHUNTING_ERROR {
            foreach (Function f in functions) {
                if (t.content == f.symbol) {
                    return f;
                }
            }
            throw new SHUNTING_ERROR.NO_FUNCTION ("");
        }

        private Constant get_constant (Token t) throws SHUNTING_ERROR {
            foreach (Constant c in constants) {
                if (t.content == c.symbol) {
                    return c;
                }
            }
            throw new SHUNTING_ERROR.NO_CONSTANT ("");
        }

        private Token compute (Eval eval, Token t1, Token t2) throws EVAL_ERROR {
            double d = eval (double.parse (t1.content), double.parse (t2.content));
            if (fabs (d) - 0.0 < double.EPSILON) {
                d = 0.0;
            }
            return new Token (d.to_string (), TokenType.NUMBER);
        }

        private string number_to_string (double d, int d_places) {
            string s = ("%.9f".printf (d));
            string s_localized = s.replace (".", scanner.decimal_symbol);

            /* Remove trailing 0s or decimal symbol */
            while (s_localized.has_suffix ("0")) {
                s_localized = s_localized.slice (0, -1);
            }
            if (s_localized.has_suffix (scanner.decimal_symbol)) {
                s_localized = s_localized.slice (0, -1);
            }

            /* Insert separator symbol in large numbers */
            var builder = new StringBuilder (s_localized);
            var decimal_pos = s_localized.last_index_of (scanner.decimal_symbol);
            if (decimal_pos == -1) {
                decimal_pos = s_localized.length;
            }

            int end_position = 0;
            if (s_localized.has_prefix ("-")) {
                end_position = 1;
            }
            for (int i = decimal_pos - 3; i > end_position; i -= 3) {
                builder.insert (i, scanner.separator_symbol);
            }
            return builder.str;
        }
    }
}
