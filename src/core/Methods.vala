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

using Calculus.Core;

namespace Calculus.Core.Methods {
    public errordomain ShuntingYardError {
        MISPLACED_MISMATCHED,
        PARENTHESIS_MISPLACED
    }
    
    public enum Fixity {
        LEFT,
        RIGHT,
        NONE
    }

    public List<Token> shunting_yard (TokenQueue in_tq) throws ShuntingYardError {
        List<Token> output = new List<Token> ();
        Stack<Token> opStack = new Stack<Token> ();
        TokenQueue tq = in_tq;
        
        for (int i = 0; i <= tq.get_max_pos (); i++) {
            switch (tq.get_token (i).get_token_type ()) {
            // (1) if the token is a number, then add it to the output queue.
            case TokenType.NUMBER:
                output.append (tq.get_token (i));
                break;
                    
            // (2) If the token is a function token, then push it onto the stack.
           case TokenType.FUNCTION:
                opStack.push (tq.get_token (i));
                break;

            // (3) If the token is a function argument separator (e.g., a comma):
            case TokenType.SEPARATOR:
                // (3.1) Until the token at the top of the stack is a left parenthesis, pop operators off the stack onto the output queue.
                while (opStack.peek ().get_token_type () != TokenType.PARENTHESIS_LEFT && opStack.is_length (0) == false) 
                    output.append (opStack.pop ());
                
                // (3.2) If no left parentheses are encountered, either the separator was misplaced or parentheses were mismatched.
                if (opStack.peek ().get_token_type () != TokenType.PARENTHESIS_LEFT)
                    throw new ShuntingYardError.MISPLACED_MISMATCHED ("Either the seperatotor was misplaced or parentheses were mismatched.");
                break;
             
            // (4) If the token is an operator, o1, then:
            case TokenType.OPERATOR:
                Token op1 = tq.get_token (i);
                if (!opStack.empty ()) {
                    Token op2 = opStack.peek ();

                    while (!opStack.empty () && op2.get_token_type () == TokenType.OPERATOR &&              // (4.1) while there is an operator token, o2, at the top of the stack, and
                    (get_fixity (op2) == Fixity.LEFT && (get_precedence (op1) <= get_precedence (op2)) ||   // (4.1.1) either o1 is left-associative and its precedence is *less than or equal* to that of o2,
                    (get_fixity (op2) == Fixity.RIGHT && (get_precedence (op1) < get_precedence (op2)))     // (4.1.2) or o1 if right associative, and has precedence *less than* that of o2,
                    )) {   
                        // (4.1.3) then pop o2 off the stack, onto the output queue;
                        output.append (opStack.pop ());
                        if (!opStack.empty ())
                            op2 = opStack.peek ();
                    }
                }  
                // (4.2) push o1 the stack.
                opStack.push (op1);
                break;
            
            // (5) If the token is a left parenthesis, then push it onto the stack.
            case TokenType.PARENTHESIS_LEFT:
                opStack.push (tq.get_token (i));
                break;
                    
            // (6) If the token is a right parenthesis:
            case TokenType.PARENTHESIS_RIGHT:
                // (6.1) Until the token at the top of the stack is a left parenthesis, pop operators off the stack onto the output queue.
                while (!(opStack.peek ().get_token_type () == TokenType.PARENTHESIS_LEFT) && !opStack.empty ())
                    output.append (opStack.pop ());
                if (!(opStack.empty ())) 
                    opStack.pop ();
                // (6.2) Pop the left parenthesis from the stack, but not onto the output queue.
                // (6.3) If the token at the top of the stack is a function token, pop it onto the output queue.
                if (!opStack.empty () && opStack.peek ().get_token_type () == TokenType.FUNCTION) 
                    output.append (opStack.pop ());
                // (6.4) If the stack runs out without finding a left parenthesis, then there are mismatched parentheses.

                break;
            default:
                /* TODO Throw error (you should never get here, but better throw one) */
                break;
            }
        }
        while (!opStack.empty ()) {
            if (opStack.peek ().get_token_type () == TokenType.PARENTHESIS_LEFT) {
                /* TODO Throw mismatched error! */
                break;
            } else {
                output.append (opStack.pop ());
            }
        }
        
        return output;
    }
    
    public double eval_postfix (List<Token> in_tokenlist) {
        Stack<Token> stack = new Stack<Token> ();
        
        foreach (Token t in in_tokenlist) {
            //stdout.printf (t.get_content () + "\n");
            if (t.get_token_type () == TokenType.NUMBER) {
                stack.push (t);
            } else if (t.get_token_type () == TokenType.OPERATOR) {
                Token right = stack.pop ();
                Token left = stack.pop ();
                stack.push (compute_tokens (left, t, right));
            } else {
                // TODO Implement function evaluating
            }
        }
        
        double out_d = double.parse (stack.pop ().get_content ());
        return out_d;
    }
    
    private Token compute_tokens (Token t1, Token op, Token t2) {
        if (t1.get_token_type () == TokenType.NUMBER && t2.get_token_type () == TokenType.NUMBER
        && op.get_token_type () == TokenType.OPERATOR) {
            double d1 = double.parse (t1.get_content ());
            double d2 = double.parse (t2.get_content ());
            double out_d = 0.0;
            
            switch (op.get_content ()) {
                case "+": out_d = d1 + d2; break;
                case "-": out_d = d1 - d2; break;
                case "*": out_d = d1 * d2; break;
                case "/": out_d = d1 / d2; break;
                default: /* TODO Throw error message */ break;
            }
            return new Token (out_d.to_string (), TokenType.NUMBER);
        } else {
            /* TODO Throw error message */
            /* returns a dummy token at the moment */
            return new Token ("5", TokenType.NUMBER);
        }
    }
    
    private Fixity get_fixity (Token t) {
        if (t.get_token_type () == TokenType.OPERATOR) {
            switch (t.get_content ()) {
                case "+": case "-":
                case "*": case "/":
                    return Fixity.LEFT;
                case "^":
                    return Fixity.RIGHT;
            }
        }
        return Fixity.NONE;
    }
    
    private int get_precedence (Token t) {
        //  3 = exponents and roots
        //  2 = multiplication and division
        //  1 = addition and subtraction   
        
        switch (t.get_content ()) {
            case "+": case "-":
                return 1;
            case "*": case "/":
                return 2;
            case "^":
                return 3;
        }
        
        return 0;
    }
}
