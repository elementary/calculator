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
    public enum TokenType {
        NULL_NUMBER, //A number with a decimal point but no leading digits e.g. .5
        NUMBER,
        OPERATOR,
        FUNCTION,
        SEPARATOR,
        CONSTANT,
        P_LEFT,
        P_RIGHT,
        ALPHA,
        EOF;
    }

    public class Token : Object {
        public string content { get; set construct; }
        public TokenType token_type { get; set construct; }

        public Token (string in_content, TokenType in_token_type) {
            Object (
                content: in_content,
                token_type: in_token_type
            );
        }

        public bool is_null_number () {
            return token_type == TokenType.NULL_NUMBER;
        }
        public bool is_number () {
            return token_type == TokenType.NUMBER;
        }
        public bool is_operator () {
            return token_type == TokenType.OPERATOR;
        }
        public bool is_function () {
            return token_type == TokenType.FUNCTION;
        }
        public bool is_separator () {
            return token_type == TokenType.SEPARATOR;
        }
        public bool is_constant () {
            return token_type == TokenType.CONSTANT;
        }
        public bool is_left_paren () {
            return token_type == TokenType.P_LEFT;
        }
        public bool is_right_paren () {
            return token_type == TokenType.P_RIGHT;
        }
        public bool is_alpha () {
            return token_type == TokenType.ALPHA;
        }
        public bool is_minus_sign () {
            return token_type == TokenType.OPERATOR && (content in "-−");
        }
    }
}
