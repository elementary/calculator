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
    public class Stack<TYPE> : Object {
        private TYPE[] stack_array;
        
        public Stack () { }
        
        public void push (TYPE t) {
            stack_array.resize (stack_array.length + 1);
            stack_array[stack_array.length - 1] = t;
        }
        
        public TYPE pop () {
            if (stack_array.length > 0) {
                TYPE output = stack_array[stack_array.length - 1];
                stack_array[stack_array.length - 1] = 0;
                stack_array.resize (stack_array.length - 1);
                return output;
            } else {
                return this.peek ();
            }
        }
        
        public TYPE peek () {
            return stack_array[stack_array.length - 1];
        }
        
        public bool is_length (int in_length) {
            return (in_length == stack_array.length);
        }
    }
}
