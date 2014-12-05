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
*
* Thanks to flo @ #vala (gimpnet) for writing the basic scanner for me and providing endless knowledge.
*/

namespace Calculus.Core {
    public errordomain SCANNER_ERROR {
        UNKNOWN_TOKEN
    }
    
    public class Scanner {
        private unowned string str;
        private char* pos;
        
        public Scanner (string input_str) {
            str = input_str;
            pos = input_str;
        }
        
        public static List<Token> scan (string input) {
            Scanner scanner = new Scanner (input);
            TokenType type = TokenType.EOF;
            List<Token> tokenlist = new List<Token> ();

            try {
                do {
                    size_t start;
                    size_t len;
                    
                    type = scanner.next (out start, out len);
                    string substr = input.substring ((long) start, (long) len);
                    tokenlist.append (new Token (substr, type));
                } while (type != TokenType.EOF);
            } catch (Error e) {
                stdout.printf ("[Error] %s \n", e.message);
            }
            
            return tokenlist;
        }
        
        private TokenType next (out size_t start, out size_t len) throws SCANNER_ERROR {
            skip_spaces ();
            start = pos - (char*) str;
            
            if (pos[0].isdigit ()) {
                while (pos[0].isdigit ())
                    pos++;
                if (pos[0] == '.')
                    pos++;
                while (pos[0].isdigit ())
                    pos++;
                len = pos - (char*) str - start;
                return TokenType.NUMBER;
            } else if (pos[0].isalpha ()) {
                while (pos[0].isalpha ())
                    pos++;
                len = pos - (char*) str - start;
                return TokenType.ALPHA;
            } else if (pos[0] == '+' || pos[0] == '-' || pos[0] == '*' || pos[0] == '/' || pos[0] == '^' || pos[0] == '%') {
                pos++;
                len = 1;
                return TokenType.OPERATOR;
            } else if (pos[0] == '(') {
                pos++;
                len = 1;
                return TokenType.P_LEFT;
            } else if (pos[0] == ')') {
                pos++;
                len = 1;
                return TokenType.P_RIGHT;
            } else if (pos[0] == '\0') {
                len = 0;
                return TokenType.EOF;
            }
            
            //if no rule matches the character at pos, throw an error.
            throw new SCANNER_ERROR.UNKNOWN_TOKEN ("Unknown Token.");       
        }
        
        private void skip_spaces () {
            while (pos[0] == ' ' || pos[0] == '\t')
                pos++;
        }
    }
}
