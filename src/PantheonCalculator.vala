/*-
 * Copyright (c) 2018 elementary LLC. (https://elementary.io)
 *               2014 Marvin Beckers <beckersmarvin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Marvin Beckers <beckersmarvin@gmail.com>
 */

namespace PantheonCalculator {
    PantheonCalculator.MainWindow window = null;

    public class PantheonCalculatorApp : Gtk.Application {
        construct {
            application_id = "io.elementary.calculator";
            flags = ApplicationFlags.FLAGS_NONE;

            Intl.setlocale (LocaleCategory.ALL, "");
            GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
            GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
            GLib.Intl.textdomain (GETTEXT_PACKAGE);

            var quit_action = new SimpleAction ("quit", null);
            var undo_action = new SimpleAction ("undo", null);

            add_action (quit_action);
            add_action (undo_action);

            set_accels_for_action ("app.quit", {"<Control>q"});
            set_accels_for_action ("app.undo", {"<Control>z"});

            quit_action.activate.connect (() => {
                if (window != null) {
                    window.destroy ();
                }
            });

            undo_action.activate.connect (() => window.undo ());
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
