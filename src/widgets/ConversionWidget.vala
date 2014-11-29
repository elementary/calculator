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
using Calculus.Core;

namespace Calculus.Widgets {
    public class ConversionWidget : Gtk.Grid {
        public Gtk.Entry main_entry;
        private Core.Utils.Entry utils;
        
        public ConversionWidget () {
            this.expand = true;
            this.orientation = Gtk.Orientation.VERTICAL;
            this.set_column_spacing (2);
            this.set_row_spacing (2);
            this.margin = 10;
            
            main_entry = new Gtk.Entry ();
            main_entry.set_size_request (250, 40);
            
            utils = new Core.Utils.Entry (main_entry);
            
            var button_back = new Gtk.Button.from_icon_name ("go-previous", Gtk.IconSize.SMALL_TOOLBAR);
            button_back.set_size_request(50, 40);
            var button_del = new Gtk.Button.from_icon_name ("dialog-close", Gtk.IconSize.SMALL_TOOLBAR);
            button_del.set_size_request(50, 40);
            
            var button_0 = new Gtk.Button.with_label ("0");
            var button_point = new Gtk.Button.with_label (".");
            var button_percent = new Gtk.Button.with_label ("%");
            
            var button_1 = new Gtk.Button.with_label ("1");
            var button_2 = new Gtk.Button.with_label ("2");
            var button_3 = new Gtk.Button.with_label ("3");
            
            var button_4 = new Gtk.Button.with_label ("4");
            var button_5 = new Gtk.Button.with_label ("5");
            var button_6 = new Gtk.Button.with_label ("6");
            
            var button_7 = new Gtk.Button.with_label ("7");
            var button_8 = new Gtk.Button.with_label ("8");
            var button_9 = new Gtk.Button.with_label ("9");
            
            button_0.set_size_request(0, 50);
            button_1.set_size_request(0, 50);
            button_4.set_size_request(0, 50);
            button_7.set_size_request(0, 50);
            
            //attach all buttons
            this.attach (button_7, 0, 1, 1, 1);
            this.attach (button_8, 1, 1, 1, 1);
            this.attach (button_9, 2, 1, 1, 1);
            
            this.attach (button_4, 0, 2, 1, 1);
            this.attach (button_5, 1, 2, 1, 1);
            this.attach (button_6, 2, 2, 1, 1);
            
            this.attach (button_1, 0, 3, 1, 1);
            this.attach (button_2, 1, 3, 1, 1);
            this.attach (button_3, 2, 3, 1, 1);
            
            this.attach (button_0, 0, 4, 1, 1);
            this.attach (button_point, 1, 4, 1, 1);
            this.attach (button_percent, 2, 4, 1, 1);
            
            this.attach (main_entry, 0, 0, 3, 1);
            this.attach (button_back, 4, 0, 1, 1);
            this.attach (button_del, 5, 0, 1, 1);
            
            this.show_all ();
        }
    }

}
