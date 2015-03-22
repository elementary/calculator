/* Copyright 2014 Marvin Beckers <beckersmarvin@gmail.com>
*
* This file is part of Pantheon Calculator
*
* Pantheon Calculator is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Pantheon Calculator is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Pantheon Calculator. If not, see http://www.gnu.org/licenses/.
*/

namespace PantheonCalculator { 
    public class PantheonCalculatorApp : Granite.Application {
        /**
         * Translatable launcher (.desktop) strings to be added to template (.pot) file.
         * These strings should reflect any changes in these launcher keys in .desktop file
         */
        public const string CALCULATOR = N_("Calculator");
        public const string PROGRAM_NAME = N_("Calculator");

        public const string COMMENT = N_("Calculate in an elementary way.");
        public const string ABOUT_STOCK = N_("About Calculator");

        construct {
            application_id = "org.pantheon.calculator";
            flags = ApplicationFlags.FLAGS_NONE;

            program_name = PROGRAM_NAME;
            app_years = "2014-2015";
            app_icon = "accessories-calculator";

            build_data_dir = Build.DATADIR;
            build_pkg_data_dir = Build.PKGDATADIR;
            build_release_name = Build.RELEASE_NAME;
            build_version = Build.VERSION;
            build_version_info = Build.VERSION_INFO;

            app_launcher = "pantheon-calculator.desktop";
            main_url = "https://launchpad.net/pantheon-calculator";
            bug_url = "https://bugs.launchpad.net/pantheon-calculator";
            help_url = "https://answers.launchpad.net/pantheon-calculator"; 
            translate_url = "https://translations.launchpad.net/pantheon-calculator";
            about_authors = { "Marvin Beckers <beckersmarvin@gmail.com>" };
            about_comments = "";
            about_license_type = Gtk.License.GPL_3_0;

            Intl.setlocale (LocaleCategory.ALL, "");
        }

        public override void activate () {
            var window = new PantheonCalculator.MainWindow ();
            this.add_window (window);
        }
    }

    public static int main (string[] args) {
        var application = new PantheonCalculatorApp ();
        return application.run (args);
    }
}

