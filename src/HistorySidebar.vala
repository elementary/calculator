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
    public class HistorySidebar : Gtk.Grid {
        public signal void clear_history ();

        private GLib.ListStore history_list;

        public signal void added (string text);

        construct {
            history_list = new GLib.ListStore (typeof (MainWindow.History));

            var clear_button = new Gtk.Button () {
                icon_name = "user-trash-full-symbolic",
                tooltip_text = _("Clear History")
            };

            clear_button.clicked.connect (() => {
                clear_history ();
                history_list.remove_all ();
            });

            var headerbar = new Adw.HeaderBar () {
                show_title = false
            };
            headerbar.pack_end (clear_button);
            headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);
            headerbar.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

            var listbox = new Gtk.ListBox () {
                hexpand = true
            };
            listbox.bind_model (history_list, create_widget_func);
            listbox.add_css_class (Granite.STYLE_CLASS_BACKGROUND);
            listbox.row_activated.connect ((row) => {
                MainWindow.History history = row.get_data<MainWindow.History> ("history");
                added (history.output);
            });

            var listbox_scrolled = new Gtk.ScrolledWindow () {
                hscrollbar_policy = NEVER,
                max_content_height = 200,
                propagate_natural_height = true,
                child = listbox,
                hexpand = true,
                vexpand = true
            };

            var main_box = new Gtk.Box (VERTICAL, 0) {
               hexpand = true,
               vexpand = true
            };
            main_box.append (listbox_scrolled);

            var toolbar_view = new Adw.ToolbarView ();
		    toolbar_view.add_top_bar (headerbar);
		    toolbar_view.content = main_box;

            attach (toolbar_view, 0, 0);
        }

        public void append (MainWindow.History entry) {
            history_list.insert (0, entry);
        }

        private Gtk.Widget create_widget_func (Object object) {
            var history = (MainWindow.History) object;

            var exp_label = new Gtk.Label () {
                halign = START,
                ellipsize = END,
                tooltip_text = history.exp
            };
            exp_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
            exp_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

            var output_label = new Gtk.Label ("<b>%s</b>".printf (history.output)) {
                halign = START,
                use_markup = true,
                ellipsize = END,
                tooltip_text = history.output
            };

            var row_grid = new Gtk.Grid () {
                margin_top = 6,
                margin_bottom = 6,
                margin_start = 12,
                margin_end = 12,
                row_spacing = 3
            };
            row_grid.attach (exp_label, 0, 0, 1, 1);
            row_grid.attach (output_label, 0, 1, 1, 1);

            var row = new Gtk.ListBoxRow () {
                child = row_grid
            };

            row.set_data ("history", history);

            return row;
        }
    }
}
