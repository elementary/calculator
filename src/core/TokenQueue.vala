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
    public class TokenQueue : Object {
        private string input_string;
        private Token[] token_array;
        
        public TokenQueue (string exp) {
            input_string = exp;
            this.parse (exp);
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
        
        private void parse (string exp) {
            // Parser functionality.
            /* TODO: improve this parser. it's pretty bad at the moment, but does the job I guess */
            
            string symbol = "";
            string symbol_old = "";
            string temp = exp.replace (" ", "");
            List<string> numbers = new List<string> ();
            string temp_numbers = "";
            
            this.destroy_array ();
            
            while (temp != "") {
                symbol_old = symbol;
                symbol = temp.slice (0, 1);
                temp = temp.slice (1, temp.length);
                
                switch (symbol) {
                case "1": case "2": case "3": case "4":
                case "5": case "6": case "7": case "8":
                case "9": case "0": case ".":
                    numbers.append (symbol);
                    break;
                case "+": case "-": case "*": case "/":
                case "^":
                    if (numbers.length () != 0) {
                        temp_numbers = "";
                        
                        foreach (string n in numbers) 
                            temp_numbers = temp_numbers + n;
                            
                        this.add (new Token (temp_numbers, TokenType.NUMBER));
                        numbers = new List<string> ();
                    }
                    this.add (new Token (symbol, TokenType.OPERATOR));
                    break;
                case ",":
                    temp_numbers = "";
                    
                    foreach (string n in numbers) 
                        temp_numbers = temp_numbers + n;
                        
                    this.add (new Token (temp_numbers, TokenType.NUMBER));
                    numbers = new List<string> ();
                    this.add (new Token (",", TokenType.SEPARATOR));
                    break;
                case "(":
                    if (numbers.length () != 0) {
                        temp_numbers = "";
                        
                        foreach (string n in numbers)
                            temp_numbers = temp_numbers + n;
                            
                        this.add (new Token (temp_numbers, TokenType.NUMBER));
                        this.add (new Token ("*", TokenType.OPERATOR));
                    }
                    this.add (new Token ("(", TokenType.PARENTHESIS_LEFT));
                    break;
                case ")":
                
                    if (numbers.length () != 0) {
                        temp_numbers = "";
                        
                        foreach (string n in numbers) 
                            temp_numbers = temp_numbers + n;

                        this.add (new Token (temp_numbers, TokenType.NUMBER));
                        numbers = new List<string> ();
                    }
                    this.add (new Token (")", TokenType.PARENTHESIS_RIGHT));
                    break;
                case "%":
                    temp_numbers = "";
                    
                    foreach (string n in numbers)
                        temp_numbers = temp_numbers + n;
                    
                    double temp_d = double.parse (temp_numbers) / 100;
                    this.add (new Token (temp_d.to_string (), TokenType.NUMBER));
                    numbers = new List<string> ();
                    break;
                } 
            }
            
            /*  check if there is anything left in numbers (most likely it is)  */
            if (numbers.length () != 0) {
                temp_numbers = "";
                foreach (string n in numbers) 
                    temp_numbers = temp_numbers + n;
                this.add (new Token (temp_numbers, TokenType.NUMBER));
            }  
        }
    }
}
