/*-
 * Copyright 2018-2021 elementary, Inc. (https://elementary.io)
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

namespace PantheonCalculator {
    // public class HistoryDialog : Granite.Dialog {
    public class HistoryDialog : Gtk.Dialog {
        public unowned List<MainWindow.History?> history { get; construct; }
        public signal void clear_history ();

        private Gtk.TreeView view;
        private Gtk.ListStore list_store;

        private Gtk.CheckButton expression_check_button;
        private Gtk.CheckButton result_check_button;
        // private Gtk.RadioButton expression_radio;
        // private Gtk.RadioButton result_radio;

        public signal void added (string text);

        public HistoryDialog (List<MainWindow.History?> _history) {
            Object (history: _history);
        }

        construct {
            deletable = false;
            // title = _("History");
            use_header_bar = (int) false;
            // titlebar = new Gtk.HeaderBar () {
            //     title_widget = new Gtk.Label (null),
            //     css_classes = {"flat","default-decoration"}
            // };
            default_width = 250;

            var description_label = new Gtk.Label (_("Insert a previous expression or result into the current calculation.")) {
                xalign = 0,
                halign = Gtk.Align.START,
                hexpand = true,
                justify = Gtk.Justification.LEFT,
                wrap = true
            };

            list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
            Gtk.TreeIter iter;

            foreach (MainWindow.History h in history) {
                list_store.insert (out iter, 0);
                list_store.set (iter, 0, h.exp, 1, h.output);
            }

            var cell = new Gtk.CellRendererText ();

            view = new Gtk.TreeView.with_model (list_store) {
                hexpand = true,
                vexpand = true,
                headers_visible = false,
                css_classes = {"h3"}
            };
            // view.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            view.insert_column_with_attributes (-1, null, cell, "text", 0);
            view.insert_column_with_attributes (-1, null, cell, "text", 1);
            view.get_column (1).min_width = 75;
            view.get_column (0).min_width = 200;

            // var scrolled = new Gtk.ScrolledWindow (null, null) {
            var scrolled = new Gtk.ScrolledWindow () {
                min_content_height = 125,
                // shadow_type = Gtk.ShadowType.IN
            };
            // scrolled.add (view);
            scrolled.set_child (view);

            var add_label = new Gtk.Label (_("Value to insert:")) {
                halign = Gtk.Align.END,
                hexpand = true
            };

            // result_radio = new Gtk.RadioButton.with_label (null, _("Result"));

            // expression_radio = new Gtk.RadioButton.with_label_from_widget (result_radio, _("Expression"));

            result_check_button = new Gtk.CheckButton.with_label (_("Result"));

            expression_check_button = new Gtk.CheckButton.with_label (_("Expression")) {
                group = result_check_button
            };

            var main_grid = new Gtk.Grid () {
               column_spacing = 12,
               hexpand = true,
               vexpand = true,
               margin_start = 12,
               margin_end = 12,
               margin_bottom = 12,
               margin_top = 0,
               row_spacing = 12
            };
            main_grid.attach (description_label, 0, 0, 3, 1);
            main_grid.attach (scrolled, 0, 1, 3, 1);
            main_grid.attach (add_label, 0, 2);
            main_grid.attach (result_check_button, 2, 2);
            main_grid.attach (expression_check_button, 1, 2);

            get_content_area ().append (main_grid);

            // Use a custom response code for "Clear History" action
            var button_clear = add_button (_("Clear History"), 0);
            button_clear.css_classes = {"destructive-action"};
            // button_clear.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            add_button (_("Close"), Gtk.ResponseType.CLOSE);

            var button_add = add_button (_("Insert"), Gtk.ResponseType.APPLY);
            button_add.css_classes = {"suggested-action"};
            // button_add.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            present ();

            response.connect (on_response);
        }

        public void append (MainWindow.History entry) {
            Gtk.TreeIter iter;
            list_store.insert (out iter, 0);
            list_store.set (iter, 0, entry.exp, 1, entry.output);
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            if (response_id == 0) {
                list_store.clear ();
                clear_history ();
            } else if (response_id == Gtk.ResponseType.APPLY) {
                var selection = view.get_selection ();
                Gtk.TreeIter iter;
                if (selection.get_selected (null, out iter)) {
                    Value val = Value (typeof (string));

                    if (result_check_button.get_active ()) {
                        list_store.get_value (iter, 1, out val);
                    } else if (expression_check_button.get_active ()) {
                        list_store.get_value (iter, 0, out val);
                    }

                    added (val.get_string ());
                }
            }

            hide ();
            destroy ();
        }
    }
}
