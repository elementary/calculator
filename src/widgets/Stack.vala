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
    public class Stack : Gtk.Stack {
        public Calculus.Widgets.StandardWidget standard;
        public Calculus.Widgets.ConversionWidget conversion;
        
        public Stack () {
            standard = new Calculus.Widgets.StandardWidget ();
            conversion = new Calculus.Widgets.ConversionWidget ();
            
            this.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
            this.set_transition_duration (150);
            
            this.add_named (standard, "Standard");
            this.add_named (conversion, "Conversion");
            this.set_visible_child_name ("Standard");
        
            this.show_all ();
        }
    }
}

