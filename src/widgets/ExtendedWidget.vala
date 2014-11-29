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
using Calculus.Core.Methods;

namespace Calculus.Widgets {
    public class ExtendedWidget : Gtk.Grid {
        public Gtk.Entry main_entry;
        
        public ExtendedWidget () {
            this.expand = true;
            this.orientation = Gtk.Orientation.VERTICAL;
            this.set_column_spacing (2);
            this.set_row_spacing (2);
            this.margin = 10;
        }
    
    }
}
