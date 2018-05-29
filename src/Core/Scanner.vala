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

namespace PantheonCalculator.Core {
    public errordomain SCANNER_ERROR {
        UNKNOWN_TOKEN,
        ALPHA_INVALID
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
            Evaluation e = new Evaluation ();

            string str = input.replace (" ", "");
            str = str.replace (separator_symbol, "");

            pos = 0;
            uc = new unichar[str.char_count ()];
            for (int i = 0; str.get_next_char (ref index, out c); i++) {
                uc[i] = c;
            }

            try {
                TokenType type = TokenType.EOF;
                unowned Token? last_token = null;
                List<Token> tokenlist = new List<Token> ();
                while (pos < uc.length) {
                    ssize_t start, len;
                    type = next (out start, out len);

                    string substr = "";
                    for (ssize_t i = start; i < (start + len); i++) {
                        substr += uc[i].to_string ();
                    }

                    substr = substr.replace (decimal_symbol, ".");

                    Token t = new Token (substr, type);

                    /* Identifying multicharacter tokens via Evaluation class. */
                    if (t.token_type == TokenType.ALPHA) {
                        if (e.is_operator (t)) {
                            t.token_type = TokenType.OPERATOR;
                        } else if (e.is_function (t)) {
                            t.token_type = TokenType.FUNCTION;
                        } else if (e.is_constant (t)) {
                            t.token_type = TokenType.CONSTANT;
                        } else {
                            throw new SCANNER_ERROR.ALPHA_INVALID (_("'%s' is invalid."), t.content);
                        }

                    } else if (t.token_type == TokenType.OPERATOR && (t.content == "-" || t.content == "−")) {
                        /* Define last_tokens, where a next minus is a number, not an operator */
                        if (last_token == null || (
                            (last_token.token_type == TokenType.OPERATOR && last_token.content != "%") ||
                            (last_token.token_type == TokenType.FUNCTION) ||
                            (last_token.token_type == TokenType.P_LEFT)
                        )) {
                            next_number_negative = true;
                            continue;
                        }

                    } else if (t.token_type == TokenType.NUMBER && next_number_negative) {
                        t.content = (double.parse (t.content) * (-1)).to_string ();
                        next_number_negative = false;
                    } else if (t.token_type == TokenType.NULL_NUMBER) {
                        t.content = "0" + t.content;
                        t.token_type = TokenType.NUMBER;
                    }

                    /*
                    * checking if last token was a number or parenthesis right
                    * and token now is a function, constant or parenthesis (left)
                    */
                    if (last_token != null &&
                    (last_token.token_type == TokenType.NUMBER || last_token.token_type == TokenType.P_RIGHT) &&
                    (t.token_type == TokenType.FUNCTION || t.token_type == TokenType.CONSTANT
                    || t.token_type == TokenType.P_LEFT || t.token_type == TokenType.NUMBER)) {
                        tokenlist.append (new Token ("*", TokenType.OPERATOR));
                    }

                    tokenlist.append (t);
                    last_token = t;
                }
                return tokenlist;
            } catch (SCANNER_ERROR e) {
                throw e;
            }
        }

        private TokenType next (out ssize_t start, out ssize_t len) throws SCANNER_ERROR {
            start = pos;
            if (uc[pos] == decimal_symbol.get_char (0)) {
                pos++;
                while (uc[pos].isdigit () && pos < uc.length) {
                    pos++;
                }
                len = pos - start;
                return TokenType.NULL_NUMBER;
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
                len = pos - start;
                return TokenType.NUMBER;
            } else if (uc[pos] == '+' || uc[pos] == '-' || uc[pos] == '*' ||
                        uc[pos] == '/' || uc[pos] == '^' || uc[pos] == '%' ||
                        uc[pos] == '÷' || uc[pos] == '×' || uc[pos] == '−') {
                pos++;
                len = 1;
                return TokenType.OPERATOR;
            } else if (uc[pos] == '√') {
                pos++;
                len = 1;
                return TokenType.FUNCTION;
            } else if (uc[pos] == 'π') {
                pos++;
                len = 1;
                return TokenType.CONSTANT;
            } else if (uc[pos].isalpha ()) {
                while (uc[pos].isalpha () && pos < uc.length) {
                    pos++;
                }
                len = pos - start;
                return TokenType.ALPHA;
            } else if (uc[pos] == '(') {
                pos++;
                len = 1;
                return TokenType.P_LEFT;
            } else if (uc[pos] == ')') {
                pos++;
                len = 1;
                return TokenType.P_RIGHT;
            } else if (uc[pos] == '\0') {
                len = 0;
                return TokenType.EOF;
            }

            /* If no rule matches the character at pos, throw an error. */
            throw new SCANNER_ERROR.UNKNOWN_TOKEN (_("'%s' is unknown."), uc[pos].to_string ());
        }
    }
}
