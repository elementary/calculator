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
    public class HistoryDialog : Gtk.Dialog {
        private unowned List<MainWindow.History?> history;
        private Gtk.TreeView view;
        private Gtk.Grid main_grid;
        private Gtk.Widget button_add;
        private Gtk.Widget button_close;
        private Gtk.ListStore list_store;

        private Gtk.RadioButton expression_radio;
        private Gtk.RadioButton result_radio;

        public signal void added (string text);

        public HistoryDialog (List<MainWindow.History?> _history) {
            history = _history;
            title = _("History");
            set_size_request (450, 0);
            set_resizable (false);
            set_deletable (false);

            build_ui ();
            build_buttons ();
            show_all ();
        }

        public void append (MainWindow.History entry) {
            Gtk.TreeIter iter;
            list_store.insert (out iter, 0);
            list_store.set (iter, 0, entry.exp, 1, entry.output);
        }

        private void build_ui () {
            var content = get_content_area () as Gtk.Box;
            get_action_area ().margin = 6;
            main_grid = new Gtk.Grid ();
            main_grid.expand = true;
            main_grid.margin = 12;
            main_grid.margin_top = 0;
            main_grid.row_spacing = 10;
            main_grid.column_spacing = 20;
            content.add (main_grid);

            if (history.length () > 0) {
                list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
                Gtk.TreeIter iter;

                foreach (MainWindow.History h in history) {
                    list_store.insert (out iter, 0);
                    list_store.set (iter, 0, h.exp, 1, h.output);
                }

                view = new Gtk.TreeView.with_model (list_store);
                view.expand = true;
                view.set_headers_visible (false);
                view.get_style_context ().add_class ("h3");

                Gtk.CellRendererText cell = new Gtk.CellRendererText ();
                view.insert_column_with_attributes (-1, null, cell, "text", 0);
                view.insert_column_with_attributes (-1, null, cell, "text", 1);

                view.get_column (1).min_width = 75;
                view.get_column (0).min_width = 200;

                Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
                scrolled.min_content_height = 125;
                scrolled.shadow_type = Gtk.ShadowType.IN;
                scrolled.add (view);
                main_grid.attach (scrolled, 0, 0, 3, 1);
            }

            var add_label = new Gtk.Label (_("Value to add:"));
            add_label.halign = Gtk.Align.END;
            main_grid.attach (add_label, 0, 1, 1, 1);

            result_radio = new Gtk.RadioButton.with_label (null, _("Result"));
            result_radio.halign = Gtk.Align.END;
            main_grid.attach (result_radio, 2, 1, 1, 1);

            expression_radio = new Gtk.RadioButton.with_label_from_widget (result_radio, _("Expression"));
            expression_radio.halign = Gtk.Align.END;
            main_grid.attach (expression_radio, 1, 1, 1, 1);
        }

        private void build_buttons () {
            button_close = add_button (_("Close"), Gtk.ResponseType.CLOSE);
            button_add = add_button (_("Add"), Gtk.ResponseType.OK);
            button_add.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            response.connect (on_response);
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            if (response_id == Gtk.ResponseType.OK) {
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
