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
    const string GETTEXT_PACKAGE = "calculus"; 
    
    public class CalculusApp : Granite.Application {
        public Toolbar toolbar; 
        private WidgetStack stack;
    
        construct {
            application_id = "org.calculus";
            flags = ApplicationFlags.FLAGS_NONE;
                    
            program_name = _("Calculator");
            app_years = "2014";
            app_icon = "accessories-calculator";
            
            build_data_dir = Build.DATADIR;
            build_pkg_data_dir = Build.PKGDATADIR;
            build_release_name = Build.RELEASE_NAME;
            build_version = Build.VERSION;
            build_version_info = Build.VERSION_INFO;
            
            app_launcher = "calculus.desktop";
            application_id = "net.launchpad.calculus";
            main_url = "https://launchpad.net/calculus";
            bug_url = "https://bugs.launchpad.net/calculus";
            help_url = "https://answers.launchpad.net/calculus";        
            about_authors = { "Marvin Beckers <marvin.beckers@posteo.de>" };
            about_comments = _("A simple calc tool for elementary OS.");
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
        Intl.setlocale(LocaleCategory.MESSAGES, "");
        Intl.textdomain(GETTEXT_PACKAGE); 
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "utf-8"); 
        Intl.bindtextdomain(GETTEXT_PACKAGE, "./po"); 
        
        var application = new CalculusApp ();
        return application.run (args);
    }
}

