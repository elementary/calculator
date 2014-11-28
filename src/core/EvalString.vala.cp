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
    public class EvalString : Object {
        private string input;
        private double result;
        private PostfixConverter pc;
        
        public EvalString (string exp) {
            input = exp;
            pc = new PostfixConverter (exp);
            this.eval (exp);
        }
        
        public double get_result () {
            return result;
        }
        
        private void eval (string exp) {
            List<string> expList = new List<string> ();
            Stack<double?> stack = new Stack<double?> ();
            bool error = false;
            string temp_s = exp;
            
            //pushing two '0's to the stack to prevent errors while applying a operator to less than two numbers
            //TODO this is just a workaround - may fix that in later version
            stack.push (0);
            stack.push (0);
            
            while (temp_s.index_of (" ") != -1) {
                expList.append (temp_s.slice (0, temp_s.index_of (" ")));
                temp_s = temp_s.slice (temp_s.index_of (" ") + 1, temp_s.length);
            }
            
            if (temp_s.index_of (" ") == - 1 && temp_s != "") 
                expList.append (temp_s);
            
            foreach (string entry in expList) {
	        	double d;
	            bool is_d = double.try_parse (entry, out d);
	            
	            if (is_d == true) 
	                stack.push (d);
	            else if (entry == "+" || entry == "-" || entry == "*" || entry == "/") {
	                double right = stack.pop ();
	                double left = stack.pop ();
	                double temp_d = compute (left, right, entry);
	                stack.push (temp_d);
	            }
	            else 
	                error = true;
	        }
	        
            result = stack.pop ();
        }
        
        private double compute (double d1, double d2, string op) {
            if (op == "+") 
                return d1 + d2;
            else if (op == "-")
                return d1 - d2;
            else if (op == "*") 
                return d1 * d2;
            else if (op == "/")
                return d1 / d2;
            else
                return 0.0;
        }
    }
}
