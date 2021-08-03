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
    public class HistoryDialog : Granite.Dialog {
        public unowned List<MainWindow.History?> history { get; construct; }
        public signal void clear_history ();

        private Gtk.TreeView view;
        private Gtk.ListStore list_store;

        private Gtk.RadioButton expression_radio;
        private Gtk.RadioButton result_radio;

        public signal void added (string text);

        public HistoryDialog (List<MainWindow.History?> _history) {
            Object (history: _history);
        }

        construct {
            deletable = false;
            title = _("History");
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
                expand = true,
                headers_visible = false
            };
            view.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            view.insert_column_with_attributes (-1, null, cell, "text", 0);
            view.insert_column_with_attributes (-1, null, cell, "text", 1);
            view.get_column (1).min_width = 75;
            view.get_column (0).min_width = 200;

            var scrolled = new Gtk.ScrolledWindow (null, null) {
                min_content_height = 125,
                shadow_type = Gtk.ShadowType.IN
            };
            scrolled.add (view);

            var add_label = new Gtk.Label (_("Value to insert:")) {
                halign = Gtk.Align.END,
                hexpand = true
            };

            result_radio = new Gtk.RadioButton.with_label (null, _("Result"));

            expression_radio = new Gtk.RadioButton.with_label_from_widget (result_radio, _("Expression"));

            var main_grid = new Gtk.Grid () {
               column_spacing = 12,
               expand = true,
               margin = 12,
               margin_top = 0,
               row_spacing = 12
            };
            main_grid.attach (description_label, 0, 0, 3, 1);
            main_grid.attach (scrolled, 0, 1, 3, 1);
            main_grid.attach (add_label, 0, 2);
            main_grid.attach (result_radio, 2, 2);
            main_grid.attach (expression_radio, 1, 2);

            get_content_area ().add (main_grid);

            // Use progressive custom response code with 0 as the default close action
            var button_clear = add_button (_("Clear History"), -1);
            button_clear.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            add_button (_("Close"), 0);

            var button_add = add_button (_("Insert"), 1);
            button_add.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            show_all ();

            response.connect (on_response);
        }

        public void append (MainWindow.History entry) {
            Gtk.TreeIter iter;
            list_store.insert (out iter, 0);
            list_store.set (iter, 0, entry.exp, 1, entry.output);
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            if (response_id == -1) {
                list_store.clear ();
                clear_history ();
            } else if (response_id == 1) {
                var selection = view.get_selection ();
                Gtk.TreeIter iter;
                if (selection.get_selected (null, out iter)) {
                    Value val = Value (typeof (string));

                    if (result_radio.get_active ()) {
                        list_store.get_value (iter, 1, out val);
                    } else if (expression_radio.get_active ()) {
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
