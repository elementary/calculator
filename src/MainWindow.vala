/*-
 * Copyright 2018-2022 elementary, Inc. (https://elementary.io)
 *           2014 Marvin Beckers <beckersmarvin@gmail.com>
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

public class PantheonCalculator.MainWindow : Gtk.ApplicationWindow {
    private static GLib.Settings settings;

    private Gtk.Revealer extended_revealer;
    private Gtk.Entry entry;
    private Gtk.Button button_calc;
    private Gtk.Button button_history;
    private Gtk.Button button_ans;
    private Gtk.Button button_del;
    private Gtk.Button button_mr;
    private Gtk.Button button_mc;
    private Gtk.Button button_gt;
    private Gtk.ToggleButton button_extended;
    private HistorySidebar history_sidebar;
    private Adw.OverlaySplitView overlay_split_view;

    private Gtk.InfoBar infobar;
    private Gtk.Label infobar_label;

    private Core.Evaluation eval;

    private List<History?> history;
    private int position;

    /* Define the decimal places */
    private int decimal_places;

    private double memory_value = 0;

    private const string ACTION_PREFIX = "win.";
    private const string ACTION_CLEAR = "action-clear";
    private const string ACTION_INSERT = "action-insert";
    private const string ACTION_FUNCTION = "action-function";
    private const string ACTION_UNDO = "action-undo";
    private const string ACTION_COPY = "action-copy";
    private const string ACTION_PASTE = "action-paste";

    private const ActionEntry[] ACTION_ENTRIES = {
        { ACTION_INSERT, action_insert, "s"},
        { ACTION_FUNCTION, action_function, "s"},
        { ACTION_CLEAR, action_clear },
        { ACTION_UNDO, undo },
        { ACTION_COPY, copy },
        { ACTION_PASTE, paste }
    };

    static construct {
        settings = new Settings ("io.elementary.calculator.saved-state");
    }

    public MainWindow (Gtk.Application application) {
        Object (application: application);
    }

    construct {
        add_action_entries (ACTION_ENTRIES, this);

        var application_instance = (Gtk.Application) GLib.Application.get_default ();
        application_instance.set_accels_for_action (ACTION_PREFIX + ACTION_CLEAR, {"Escape"});
        application_instance.set_accels_for_action (ACTION_PREFIX + ACTION_UNDO, {"<Control>z"});
        application_instance.set_accels_for_action (ACTION_PREFIX + ACTION_COPY, {"<Control>c"});
        application_instance.set_accels_for_action (ACTION_PREFIX + ACTION_PASTE, {"<Control>v"});

        resizable = false;
        title = _("Calculator");

        decimal_places = settings.get_int ("decimal-places");

        eval = new Core.Evaluation ();

        history = new List<History?> ();
        position = 0;
        button_extended = new Gtk.ToggleButton () {
            icon_name = "pane-hide-symbolic",
            tooltip_text = _("Show extended functionality")
        };
        button_extended.toggled.connect (toggle_grid);

        button_history = new Gtk.Button () {
            icon_name = "document-open-recent-symbolic",
            tooltip_text = _("History"),
            sensitive = false
        };
        button_history.clicked.connect (show_history);

        var headerbar = new Gtk.HeaderBar () {
            show_title_buttons = true,
            title_widget = new Gtk.Label (null)
        };
        headerbar.pack_start (button_history);
        headerbar.pack_end (button_extended);
        headerbar.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        entry = new Gtk.Entry () {
            xalign = 1,
            vexpand = true,
            valign = Gtk.Align.FILL
        };
        entry.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        button_calc = new Button ("=") {
            tooltip_text = _("Calculate Result")
        };
        button_calc.add_css_class (Granite.STYLE_CLASS_H2_LABEL);
        button_calc.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        button_ans = new Button ("ANS") {
            sensitive = false,
            tooltip_text = _("Insert last result")
        };

        button_del = new Button ("Del") {
            tooltip_text = _("Backspace")
        };

        var button_clr = new Button ("C") {
            action_name = ACTION_PREFIX + ACTION_CLEAR
        };
        button_clr.tooltip_markup = Granite.markup_accel_tooltip (
            application_instance.get_accels_for_action (button_clr.action_name),
            _("Clear entry")
        );
        button_clr.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

        var button_add = new Button (" + ") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("+"),
            tooltip_text = _("Add")
        };
        button_add.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var button_sub = new Button (" − ") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("-"),
            tooltip_text = _("Subtract")
        };
        button_sub.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var button_mult = new Button (" × ") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("×"),
            tooltip_text = _("Multiply")
        };
        button_mult.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var button_div = new Button (" ÷ ") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("÷"),
            tooltip_text = _("Divide")
        };
        button_div.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var button_0 = new Button ("0") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("0")
        };

        var button_point = new Button (Posix.nl_langinfo (Posix.NLItem.RADIXCHAR)) {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string (Posix.nl_langinfo (Posix.NLItem.RADIXCHAR))
        };

        var button_percent = new Button ("%") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("%"),
            tooltip_text = _("Percentage")
        };

        var button_1 = new Button ("1") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("1")
        };

        var button_2 = new Button ("2") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("2")
        };

        var button_3 = new Button ("3") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("3")
        };

        var button_4 = new Button ("4") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("4")
        };

        var button_5 = new Button ("5") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("5")
        };

        var button_6 = new Button ("6") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("6")
        };

        var button_7 = new Button ("7") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("7")
        };

        var button_8 = new Button ("8") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("8")
        };

        var button_9 = new Button ("9") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("9")
        };

        var basic_grid = new Gtk.Grid () {
            column_spacing = 6,
            row_spacing = 6,
            row_spacing = 6,
            row_homogeneous = true
        };

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

        var button_ms = new Button ("MS") {
            tooltip_text = _("Set memory value")
        };

        button_mr = new Button ("MR") {
            sensitive = false,
            tooltip_text = _("Recall value from memory")
        };

        var button_m_add = new Button ("M+") {
            tooltip_text = _("Add to stored value")
        };

        var button_m_sub = new Button ("M−") {
            tooltip_text = _("Subtract from stored value")
        };

        button_mc = new Button ("MC") {
            sensitive = false,
            tooltip_text = _("Clear memory")
        };

        button_gt = new Button ("GT") {
            sensitive = false,
            tooltip_text = _("Grand Total")
        };

        var button_par_left = new Button ("(") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("("),
            tooltip_text = _("Start Group")
        };

        var button_par_right = new Button (")") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string (")"),
            tooltip_text = _("End Group")
        };

        var button_pow = new Button ("x<sup>y</sup>") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("^"),
            tooltip_text = _("Exponent")
        };

        var button_sr = new Button ("√") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("√"),
            tooltip_text = _("Root")
        };

        var button_sin = new Button ("sin") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("sin"),
            tooltip_text = _("Sine")
        };

        var button_sinh = new Button ("sinh") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("sinh"),
            tooltip_text = _("Hyperbolic Sine")
        };

        var button_cos = new Button ("cos") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("cos"),
            tooltip_text = _("Cosine")
        };

        var button_cosh = new Button ("cosh") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("cosh"),
            tooltip_text = _("Hyperbolic Cosine")
        };

        var button_tan = new Button ("tan") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("tan"),
            tooltip_text = _("Tangent")
        };

        var button_tanh = new Button ("tanh") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("tanh"),
            tooltip_text = _("Hyperbolic Tangent")
        };

        var button_pi = new Button ("π") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("π"),
            tooltip_text = _("Pi")
        };

        var button_e = new Button ("e") {
            action_name = ACTION_PREFIX + ACTION_INSERT,
            action_target = new Variant.string ("e"),
            tooltip_text = _("Euler's Number")
        };

        var button_log = new Button ("log<sub>10</sub>") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("log"),
            tooltip_text = _("Logarithm Base 10")
        };

        var button_ln = new Button ("ln") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("ln"),
            tooltip_text = _("Natural Logarithm")
        };

        var button_asin = new Button ("sin<sup>-1</sup>") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("asin"),
            tooltip_text = _("Inverse Sine")
        };

        var button_acos = new Button ("cos<sup>-1</sup>") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("acos"),
            tooltip_text = _("Inverse Cosine")
        };

        var button_atan = new Button ("tan<sup>-1</sup>") {
            action_name = ACTION_PREFIX + ACTION_FUNCTION,
            action_target = new Variant.string ("atan"),
            tooltip_text = _("Inverse Tangent")
        };

        var button_reciprocal = new Button ("x<sup>-1</sup>") {
            tooltip_text = _("Reciprocal")
        };

        var extended_grid = new Gtk.Grid () {
            margin_start = 6,
            column_spacing = 6,
            row_spacing = 6,
            valign = Gtk.Align.FILL,
            row_homogeneous = true
        };

        // First row
        extended_grid.attach (button_ms, 0, 0, 1, 1);
        extended_grid.attach (button_par_left, 1, 0, 1, 1);
        extended_grid.attach (button_par_right, 2, 0, 1, 1);
        extended_grid.attach (button_log, 3, 0, 1, 1);
        // Second row
        extended_grid.attach (button_mr, 0, 1, 1, 1);
        extended_grid.attach (button_pow, 1, 1, 1, 1);
        extended_grid.attach (button_sr, 2, 1, 1, 1);
        extended_grid.attach (button_ln, 3, 1, 1, 1);
        // Third row
        extended_grid.attach (button_m_add, 0, 2, 1, 1);
        extended_grid.attach (button_sin, 1, 2, 1, 1);
        extended_grid.attach (button_sinh, 2, 2, 1, 1);
        extended_grid.attach (button_asin, 3, 2, 1, 1);
        // Fourth row
        extended_grid.attach (button_m_sub, 0, 3, 1, 1);
        extended_grid.attach (button_cos, 1, 3, 1, 1);
        extended_grid.attach (button_cosh, 2, 3, 1, 1);
        extended_grid.attach (button_acos, 3, 3, 1, 1);
        // Fifth row
        extended_grid.attach (button_mc, 0, 4, 1, 1);
        extended_grid.attach (button_tan, 1, 4, 1, 1);
        extended_grid.attach (button_tanh, 2, 4, 1, 1);
        extended_grid.attach (button_atan, 3, 4, 1, 1);
        // Sixth row
        extended_grid.attach (button_gt, 0, 5, 1, 1);
        extended_grid.attach (button_pi, 1, 5, 1, 1);
        extended_grid.attach (button_e, 2, 5, 1, 1);
        extended_grid.attach (button_reciprocal, 3, 5, 1, 1);

        extended_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
            child = extended_grid
        };

        var main_grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6,
            margin_top = 6
        };
        main_grid.append (basic_grid);
        main_grid.append (extended_revealer);

        infobar_label = new Gtk.Label ("");

        infobar = new Gtk.InfoBar () {
            message_type = Gtk.MessageType.WARNING,
            revealed = false,
            show_close_button = false
        };
        infobar.add_child (infobar_label);

        var global_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        global_box.append (infobar);
        global_box.append (main_grid);

        var toolbar_view = new Adw.ToolbarView ();
		toolbar_view.add_top_bar (headerbar);
		toolbar_view.content = global_box;

        history_sidebar = new HistorySidebar ();
        history_sidebar.added.connect (history_added);
        history_sidebar.clear_history.connect (() => {
            history.foreach ((entry) => {
                history.delete_link (history.find (entry));
            });
            button_ans.sensitive = false;
        });

        overlay_split_view = new Adw.OverlaySplitView () {
            collapsed = true,
            max_sidebar_width = 175,
			min_sidebar_width = 175,
        };
		overlay_split_view.content = toolbar_view;
		overlay_split_view.sidebar = history_sidebar;

        child = overlay_split_view;

        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        entry.grab_focus ();

        entry.changed.connect (remove_error);
        entry.activate.connect (button_calc_clicked);
        entry.get_delegate ().insert_text.connect (replace_text);

        button_calc.clicked.connect (() => {button_calc_clicked ();});
        button_del.clicked.connect (() => {button_del_clicked ();});
        button_ans.clicked.connect (() => {button_ans_clicked ();});

        button_mr.clicked.connect (() => {
            activate_action (ACTION_INSERT, new Variant.string (number_to_string (memory_value)));
        });

        button_ms.clicked.connect (() => {button_memory_store_clicked ();});
        button_m_add.clicked.connect (() => {button_memory_add_clicked ();});
        button_m_sub.clicked.connect (() => {button_memory_subtract_clicked ();});
        button_mc.clicked.connect (() => {button_memory_clear_clicked ();});
        button_gt.clicked.connect (() => {button_gt_clicked ();});
        button_reciprocal.clicked.connect (() => {button_reciprocal_clicked ();});

        settings.bind ("extended-shown", button_extended, "active", GLib.SettingsBindFlags.DEFAULT | GLib.SettingsBindFlags.GET_NO_CHANGES);

        // The window is constructed before adding to the application.
        // So for the first window, the application will have 0 windows
        if (application_instance.get_windows ().length () == 0) {
            //Only remember the contents of the entry in the first window (subject to privacy settings)
            var privacy_settings = new Settings ("org.gnome.desktop.privacy");
            if (privacy_settings.get_boolean ("remember-recent-files")) {
                settings.bind ("entry-content", entry, "text", GLib.SettingsBindFlags.DEFAULT);
            }
        }
    }

    private void undo () {
        unowned List<History?> previous_entry = history.last ();
        if (previous_entry != null) {
            entry.set_text (previous_entry.data.exp);
            history.remove_link (previous_entry);
        }
    }

    private void copy () {
        int start, end;
        entry.get_selection_bounds (out start, out end);
        var text_selected = end - start != 0;

        // we have to copy text in both cases
        // because seems like application action blocks entry's action
        if (!text_selected) {
            entry.get_clipboard ().set_text (entry.text);
        } else {
            entry.get_clipboard ().set_text (entry.text.slice (start, end));
        }
    }

    private void paste () {
        get_clipboard_text.begin ((obj, res) => {
            var text = get_clipboard_text.end (res);
            if (text == null) {
                return;
            }

            int start, end;
            entry.get_selection_bounds (out start, out end);
            // start and end are character positions so cannot use string slice
            var before = entry.get_chars (0, start);
            var after = entry.get_chars (end, -1);
            entry.text = before + text + after;
            entry.set_position (before.char_count () + text.char_count ());
        });
    }

    private async string? get_clipboard_text () {
        try {
            return yield entry.get_clipboard ().read_text_async (null);
        } catch (Error e) {
            warning (e.message);
            return null;
        }
    }

    private void action_insert (SimpleAction action, Variant? variant) {
        var token = variant.get_string ();
        int new_position = entry.get_position ();
        int selection_start, selection_end, selection_length;
        bool is_text_selected = entry.get_selection_bounds (out selection_start, out selection_end);
        if (is_text_selected) {
            new_position = selection_end;
            entry.delete_selection ();
            selection_length = selection_end - selection_start;
            new_position -= selection_length;
        }

        var cursor_position = entry.cursor_position;
        entry.do_insert_text (token, -1, ref cursor_position);

        new_position += token.char_count ();
        entry.grab_focus ();
        entry.set_position (new_position);
    }

    private void action_function (SimpleAction action, Variant? variant) {
        var token = variant.get_string ();
        int selection_start = -1;
        int selection_end = -1;
        if (entry.get_selection_bounds (out selection_start, out selection_end)) {
            int new_position = selection_start;
            string selected_text = entry.get_chars (selection_start, selection_end);
            string function_call = token + "(" + selected_text + ")";
            entry.delete_text (selection_start, selection_end);
            entry.insert_text (function_call, -1, ref selection_start);
            new_position += function_call.char_count ();
            entry.grab_focus ();
            entry.set_position (new_position);
        } else {
            activate_action (ACTION_INSERT, variant);
        }
    }

    private void button_calc_clicked () {
        position = entry.get_position ();
        if (entry.get_text () != "") {
            try {
                var output = eval.evaluate (entry.get_text (), decimal_places);
                if (entry.get_text () != output) {
                    History history_entry = new History ();
                    history_entry.exp = entry.get_text ();
                    history_entry.output = output;
                    history.append (history_entry);
                    update_history_dialog (history_entry);
                    entry.set_text (output);
                    button_history.set_sensitive (true);
                    button_ans.set_sensitive (true);
                    button_gt.set_sensitive (true);

                    position = output.length;
                    remove_error ();
                }
            } catch (Core.OUT_ERROR e) {
                infobar_label.label = e.message;
                infobar.revealed = true;
            }
        } else {
            remove_error ();
        }

        entry.grab_focus ();
        entry.set_position (position);
    }

    private void button_reciprocal_clicked () {
        entry.set_text ("1/(" + entry.get_text () + ")");
        button_calc_clicked ();
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

    private void button_memory_store_clicked () {
        if (entry.get_text () != "") {
            try {
                /* This is necessary because we don't want to accept non-numeric values.
                 * Moreover, it allows the saving in memory of the result of complex mathematical
                 * functions by calculating the result separately and allowing the user to recall
                 * it using the MR button (e.g. "√4" will store the value "2,0" in the variable).
                 *
                 * Since "double.parse" method works only by using "." as decimal symbol we need
                 * to make sure to replace the localized one with it before storing the value and
                 * adding/subtracting to and from it. We must also replace "." with the correct
                 * decimal symbol for locale when recalling stored value from the memory.
                 */
                var output = eval.evaluate (entry.get_text (), decimal_places);
                memory_value = double.parse (output.replace (eval.scanner.decimal_symbol, "."));

                button_mr.set_sensitive (true);
                button_mc.set_sensitive (true);
            } catch (Core.OUT_ERROR e) {
                infobar_label.label = e.message;
                infobar.revealed = true;
            }
        }
    }

    // Addition and subtraction to and from memory value are done silently,
    // updating the value without informing the user, as in real-life calculators.
    private void button_memory_add_clicked () {
        if (entry.get_text () != "") {
            try {
                var output = eval.evaluate (entry.get_text (), decimal_places);
                memory_value += double.parse (output.replace (eval.scanner.decimal_symbol, "."));
            } catch (Core.OUT_ERROR e) {
                infobar_label.label = e.message;
                infobar.revealed = true;
            }
        }
    }

    private void button_memory_subtract_clicked () {
        if (entry.get_text () != "") {
            try {
                var output = eval.evaluate (entry.get_text (), decimal_places);
                memory_value -= double.parse (output.replace (eval.scanner.decimal_symbol, "."));
            } catch (Core.OUT_ERROR e) {
                infobar_label.label = e.message;
                infobar.revealed = true;
            }
        }
    }

    private void button_memory_clear_clicked () {
        memory_value = 0;
        button_mr.sensitive = false;
        button_mc.sensitive = false;
    }

    private void button_gt_clicked () {
        action_clear ();

        double grand_total = 0;
        history.foreach ((list_entry) => {
            grand_total += double.parse (list_entry.output.replace (eval.scanner.decimal_symbol, "."));
        });

        entry.set_text (number_to_string (grand_total));
        entry.set_position (grand_total.to_string ().length);
    }

    /* Method taken from "Evaluation.vala" to limit the number of digits to be shown
     * and to strip all trailing zeroes because the last decimals may be innacurate.
     *
     * Since the application has a precision of nine decimal numbers it makes
     * sense to apply the same criterion for the value stored in memory as well.
     */
    private string number_to_string (double number) {
        string shortened_number = ("%.9f".printf (number));
        string number_localized = shortened_number.replace (".", eval.scanner.decimal_symbol);

        /* Remove trailing 0s or decimal symbol */
        while (number_localized.has_suffix ("0")) {
            number_localized = number_localized.slice (0, -1);
        }
        if (number_localized.has_suffix (eval.scanner.decimal_symbol)) {
            number_localized = number_localized.slice (0, -1);
        }

        /* Insert separator symbol in large numbers */
        var builder = new StringBuilder (number_localized);
        var decimal_pos = number_localized.last_index_of (eval.scanner.decimal_symbol);
        if (decimal_pos == -1) {
            decimal_pos = number_localized.length;
        }

        int end_position = 0;
        if (number_localized.has_prefix ("-")) {
            end_position = 1;
        }
        for (int i = decimal_pos - 3; i > end_position; i -= 3) {
            builder.insert (i, eval.scanner.separator_symbol);
        }

        return builder.str;
    }

    private void action_clear () {
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
            button.icon_name = "pane-show-symbolic";
            button.tooltip_text = _("Hide extended functionality");
            extended_revealer.reveal_child = true;
        } else {
            /* Hide extended functionality */
            button.icon_name = "pane-hide-symbolic";
            button.tooltip_text = _("Show extended functionality");
            extended_revealer.reveal_child = false;
        }
        /* Focusing button_calc because without a new focus it will cause weird window drawing problems. */
        entry.grab_focus ();
        entry.set_position (position);
    }

    private void show_history () {
        overlay_split_view.show_sidebar = true;
        position = entry.get_position ();
    }

    private void update_history_dialog (History entry) {
        history_sidebar.append (entry);
    }

    private void history_added (string input) {
        var cursor_position = entry.cursor_position;
        entry.do_insert_text (input, -1, ref cursor_position);
        position += input.length;
        entry.grab_focus ();
        entry.set_position (position);

        overlay_split_view.show_sidebar = false;
    }

    private void remove_error () {
        infobar.revealed = false;
    }

    private void replace_text (string new_text, int new_text_length, ref int position) {
        var replacement_text = "";

        switch (new_text) {
            case ".":
            case ",":
                replacement_text = Posix.nl_langinfo (Posix.NLItem.RADIXCHAR);
                break;
            case "/":
                replacement_text = "÷";
                break;
            case "*":
                replacement_text = "×";
                break;
        }

        if (replacement_text != "" && replacement_text != new_text) {
            entry.do_insert_text (replacement_text, entry.cursor_position + replacement_text.char_count (), ref position);
            Signal.stop_emission_by_name ((void*) entry.get_delegate (), "insert-text");
        }
    }

    public class History : GLib.Object {
        public string exp { get; set; }
        public string output { get; set; }
    }
}
