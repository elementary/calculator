/* Copyright 2014 Marvin Beckers <beckersmarvin@gmail.com>
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

namespace Calculus { 
    public class CalculusApp : Granite.Application {
        /**
         * Translatable launcher (.desktop) strings to be added to template (.pot) file.
         * These strings should reflect any changes in these launcher keys in .desktop file
         */
        public const string CALCULATOR = N_("Calculator");
        public const string PROGRAM_NAME = "Calculus";

        public const string KEYWORDS = N_("GTK;Utility;Calculator;");
        public const string COMMENT = N_("Calculate in an elementary way.");
        public const string GENERIC_NAME = N_("Calculator");

        public const string ABOUT_STOCK = N_("About Calculus");
        public const string ABOUT_GENERIC = N_("About Calculator");
    
        construct {
            application_id = "org.calculus";
            flags = ApplicationFlags.FLAGS_NONE;
                    
            program_name = PROGRAM_NAME;
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
            translate_url = "https://translations.launchpad.net/calculus";       
            about_authors = { "Marvin Beckers <marvin.beckers@posteo.de>" };
            about_comments = _("A simple calc tool for elementary OS.");
            about_license_type = Gtk.License.GPL_3_0;
        }
        
        public override void activate () {
            var window = new Calculus.MainWindow ();
            this.add_window (window);
        }     
    }
    
    public static int main (string[] args) {
        var application = new CalculusApp ();
        return application.run (args);
    }
}

