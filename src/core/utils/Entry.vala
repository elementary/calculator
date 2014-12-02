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
using Calculus.Core;

namespace Calculus.Core.Utils {
    public class Entry : Object {
        private Gtk.Entry entry;
        private Parser parser;
        
        public Entry (Gtk.Entry e) {
            entry = e;
            parser = new Parser ();
        }
        
        public void add (string text) {
            entry.set_text (entry.get_text () + text);
        }
        
        public void back () {
            entry.backspace ();
        }
        
        public void del () {
            entry.set_text ("");
        }
        
        public void calc () {
            if (entry.get_text () != "") {
                double d = 0;
                try {
                    d = parser.parse (entry.get_text ());
                } catch (PARSER_ERROR e) { stdout.printf (e.message + " \n"); }

                entry.set_text (d.to_string ());
            }
        }
    }
}
