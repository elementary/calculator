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
using Calculus.Widgets;

namespace Calculus.Widgets {
    public class Toolbar : Gtk.HeaderBar {
        private Gtk.Menu menu;
        private AppMenu app_menu;
        private Gtk.ComboBoxText combobox;
        
        public Toolbar (Granite.Application app, WidgetStack stack) {
            // Toolbar properties
            // compliant with elementary HIG
            get_style_context ().add_class ("primary-toolbar");
            this.show_close_button = true;
            //this.title = "GraniteCalc";
            
            menu = new Gtk.Menu ();
            Gtk.MenuItem item_settings = new Gtk.MenuItem.with_label (_("Settings"));
            menu.add (item_settings);
            app_menu = app.create_appmenu (this.menu);
            this.pack_end (app_menu);
            
            combobox = new Gtk.ComboBoxText ();
            combobox.append_text (_("Standard"));
		    //combobox.append_text ("Extended");
		    //combobox.append_text ("Conversion");
		    //combobox.append_text ("Fiscal");
		    //combobox.append_text ("Computer Science");
		    combobox.active = 0;

            this.pack_end (combobox);
            
            combobox.changed.connect (() => {
		        var combobox_value = combobox.get_active_text ();
		        stack.set_visible_child_name (combobox_value);
		    });
            
            show_all ();
        }
   }
}
