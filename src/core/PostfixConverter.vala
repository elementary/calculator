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
    public class PostfixConverter : Object {
        private string infix;
        private string postfix;
        
        public PostfixConverter (string exp) { 
            infix = exp;
            this.shunting_yard (exp);
        }
        
        public string get_postfix () {
            return postfix;
        }
        
        private void shunting_yard (string exp) {
            // implementation of the Shunting Yard Algorithm by Edsger Dijkstra
            // https://en.wikipedia.org/wiki/Shunting-yard_algorithm
            
            Stack<Token> opStack = new Stack<Token> ();
            TokenQueue tq = new TokenQueue (infix);
            Queue<string> output = new Queue<string> ();
            string op1 = "";
            string op2 = "";
            
            for (int i = 0; i <= tq.get_max_pos (); i++) {
                // (1) if the token is a number, then add it to the output queue.
                if (tq.get_token (i).get_token_type () == TokenType.NUMBER)
                    output.push_tail (tq.get_token (i).get_content ());
                    
                // (2) If the token is a function token, then push it onto the stack.
                if (tq.get_token (i).get_token_type () == TokenType.FUNCTION)
                    opStack.push (tq.get_token (i));
                
                // (3) If the token is a function argument separator (e.g., a comma):
                // (3.1) Until the token at the top of the stack is a left parenthesis, pop operators off the stack onto the output queue. 
                // (3.2) If no left parentheses are encountered, either the separator was misplaced or parentheses were mismatched.
                
                // (4) If the token is an operator, o1, then:
                if (tq.get_token (i).get_token_type() == TokenType.OPERATOR) {
                    // (4.1) while there is an operator token, o2, at the top of the stack, and
                    // (4.1.1) either o1 is left-associative and its precedence is *less than or equal* to that of o2,
                    // (4.1.2) or o1 if right associative, and has precedence *less than* that of o2,
                    // (4.1.3) then pop o2 off the stack, onto the output queue;
                    
                    // (4.2) push o1 the stack.
                    opStack.push (tq.get_token (i));
                }
                
                // (5) If the token is a left parenthesis, then push it onto the stack.
                if (tq.get_token (i).get_token_type () == TokenType.PARENTHESIS_LEFT) 
                    opStack.push (tq.get_token (i));
                    
                // (6) If the token is a right parenthesis:
                if (tq.get_token (i).get_token_type () == TokenType.PARENTHESIS_RIGHT) {
                    // (6.1) Until the token at the top of the stack is a left parenthesis, pop operators off the stack onto the output queue.
                    // (6.2) Pop the left parenthesis from the stack, but not onto the output queue.
                    // (6.3) If the token at the top of the stack is a function token, pop it onto the output queue.
                    if (opStack.peek ().get_token_type () == TokenType.FUNCTION) {
                        output.push_tail (opStack.pop ().get_content ());
                    }
                    // (6.4) If the stack runs out without finding a left parenthesis, then there are mismatched parentheses.

                }
            }
            
            postfix = "";
        }
    }
}
