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
    public class MainWindow : Gtk.Window {
        private Settings settings;

        private Gtk.HeaderBar headerbar;
        private Gtk.Grid main_grid;
        private Gtk.Revealer extended_revealer;
        private Gtk.Entry entry;

        /* Widgets I need to access */
        private Gtk.Image extended_img_1;
        private Gtk.Image extended_img_2;
        private Gtk.Button button_calc;
        private Gtk.Button button_history;
        private Gtk.Button button_ans;
        private Gtk.Button button_del;
        private Gtk.Button button_clr;
        private Gtk.ToggleButton button_extended;
        private HistoryDialog history_dialog;

        private Gtk.InfoBar infobar;
        private Gtk.Label infobar_label;

        private Gtk.Grid global_grid;

        private List<History?> history;
        private int position;

        /* Define the decimal places */
        private int decimal_places;

        public struct History { string exp; string output; }

        public MainWindow () {
            get_style_context ().add_class ("rounded");
            set_resizable (false);
            window_position = Gtk.WindowPosition.CENTER;

            settings = new Settings ("io.elementary.calculator.saved-state");
            decimal_places = settings.get_int ("decimal-places");

            history = new List<History?> ();
            position = 0;

            int x = settings.get_int ("window-x");
            int y = settings.get_int ("window-y");
            if (x != -100 && y != -100) {
                move (x, y);
            }

            build_titlebar ();
            build_ui ();

            this.key_press_event.connect (key_pressed);

            delete_event.connect ((event) => {
                save_state ();
                return false;
            });
        }

        public void undo () {
            unowned List<History?> previous_entry = history.last ();
            if (previous_entry != null) {
                entry.set_text (previous_entry.data.exp);
                history.remove_link (previous_entry);
            }
        }

        private void build_titlebar () {
            headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.show_close_button = true;
            headerbar.set_title (_("Calculator"));
            set_titlebar (headerbar);

            extended_img_1 = new Gtk.Image.from_icon_name ("pane-hide-symbolic", Gtk.IconSize.MENU);
            extended_img_2 = new Gtk.Image.from_icon_name ("pane-show-symbolic", Gtk.IconSize.MENU);

            button_extended = new Gtk.ToggleButton ();
            button_extended.image = extended_img_1;
            button_extended.tooltip_text = _("Show extended functionality");
            button_extended.toggled.connect (toggle_grid);

            button_history = new Gtk.Button ();
            button_history.image = new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.MENU);
            button_history.tooltip_text = _("History");
            button_history.sensitive = false;
            button_history.clicked.connect (show_history);

            headerbar.pack_end (button_extended);
            headerbar.pack_end (button_history);
        }

        private void build_ui () {
            main_grid = new Gtk.Grid ();
            main_grid.margin = 6;

            build_basic_ui ();
            build_extended_ui ();
            button_extended.active = settings.get_boolean ("extended-shown");

            infobar = new Gtk.InfoBar ();
            infobar_label = new Gtk.Label ("");
            infobar.get_content_area ().add (infobar_label);
            infobar.show_close_button = false;
            infobar.message_type = Gtk.MessageType.WARNING;
            infobar.no_show_all = true;

            global_grid = new Gtk.Grid ();
            global_grid.orientation = Gtk.Orientation.VERTICAL;
            global_grid.add (infobar);
            global_grid.add (main_grid);

            add (global_grid);
            show_all ();
        }

        private void build_basic_ui () {
            entry = new Gtk.Entry ();
            entry.set_alignment (1);
            entry.set_text (settings.get_string ("entry-content"));
            entry.get_style_context ().add_class ("h2");
            entry.vexpand = true;
            entry.valign = Gtk.Align.CENTER;

            button_calc = new Button ("=", _("Calculate Result"));
            button_calc.get_style_context ().add_class ("h2");
            button_calc.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_ans = new Button ("ANS", _("Add last result"));
            button_ans.sensitive = false;
            button_del = new Button ("Del", _("Backspace"));
            button_clr = new Button ("C", _("Clear entry"));
            button_clr.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            var button_add = new Button (" + ", _("Add"));
            button_add.function = "+";
            button_add.get_style_context ().add_class ("h3");
            var button_sub = new Button (" − ", _("Subtract"));
            button_sub.function = "−";
            button_sub.get_style_context ().add_class ("h3");
            var button_mult = new Button (" × ", _("Multiply"));
            button_mult.function = "×";
            button_mult.get_style_context ().add_class ("h3");
            var button_div = new Button (" ÷ ", _("Divide"));
            button_div.function = "÷";
            button_div.get_style_context ().add_class ("h3");

            var button_0 = new Button ("0");
            var button_point = new Button (Posix.nl_langinfo (Posix.NLItem.RADIXCHAR));
            var button_percent = new Button ("%", _("Percentage"));
            var button_1 = new Button ("1");
            var button_2 = new Button ("2");
            var button_3 = new Button ("3");

            var button_4 = new Button ("4");
            var button_5 = new Button ("5");
            var button_6 = new Button ("6");

            var button_7 = new Button ("7");
            var button_8 = new Button ("8");
            var button_9 = new Button ("9");

            var basic_grid = new Gtk.Grid ();
            basic_grid.column_spacing = 6;
            basic_grid.row_spacing = 6;
            basic_grid.valign = Gtk.Align.FILL;
            basic_grid.set_row_homogeneous (true);

            basic_grid.attach (entry, 0, 0, 4, 1);
            basic_grid.attach (button_clr, 0, 1, 1, 1);
            basic_grid.attach (button_del, 1, 1, 1, 1);
            basic_grid.attach (button_percent, 2, 1, 1, 1);
            basic_grid.attach (button_div, 3, 1, 1, 1);

            basic_grid.attach (button_7, 0, 2, 1, 1);
            basic_grid.attach (button_8, 1, 2, 1, 1);
            basic_grid.attach (button_9, 2, 2, 1, 1);
            basic_grid.attach (button_mult, 3, 2, 1, 1);

            basic_grid.attach (button_4, 0, 3, 1, 1);
            basic_grid.attach (button_5, 1, 3, 1, 1);
            basic_grid.attach (button_6, 2, 3, 1, 1);
            basic_grid.attach (button_sub, 3, 3, 1, 1);

            basic_grid.attach (button_1, 0, 4, 1, 1);
            basic_grid.attach (button_2, 1, 4, 1, 1);
            basic_grid.attach (button_3, 2, 4, 1, 1);
            basic_grid.attach (button_add, 3, 4, 1, 1);

            basic_grid.attach (button_0, 0, 5, 1, 1);
            basic_grid.attach (button_point, 1, 5, 1, 1);
            basic_grid.attach (button_ans, 2, 5, 1, 1);
            basic_grid.attach (button_calc, 3, 5, 1, 1);

            main_grid.add (basic_grid);

            entry.changed.connect (remove_error);
            entry.activate.connect (button_calc_clicked);

            button_calc.clicked.connect (() => {button_calc_clicked ();});
            button_del.clicked.connect (() => {button_del_clicked ();});
            button_clr.clicked.connect (() => {button_clr_clicked ();});
            button_ans.clicked.connect (() => {button_ans_clicked ();});
            button_add.clicked.connect (() => {regular_button_clicked (button_add.function);});
            button_sub.clicked.connect (() => {regular_button_clicked (button_sub.function);});
            button_mult.clicked.connect (() => {regular_button_clicked (button_mult.function);});
            button_div.clicked.connect (() => {regular_button_clicked (button_div.function);});
            button_0.clicked.connect (() => {regular_button_clicked (button_0.function);});
            button_1.clicked.connect (() => {regular_button_clicked (button_1.function);});
            button_2.clicked.connect (() => {regular_button_clicked (button_2.function);});
            button_3.clicked.connect (() => {regular_button_clicked (button_3.function);});
            button_4.clicked.connect (() => {regular_button_clicked (button_4.function);});
            button_5.clicked.connect (() => {regular_button_clicked (button_5.function);});
            button_6.clicked.connect (() => {regular_button_clicked (button_6.function);});
            button_7.clicked.connect (() => {regular_button_clicked (button_7.function);});
            button_8.clicked.connect (() => {regular_button_clicked (button_8.function);});
            button_9.clicked.connect (() => {regular_button_clicked (button_9.function);});
            button_point.clicked.connect (() => {regular_button_clicked (button_point.function);});
            button_percent.clicked.connect (() => {regular_button_clicked (button_percent.function);});
        }

        private void build_extended_ui () {
            var button_par_left = new Button ("(", _("Start Group"));
            var button_par_right = new Button (")", _("End Group"));
            var button_pow = new Button ("x<sup>y</sup>", _("Exponent"));
            button_pow.function = "^";
            var button_sr = new Button ("√", _("Root"));
            var button_sin = new Button ("sin", _("Sine"));
            var button_sinh = new Button ("sinh", _("Hyperbolic Sine"));
            var button_cos = new Button ("cos", _("Cosine"));
            var button_cosh = new Button ("cosh", _("Hyperbolic Cosine"));
            var button_tan = new Button ("tan", _("Tangent"));
            var button_tanh = new Button ("tanh", _("Hyperbolic Tangent"));
            var button_pi = new Button ("π", _("Pi"));
            var button_e = new Button ("e", _("Euler's Number"));

            var extended_grid = new Gtk.Grid ();
            extended_grid.margin_start = 6;
            extended_grid.column_spacing = 6;
            extended_grid.row_spacing = 6;
            extended_grid.valign = Gtk.Align.END;
            extended_grid.attach (button_par_left, 0, 0, 1, 1);
            extended_grid.attach (button_par_right, 1, 0, 1, 1);
            extended_grid.attach (button_pow, 0, 1, 1, 1);
            extended_grid.attach (button_sr, 1, 1, 1, 1);
            extended_grid.attach (button_sin, 0, 2, 1, 1);
            extended_grid.attach (button_sinh, 1, 2, 1, 1);
            extended_grid.attach (button_cos, 0, 3, 1, 1);
            extended_grid.attach (button_cosh, 1, 3, 1, 1);
            extended_grid.attach (button_tan, 0, 4, 1, 1);
            extended_grid.attach (button_tanh, 1, 4, 1, 1);
            extended_grid.attach (button_pi, 0, 5, 1, 1);
            extended_grid.attach (button_e, 1, 5, 1, 1);

            extended_revealer = new Gtk.Revealer ();
            extended_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);
            extended_revealer.show_all ();
            extended_revealer.add (extended_grid);
            main_grid.add (extended_revealer);

            button_pi.clicked.connect (() => {regular_button_clicked (button_pi.function);});
            button_e.clicked.connect (() => {regular_button_clicked (button_e.function);});
            button_pow.clicked.connect (() => {regular_button_clicked (button_pow.function);});
            button_par_left.clicked.connect (() => {regular_button_clicked (button_par_left.function);});
            button_par_right.clicked.connect (() => {regular_button_clicked (button_par_right.function);});
            button_sr.clicked.connect (() => {function_button_clicked (button_sr.function);});
            button_sin.clicked.connect (() => {function_button_clicked (button_sin.function);});
            button_sinh.clicked.connect (() => {function_button_clicked (button_sinh.function);});
            button_cos.clicked.connect (() => {function_button_clicked (button_cos.function);});
            button_cosh.clicked.connect (() => {function_button_clicked (button_cosh.function);});
            button_tan.clicked.connect (() => {function_button_clicked (button_tan.function);});
            button_tanh.clicked.connect (() => {function_button_clicked (button_tanh.function);});
        }

        private void regular_button_clicked (string label) {
            int new_position = entry.get_position ();
            entry.insert_at_cursor (label);
            new_position += label.length;
            entry.grab_focus ();
            entry.set_position (new_position);
        }

        private void function_button_clicked (string label) {
            int selection_start = -1;
            int selection_end = -1;
            int new_position = entry.get_position ();
            if (entry.get_selection_bounds (out selection_start, out selection_end)) {
                string selected_text = entry.get_chars (selection_start, selection_end);
                string function_call = label + "(" + selected_text + ")";
                entry.delete_text (selection_start, selection_end);
                entry.insert_text (function_call, -1, ref selection_start);
                new_position += function_call.length;
                entry.grab_focus ();
                entry.set_position (new_position);
            } else {
                regular_button_clicked (label);
            }
        }

        private void button_calc_clicked () {
            position = entry.get_position ();
            if (entry.get_text () != "") {
                var eval = new Core.Evaluation ();

                try {
                    var output = eval.evaluate (entry.get_text (), decimal_places);
                    if (entry.get_text () != output) {
                        History history_entry = History () { exp = entry.get_text (), output = output };
                        history.append (history_entry);
                        update_history_dialog (history_entry);
                        entry.set_text (output);
                        button_history.set_sensitive (true);
                        button_ans.set_sensitive (true);

                        position = output.length;
                        remove_error ();
                    }
                } catch (Core.OUT_ERROR e) {
                    infobar_label.label = e.message;
                    infobar.no_show_all = false;
                    infobar.show_all ();
                    infobar.no_show_all = true;
                }
            } else {
                remove_error ();
            }

            entry.grab_focus ();
            entry.set_position (position);
        }

        private void button_del_clicked () {
            position = entry.get_position ();
            if (entry.get_text ().length > 0) {
                string new_text = "";
                int index = 0;
                unowned unichar c;
                List<unichar> news = new List<unichar> ();

                for (int i = 0; entry.get_text ().get_next_char (ref index, out c); i++) {
                    if (i + 1 != position) {
                        news.append (c);
                    }
                }

                foreach (unichar u in news) {
                    new_text += u.to_string ();
                }

                entry.set_text (new_text);
            }

            entry.grab_focus ();
            entry.set_position (position - 1);
        }

        private void button_clr_clicked () {
            position = 0;
            entry.set_text ("");
            set_focus (entry);
            remove_error ();

            entry.grab_focus ();
            entry.set_position (position);
        }

        private void button_ans_clicked () {
            position = entry.get_position ();
            if ((int) history.length () > 0) {
                unowned List<History?> last = history.last ();
                history_added (last.data.output.to_string ());
            }
        }

        private void toggle_grid (Gtk.ToggleButton button) {
            position = entry.get_position ();
            if (button.get_active ()) {
                /* Show extended functionality */
                button.image = extended_img_2;
                button.tooltip_text = _("Hide extended functionality");
                extended_revealer.set_reveal_child (true);
            } else {
                /* Hide extended functionality */
                button.image = extended_img_1;
                button.tooltip_text = _("Show extended functionality");
                extended_revealer.set_reveal_child (false);
            }
            /* Focusing button_calc because without a new focus it will cause weird window drawing problems. */
            entry.grab_focus ();
            entry.set_position (position);
        }

        private void show_history (Gtk.Button button) {
            position = entry.get_position ();
            button_history.sensitive = false;

            history_dialog = new HistoryDialog (history);
            history_dialog.added.connect (history_added);
            history_dialog.hide.connect (() => button_history.set_sensitive (true));
        }

        private void update_history_dialog (History entry) {
            if (history_dialog != null) {
                history_dialog.append (entry);
            }
        }

        private void history_added (string input) {
            entry.insert_at_cursor (input);
            position += input.length;
            entry.grab_focus ();
            entry.set_position (position);
        }

        private void remove_error () {
            infobar.hide ();
        }

        private bool key_pressed (Gdk.EventKey key) {
            bool retval = false;
            switch (key.keyval) {
                case Gdk.Key.Escape:
                    button_clr_clicked ();
                    break;
                case Gdk.Key.KP_Decimal:
                case Gdk.Key.KP_Separator:
                case Gdk.Key.decimalpoint:
                case Gdk.Key.period:
                case Gdk.Key.comma:
                    decimal () ;
                    key.keyval = Gdk.Key.Right;
                    break;
                case Gdk.Key.KP_Divide:
                case Gdk.Key.slash:
                    key.keyval = Gdk.Key.division;
                    break;
                case Gdk.Key.KP_Multiply:
                case Gdk.Key.asterisk:
                    key.keyval = Gdk.Key.multiply;
                    break;
                case Gdk.Key.KP_Subtract:
                case Gdk.Key.minus:
                    regular_button_clicked ("−");
                    retval = true;
                    break;
            }
            return retval;
        }

        public void save_state () {
            int x_pos, y_pos;
            get_position (out x_pos, out y_pos);
            settings.set_int ("window-x", x_pos);
            settings.set_int ("window-y", y_pos);

            settings.set_boolean ("extended-shown", button_extended.active);
            settings.set_string ("entry-content", entry.text);
        }

        public void decimal () {
            var new_decimal = Posix.nl_langinfo (Posix.NLItem.RADIXCHAR); 
            entry.insert_at_cursor (new_decimal);
        }
    }
}
