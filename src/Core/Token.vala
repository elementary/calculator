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
    public enum TokenType {
        NUMBER,
        OPERATOR,
        FUNCTION,
        SEPARATOR,
        CONSTANT,
        P_LEFT,
        P_RIGHT,
        
        //basic TokenTypes for Scanner output
        ALPHA,
        EOF;
    }
    
    public class Token : Object {
        public string content { get; private set; }
        public TokenType token_type { get; set; }
        
        public Token (string in_content, TokenType in_token_type) {
            content = in_content;
            token_type = in_token_type;
        }
    }
}
