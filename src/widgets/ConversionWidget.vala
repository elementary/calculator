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
using Granite.Widgets;

namespace Calculus.Widgets {
    public class ConversionWidget : Gtk.Grid {
        public Gtk.Entry main_entry;
        
        public ConversionWidget () {
            this.expand = true;
            this.orientation = Gtk.Orientation.VERTICAL;
            this.set_column_spacing (2);
            this.set_row_spacing (2);
            this.margin = 10;
            
            main_entry = new Gtk.Entry ();
            main_entry.set_size_request (250, 40);
            
            var button_back = new Gtk.Button.with_label ("back");
            button_back.set_size_request(100, 40);
            
            this.attach (main_entry, 0, 0, 3, 1);
            this.attach (button_back, 4, 0, 1, 1);
            
            this.show_all ();
        }
    }

}
