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
		private Gtk.Grid grid;
        private Gtk.Widget button_add;
        //private Gtk.Widget button_cp_output;
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
            
            build_ui ();
            build_buttons ();
            show_all ();
        }
        
        private void build_ui () {
            Gtk.Box content = get_content_area () as Gtk.Box;
            get_action_area ().margin_right = 12;
			get_action_area ().margin_bottom = 12;
			grid = new Gtk.Grid ();
			grid.expand = true;
			grid.margin = 12;
			grid.margin_top = 12;
			grid.margin_bottom = 24;
			grid.row_spacing = 10;
			grid.column_spacing = 20;
			content.pack_start (grid);

            if (history.length () > 0) {
                list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
                Gtk.TreeIter iter;
                
                foreach (MainWindow.History h in history) {
                    list_store.insert (out iter, 0);
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
                scrolled.min_content_height = 100;
                scrolled.shadow_type = Gtk.ShadowType.IN;
                scrolled.add (view);
                grid.attach (scrolled, 0, 0, 3, 1);
            }

			var add_label = new Gtk.Label (_("Value to add:"));
			add_label.halign = Gtk.Align.END;
			grid.attach (add_label, 0, 1, 1, 1);

			result_radio = new Gtk.RadioButton.with_label (null, _("Result"));
			grid.attach (result_radio, 1, 1, 1, 1);

			expression_radio = new Gtk.RadioButton.with_label_from_widget (result_radio, _("Expression"));
			grid.attach (expression_radio, 2, 1, 1, 1);
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
                    Value val = Value (typeof (string));;
                    if (result_radio.get_active ())
                        list_store.get_value (iter, 0, out val);
                    else if (expression_radio.get_active ())
                        list_store.get_value (iter, 1, out val);
                   
                   added (val.get_string ());
                }
            }
            hide ();
            destroy ();
        }
    }
}
