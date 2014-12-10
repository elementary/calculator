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
		        view.insert_column_with_attributes (-1, "Result", cell, "text", 0);
		        view.insert_column_with_attributes (-1, "Expression", cell, "text", 1);
                
                view.get_column (0).min_width = 100;
                view.get_column (0).max_width = 100;
                
                Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
                scrolled.min_content_height = 150;
                scrolled.shadow_type = Gtk.ShadowType.IN;
                scrolled.add (view);
                grid.attach (scrolled, 0, 1, 1, 1);
                
            } else {
                var text = new Gtk.Label (_("There is no calculation history yet."));
                text.get_style_context ().add_class ("h3");
                grid.attach (text, 0, 1, 1, 1);
            }
            
            var header = new Gtk.Grid ();
            header.set_column_spacing (10);
            var header_label = new Gtk.Label (_("History"));
            var history_img = new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.DND);
            
            header_label.get_style_context ().add_class ("h2");
            header.attach (header_label, 1, 0, 1, 1);
            header.attach (history_img, 0, 0, 1, 1);
            grid.attach (header, 0, 0, 1, 1);
            
            content.pack_start (grid);
        }
        
        private void build_buttons () {
            button_cp_expression = add_button (_("Add Result"), 100);
            button_cp_output = add_button (_("Add Expression"), 101);
            
            if (history.length () == 0) {
                button_cp_expression.sensitive = false;
                button_cp_output.sensitive = false;
            }
            
            button_close = add_button (_("Close"), Gtk.ResponseType.CLOSE);
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
