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

using Gtk;
using Calculus.Core;
using Granite.Widgets;

namespace Calculus {
    public class HistoryDialog : Gtk.Dialog {
    
        private unowned List<MainWindow.History?> history;
        private Gtk.TreeView view;
        private Gtk.Widget button_cp_expression;
        private Gtk.Widget button_cp_output;
        private Gtk.Widget button_close;
        private Gtk.ListStore list_store;
        
        public signal void added (string text);
        
        public HistoryDialog (List<MainWindow.History?> history) {
            this.history = history;
            this.title = _("History");
            this.set_resizable (false);
            
            this.build_ui ();
            this.build_buttons ();
            this.show_all ();
        }
        
        private void build_ui () {
            Gtk.Box content = get_content_area () as Gtk.Box;
            Gtk.Grid grid = new Gtk.Grid ();
            grid.expand = true;
            grid.set_column_spacing (3);
            grid.set_row_spacing (10);
            grid.margin = 10;
            grid.margin_top = 0;
			content.pack_start (grid);

			var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
			header_box.hexpand = true;
			header_box.halign = Gtk.Align.CENTER;
			header_box.margin_bottom = 20;

			var history_img = new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.DND);
			header_box.pack_start (history_img);

            var header_label = new Gtk.Label (_("History"));
            header_label.get_style_context ().add_class ("h2");

			header_box.pack_start (header_label);
            grid.attach (header_box, 0, 0, 1, 1);

            
            if (history.length () > 0) {
                list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
                Gtk.TreeIter iter;
                
                foreach (MainWindow.History h in history) {
                    list_store.append (out iter);
                    list_store.set (iter, 0, h.output, 1, h.exp);
                }

                view = new Gtk.TreeView.with_model (list_store);
                view.expand = true;
                
                Gtk.CellRendererText cell = new Gtk.CellRendererText ();
		        view.insert_column_with_attributes (-1, _("Result"), cell, "text", 0);
		        view.insert_column_with_attributes (-1, _("Expression"), cell, "text", 1);
                
                view.get_column (0).min_width = 100;
                view.get_column (0).max_width = 100;
                
                Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
                scrolled.min_content_height = 150;
                scrolled.shadow_type = Gtk.ShadowType.IN;
                scrolled.add (view);
                grid.attach (scrolled, 0, 1, 1, 1);
                
            }
        }
        
        private void build_buttons () {
			button_close = add_button (_("Close"), Gtk.ResponseType.CLOSE);
			button_cp_output = add_button (_("Add Expression"), 101);
            button_cp_expression = add_button (_("Add Result"), 100);
            
            if (history.length () == 0) {
                button_cp_expression.sensitive = false;
                button_cp_output.sensitive = false;
            }
            
            this.response.connect (on_response);
        }
        
        private void on_response (Gtk.Dialog source, int response_id) {
            if (response_id != Gtk.ResponseType.CLOSE) {
                var selection = view.get_selection ();
                Gtk.TreeIter iter;
                if (selection.get_selected (null, out iter)) {
                    Value val = Value (typeof (string));;
                    if (response_id == 100)
                        list_store.get_value (iter, 0, out val);
                    else if (response_id == 101)
                        list_store.get_value (iter, 1, out val);
                   
                   this.added (val.get_string ());    
                }
            }
            this.hide ();
            this.destroy ();
        }
    }
}
