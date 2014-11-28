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

using Calculus.Widgets;

namespace Calculus {
    public class CalculusApp : Granite.Application {
        public Toolbar toolbar; 
        private WidgetStack stack;
    
        construct {
            application_id = "org.Calculus";
            flags = ApplicationFlags.FLAGS_NONE;
                    
            program_name = "Calculus";
            app_years = "2014";
                
            build_version = "0.1";
            app_icon = "accessories-calculator";
                    
            about_authors = { "Marvin Beckers <marvin.beckers@posteo.de>" };
            about_comments = "a simple calc tool for elementary OS";
            about_license_type = Gtk.License.GPL_3_0;
            
        }
        
        public override void activate () {
            var window = new Gtk.Window ();
            window.title = "Calculus";
            window.window_position = Gtk.WindowPosition.CENTER;
            
            this.add_window (window);
            
            // Main stack widget structure
            stack = new WidgetStack ();

            var toolbar = new Toolbar (this, stack);
            
            window.set_titlebar (toolbar);       
            window.add (stack);
            window.set_resizable (false);
            window.show_all ();
        
        }     
    }
    
    public static int main (string[] args) {
        var application = new CalculusApp ();
        return application.run (args);
    }
}

