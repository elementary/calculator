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
    public errordomain ParserError {
        SYNTAX
    }
    
    public class TokenQueue : Object {
        private string input_string;
        private Token[] token_array;
        private List<string> numbers = new List<string> ();
        private List<string> func = new List<string> ();
        
        public TokenQueue (string exp) throws ParserError {
            input_string = exp;
            try {
                this.parse (exp);
            } catch (ParserError e) {
                throw e;
            }
        }
        
        // public functions.
        public int get_max_pos () { return (token_array.length - 1); }
        public Token get_token (int pos) { return token_array[pos]; }
        
        // private functions for working with the private array.
        private void add (Token t) {
            token_array.resize (token_array.length + 1);
            token_array[token_array.length - 1] = t;
        }
        
        private void destroy_array () { token_array.resize (0); }
        
        // parsing string into tokens.
        private void parse (string exp) throws ParserError {
            string symbol = "";
            string temp = exp.replace (" ", "");
            this.destroy_array ();
            
            while (temp != "") {
                symbol = temp.slice (0, 1);
                temp = temp.slice (1, temp.length);
                
                switch (symbol) {
                case "1": case "2": case "3": case "4":
                case "5": case "6": case "7": case "8":
                case "9": case "0": case ".":
                    numbers.append (symbol);
                    break;
                case "a": case "b": case "c": case "d": case "e":
                case "f": case "g": case "h": case "i": case "j":
                case "k": case "l": case "m": case "n": case "o":
                case "p": case "q": case "r": case "s": case "t":
                case "u": case "v": case "w": case "x": case "y":
                case "z":
                    func.append (symbol);
                    break;
                case "+": case "-": case "*": case "/":
                case "^":
                    if (!this.is_empty (numbers)) {
                        this.add (this.create_token (numbers));
                        numbers = new List<string> ();
                    }
                    this.add (new Token (symbol, TokenType.OPERATOR));
                    break;
                case ",":
                    if (!this.is_empty (numbers)) {
                        this.add (this.create_token (numbers));
                        numbers = new List<string> ();
                    }
                    this.add (new Token (",", TokenType.SEPARATOR));
                    break;
                case "(":
                    if (!this.is_empty (numbers)) {
                        this.add (this.create_token (numbers));
                        numbers = new List<string> ();
                        this.add (new Token ("*", TokenType.OPERATOR));
                    } else if (!this.is_empty (func)) {
                        this.add (this.create_token (func, TokenType.FUNCTION));
                        func = new List<string> ();
                    }
                    this.add (new Token ("(", TokenType.PARENTHESIS_LEFT));
                    break;
                case ")":
                    if (!this.is_empty (numbers)) {
                        this.add (this.create_token (numbers));
                        numbers = new List<string> ();
                    }
                    this.add (new Token (")", TokenType.PARENTHESIS_RIGHT));
                    break;
                case "%":
                    if (!this.is_empty (numbers)) {
                        this.add (this.create_token (numbers, TokenType.NUMBER, true));
                        numbers = new List<string> ();
                    }
                    break;
                } 
            }
            
            // check if there is anything left in numbers (most likely it is) 
            if (!this.is_empty (numbers)) {
                this.add (this.create_token (numbers));
                numbers = new List<string> ();
            }
        }
        
        private bool is_empty (List<string> ls) {
            return (ls.length () == 0);
        }
        
        private Token create_token (List<string> ls, TokenType tt = TokenType.NUMBER, bool percent = false) {
            string temp = "";
            foreach (string s in ls) 
                temp = temp + s;
            if (percent == true) {
                double temp_d = double.parse (temp) / 100;
                temp = temp_d.to_string ();
            }
            return new Token (temp, tt);
        }
    }
}
