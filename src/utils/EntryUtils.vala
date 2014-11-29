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
using Calculus.Core.Methods;

namespace Calculus.Utils {
    public class EntryUtils : Object {
        public Gtk.Entry entry;
        
        public EntryUtils (Gtk.Entry input_entry) {
            entry = input_entry;
        }
        
        public void addToEntry (string input) {
            entry.set_text (entry.get_text() + input);
        }
        
        public void backEntry () {
            string str = entry.get_text ();
                
            if (str.length != 0)
                str = str.slice (0, (str.length - 1));
                
            entry.set_text (str);
        }
        
        public void delEntry () {
            entry.set_text ("");
        }
        
        public void calcEntry () {
            if (entry.get_text () != "") {
                string text = entry.get_text ();
                TokenQueue tq = new TokenQueue (text);
                for (int i = 0; i <= tq.get_max_pos (); i++) 
                    stdout.printf (tq.get_token (i).get_content () + " | " + tq.get_token (i).get_token_type ().to_string () + "\n");
                stdout.printf ("\n");
                List<Token> token_list = Methods.shunting_yard (tq);
                foreach (Token t  in token_list)
                    stdout.printf (t.get_content () + " | " + t.get_token_type ().to_string () + "\n");
                stdout.printf ("\n");
                double out_d = Methods.eval_postfix (token_list);
                //stdout.printf (out_d.to_string () + "\n");
                entry.set_text (out_d.to_string ());
            }
        }
    }
}
