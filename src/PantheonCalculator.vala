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
    PantheonCalculator.MainWindow window = null;

    public class PantheonCalculatorApp : Granite.Application {
        construct {
            application_id = "io.elementary.calculator";
            flags = ApplicationFlags.FLAGS_NONE;

            Intl.setlocale (LocaleCategory.ALL, "");

            program_name = _("Calculator");
            app_years = "2014-2017";
            app_icon = "accessories-calculator";

            build_data_dir = Build.DATADIR;
            build_pkg_data_dir = Build.PKGDATADIR;
            build_release_name = Build.RELEASE_NAME;
            build_version = Build.VERSION;
            build_version_info = Build.VERSION_INFO;

            app_launcher = "org.pantheon.calculator.desktop";
            
            SimpleAction quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (() => {
                if (window != null) {
                    window.save_state ();
                    window.destroy ();
                }
            });
            SimpleAction undo_action = new SimpleAction ("undo", null);
            undo_action.activate.connect (() => window.undo ());
            add_action (undo_action);
            add_action (quit_action);
            add_accelerator ("<Control>z", "app.undo", null);
            add_accelerator ("<Control>q", "app.quit", null);
        }

        public override void activate () {
            window = new PantheonCalculator.MainWindow ();
            this.add_window (window);
        }
    }

    public static int main (string[] args) {
        var application = new PantheonCalculatorApp ();
        return application.run (args);
    }
}

