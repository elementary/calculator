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
using Gtk;
using Calculus.Core.CoreMethods;

namespace Calculus.Core.Utils {
    public class Entry : Object {
        private Gtk.Entry entry;
        
        public Entry (Gtk.Entry e) {
            entry = e;
        }
        
        public void add (string text) {
            entry.set_text (entry.get_text () + text);
        }
        
        public void back () {
            string str = "";
            if (entry.get_text ().length != 0)
                str = str.slice (0, (entry.get_text ().length - 1));
            entry.set_text (str);
        }
        
        public void del () {
            entry.set_text ("");
        }
        
        public void calc () {
            if (entry.get_text () != "") {
                string text = entry.get_text ();
                TokenQueue tq = new TokenQueue (text);
                List<Token> token_list = CoreMethods.shunting_yard (tq);
                double out_d = CoreMethods.eval_postfix (token_list);
                entry.set_text (out_d.to_string ());
            }
        }
    }
}
