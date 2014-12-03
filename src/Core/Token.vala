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
    public enum TokenType {
        NUMBER,
        OPERATOR,
        FUNCTION,
        SEPARATOR,
        PARENTHESIS_LEFT,
        PARENTHESIS_RIGHT;
    }
    
    public class Token : Object {
        private string content;
        private TokenType token_type;
        
        public Token (string in_content, TokenType in_token_type) {
            content = in_content;
            token_type = in_token_type;
        }
        
        public string get_content () { return content; }
        public TokenType get_token_type () { return token_type; }
        
    }
}
