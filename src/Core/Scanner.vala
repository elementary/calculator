/*-
 * Copyright (c) 2020 elementary LLC. (https://elementary.io)
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

namespace PantheonCalculator.Core {
    public errordomain SCANNER_ERROR {
        UNKNOWN_TOKEN,
        ALPHA_INVALID,
        MISMATCHED_PARENTHESES
    }

    public class Scanner : Object {
        private ssize_t pos;
        private unichar[] uc;

        public string decimal_symbol { get; set; }
        public string separator_symbol { get; set; }

        public Scanner () {
            decimal_symbol = Posix.nl_langinfo (Posix.NLItem.RADIXCHAR);
            separator_symbol = Posix.nl_langinfo (Posix.NLItem.THOUSEP);
        }

        public List<Token> scan (string input) throws SCANNER_ERROR {
            int index = 0;
            unowned unichar c;
            bool next_number_negative = false;

            string str = input.replace (" ", "");
            str = str.replace (separator_symbol, "");

            pos = 0;
            uc = new unichar[str.char_count ()];
            for (int i = 0; str.get_next_char (ref index, out c); i++) {
                uc[i] = c;
            }

            Token? last_token = null;
            List<Token> token_list = new List<Token> ();
            int parentheses_balance_counter = 0;
            while (pos < uc.length) {
                Token t = next_token ();
                /* Identifying multicharacter tokens via Evaluation class. */
                if (t.token_type == TokenType.ALPHA) {
                    if (Evaluation.is_operator (t)) {
                        t.token_type = TokenType.OPERATOR;
                    } else if (Evaluation.is_function (t)) {
                        t.token_type = TokenType.FUNCTION;
                    } else if (Evaluation.is_constant (t)) {
                        t.token_type = TokenType.CONSTANT;
                    } else {
                        throw new SCANNER_ERROR.ALPHA_INVALID (_("'%s' is invalid."), t.content);
                    }
                } else if (t.token_type == TokenType.OPERATOR && (t.content in "-−")) {
                    /* Define last_tokens, where a next minus is a number, not an operator */
                    if (last_token == null || (
                        (last_token.token_type == TokenType.OPERATOR && last_token.content != "%") ||
                        (last_token.token_type == TokenType.FUNCTION) ||
                        (last_token.token_type == TokenType.P_LEFT)
                    )) {
                        // A minus sign not following a number can be merged with a following number;
                        next_number_negative = true;
                        continue;
                    }
                } else if (t.token_type == TokenType.NULL_NUMBER) {
                    //Insert a leading zero to make complete number e.g. .5 -> 0.5
                    t.content = "0" + t.content;
                    t.token_type = TokenType.NUMBER;
                }

                if (next_number_negative && t.token_type == TokenType.NUMBER) {
                    // Merge minus sign into the number itself
                    t.content = (double.parse (t.content) * (-1)).to_string ();
                    next_number_negative = false;
                }

                /*
                * Checking if last token was a number or parenthesis right
                * and token now is a function, constant or parenthesis (left)
                */
                if (last_token != null &&
                   (last_token.token_type == TokenType.NUMBER || last_token.token_type == TokenType.P_RIGHT) &&
                   (t.token_type == TokenType.FUNCTION || t.token_type == TokenType.CONSTANT ||
                    t.token_type == TokenType.P_LEFT || t.token_type == TokenType.NUMBER)
                ) {
                    token_list.append (new Token ("*", TokenType.OPERATOR));
                }

                if (t.token_type == TokenType.P_LEFT) {
                    parentheses_balance_counter -= 1;
                } else if (t.token_type == TokenType.P_RIGHT) {
                    parentheses_balance_counter += 1;
                }

                token_list.append (t);
                last_token = t;
            }

            if (parentheses_balance_counter != 0) {
                throw new SCANNER_ERROR.MISMATCHED_PARENTHESES (_("Mismatched parenthesis."));
            }

            return token_list;
        }

        private Token next_token () throws SCANNER_ERROR {
            ssize_t start = pos;
            TokenType type;

            if (uc[pos] == decimal_symbol.get_char (0)) {
                pos++;
                while (uc[pos].isdigit () && pos < uc.length) {
                    pos++;
                }
                type = TokenType.NULL_NUMBER;
            } else if (uc[pos].isdigit ()) {
                while (uc[pos].isdigit () && pos < uc.length) {
                    pos++;
                }
                if (uc[pos] == decimal_symbol.get_char (0)) {
                    pos++;
                }
                while (uc[pos].isdigit () && pos < uc.length) {
                    pos++;
                }
                type = TokenType.NUMBER;
            } else if (is_plus_minus_times (uc[pos]) ||
                        uc[pos] == '/' || uc[pos] == '÷' ||
                        uc[pos] == '^' || uc[pos] == '%') {
                pos++;
                if (pos < uc.length) {
                    if (uc[pos] == '%' && is_plus_minus_times (uc[pos - 1])) {
                        pos++;
                    }
                }
                type = TokenType.OPERATOR;
            } else if (uc[pos] == '√') {
                pos++;
                type = TokenType.FUNCTION;
            } else if (uc[pos] == 'π') {
                pos++;
                type = TokenType.CONSTANT;
            } else if (uc[pos].isalpha ()) {
                while (uc[pos].isalpha () && pos < uc.length) {
                    pos++;
                }
                type = TokenType.ALPHA;
            } else if (uc[pos] == '(') {
                pos++;
                type = TokenType.P_LEFT;
            } else if (uc[pos] == ')') {
                pos++;
                type = TokenType.P_RIGHT;
            } else if (uc[pos] == '\0') {
                type = TokenType.EOF;
            } else {
                /* If no rule matches the character at pos, throw an error. */
                throw new SCANNER_ERROR.UNKNOWN_TOKEN (_("'%s' is unknown."), uc[pos].to_string ());
            }

            string substr = "";
            for (ssize_t i = start; i < pos; i++) {
                substr += uc[i].to_string ();
            }
            substr = substr.replace (decimal_symbol, ".");

            return new Token (substr, type);
        }

        /* Operators than can combine with % */
        private bool is_plus_minus_times (unichar uc) {
            return uc == '+' ||
                   uc == '-' ||
                   uc == '*' ||
                   uc == '×' ||
                   uc == '−';
        }
    }
}
