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

namespace PantheonCalculator.Core {
    public errordomain SCANNER_ERROR {
        UNKNOWN_TOKEN,
        ALPHA_INVALID
    }

    public class Scanner : Object {
        public unowned string str;
        public int pos;
        public unichar[] uc;

        public Scanner (string input_str) {
            this.str = input_str;
            this.pos = 0;
            this.uc = new unichar[0];
        }

        public static List<Token> scan (string input) throws SCANNER_ERROR {
            Scanner scanner = new Scanner (input);
            int index = 0;
            unowned unichar c;
            bool next_number_negative = false;
            Evaluation e = new Evaluation ();

            for (int i = 0; input.get_next_char(ref index, out c); i++) {
                if (c != ' ') {
                    scanner.uc.resize (scanner.uc.length + 1);
                    scanner.uc[scanner.uc.length - 1] = c;
                }
            }
            try {
                TokenType type = TokenType.EOF;
                unowned Token? last_token = null;
                List<Token> tokenlist = new List<Token> ();
                while (scanner.pos < scanner.uc.length) {
                    ssize_t start;
                    ssize_t len;
                    string substr = "";

                    type = scanner.next (out start, out len);
                    for (ssize_t i = start; i < (start + len); i++) {
                        substr = substr + scanner.uc[i].to_string ();
                    }
                    Token t = new Token (substr, type);

                    //identifying multicharacter tokens via Evaluation class. 
                    if (t.token_type == TokenType.ALPHA) {
                        if (e.is_operator (t))
                            t.token_type = TokenType.OPERATOR;
                        else if (e.is_function (t))
                            t.token_type = TokenType.FUNCTION;
                        else if (e.is_constant (t))
                            t.token_type = TokenType.CONSTANT;
                        else
                            throw new SCANNER_ERROR.ALPHA_INVALID (_("'%s' is invalid."), t.content);

                    } else if (t.token_type == TokenType.OPERATOR && t.content == "-") {
                        if (last_token == null || (last_token != null && last_token.token_type != TokenType.NUMBER &&
                        last_token.token_type != TokenType.P_RIGHT)) {
                            next_number_negative = true;
                            continue;
                        }

                    } else if (t.token_type == TokenType.NUMBER && next_number_negative) {
                        t.content = (double.parse (t.content) * (-1)).to_string ();
                        next_number_negative = false;
                    }

                    /*
                    * checking if last token was a number or parenthesis right
                    * and token now is a function, constant or parenthesis (left)
                    */
                    if (last_token != null && 
                    (last_token.token_type == TokenType.NUMBER || last_token.token_type == TokenType.P_RIGHT) &&
                    (t.token_type == TokenType.FUNCTION || t.token_type == TokenType.CONSTANT
                    || t.token_type == TokenType.P_LEFT || t.token_type == TokenType.NUMBER))
                        tokenlist.append (new Token ("*", TokenType.OPERATOR));

                    tokenlist.append (t);
                    last_token = t;
                }
                return tokenlist;
            } catch (SCANNER_ERROR e) { throw e; }
        }

        private TokenType next (out ssize_t start, out ssize_t len) throws SCANNER_ERROR {
            start = pos;
            if (uc[pos] == '.') {
                while (uc[pos].isdigit ())
                    pos++;
                len = pos - start;
                return TokenType.NUMBER;
            } else if (uc[pos].isdigit ()) {
                while (uc[pos].isdigit ())
                    pos++;
                if (uc[pos] == '.')
                    pos++;
                while (uc[pos].isdigit ())
                    pos++;
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
                while (uc[pos].isalpha ())
                    pos++;
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

            //if no rule matches the character at pos, throw an error.
            throw new SCANNER_ERROR.UNKNOWN_TOKEN (_("'%s' is unknown."), str.get_char (pos).to_string ());
        }
    }
}
