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
using Granite.Widgets;
using Calculus.Core;

namespace Calculus {
    public class MainWindow : Gtk.Window {
        private Gtk.HeaderBar headerbar;
        private Gtk.Grid main_grid;
        private Gtk.Grid sub_grid_1;
        private Gtk.Grid sub_grid_2;
        private Gtk.Entry entry;
        
        // widgets I need to access
        private Gtk.Image extended_img_1;
        private Gtk.Image extended_img_2;
        private Gtk.Button button_calc;
		private Gtk.Button button_history;
		private Gtk.ToggleButton button_extended;
        private Gtk.InfoBar? infobar;
        
        private List<History?> history;
		private int position;
        
        //define the decimal places
        private int round = 5;
        
        public struct History { string exp; string output; }
        
        private string[] button_types = {  "0", "1", "2", "3", "4", "5", 
                                            "6", "7", "8", "9", "0", " + ",
                                            " − ", " × ", " ÷ ", "%", ".", "(", 
                                            ")", "^", "sin", "cos", "tan", "√",
                                            "sinh", "cosh", "tanh" , "sqrt", "π"};

        public MainWindow () {
            this.set_resizable (false);
            this.window_position = Gtk.WindowPosition.CENTER;
            
            this.history = new List<History?> ();
			this.position = 0;
            
            this.build_titlebar ();
            this.build_ui ();
        }
        
        private void build_titlebar () {
            headerbar = new HeaderBar ();  
            headerbar.get_style_context ().add_class ("primary-toolbar");
            headerbar.show_close_button = true;
            headerbar.set_title (_("Calculator"));
            this.set_titlebar (headerbar); 
            
            extended_img_1 = new Gtk.Image.from_icon_name ("pane-hide-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            extended_img_2 = new Gtk.Image.from_icon_name ("pane-show-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            var history_img = new Gtk.Image.from_icon_name ("document-open-recent-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            
            button_extended = new Gtk.ToggleButton ();
            button_extended.set_property ("image", extended_img_1);
            button_extended.set_tooltip_text (_("Show extended functionality"));
            button_extended.set_relief (Gtk.ReliefStyle.NONE);
            button_extended.toggled.connect (toggle_grid);
            
            button_history = new Gtk.Button ();
            button_history.set_property ("image", history_img);
            button_history.set_tooltip_text (_("History"));
            button_history.set_relief (Gtk.ReliefStyle.NONE);
			button_history.set_sensitive (false);
            button_history.clicked.connect (show_history);
            
            headerbar.pack_end (button_extended);
            headerbar.pack_end (button_history);
        }
        
        private void build_ui () {
            main_grid = new Gtk.Grid ();
            sub_grid_2 = new Gtk.Grid ();
            
            main_grid.expand = true;
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            
            build_grid_1 ();
            build_grid_2 ();
            main_grid.attach (sub_grid_1, 0, 1, 1, 1);
            main_grid.attach (sub_grid_2, 1, 1, 1, 1);
            
            main_grid.show_all ();
            this.add (main_grid);
            this.show_all ();
            
            sub_grid_2.set_visible (false);
        }
        
        private void build_grid_1 () {
            sub_grid_1 = new Gtk.Grid ();
            sub_grid_1.orientation = Gtk.Orientation.VERTICAL;
            sub_grid_1.set_column_spacing (2);
            sub_grid_1.set_row_spacing (2);
            sub_grid_1.margin = 5;
            
            //create all widgets
            entry = new Gtk.Entry ();
            entry.set_text ("");
            button_calc = new Gtk.Button.with_label ("=");
            
            var button_undo = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            var button_del = new Gtk.Button.with_label ("C");
            var button_add = new Gtk.Button.with_label (" + ");
            var button_sub = new Gtk.Button.with_label (" − ");
            var button_mult = new Gtk.Button.with_label (" × ");
            var button_div = new Gtk.Button.with_label (" ÷ ");
            
            var button_0 = new Gtk.Button.with_label ("0");
            var button_point = new Gtk.Button.with_label (".");
            var button_percent = new Gtk.Button.with_label ("%");
            var button_1 = new Gtk.Button.with_label ("1");
            var button_2 = new Gtk.Button.with_label ("2");
            var button_3 = new Gtk.Button.with_label ("3");
            
            var button_4 = new Gtk.Button.with_label ("4");
            var button_5 = new Gtk.Button.with_label ("5");
            var button_6 = new Gtk.Button.with_label ("6");
            
            var button_7 = new Gtk.Button.with_label ("7");
            var button_8 = new Gtk.Button.with_label ("8");
            var button_9 = new Gtk.Button.with_label ("9");
      		
			button_undo.set_focus_on_click (false);
			button_del.set_focus_on_click (false);
			button_add.set_focus_on_click (false);
			button_sub.set_focus_on_click (false);
			button_div.set_focus_on_click (false);

            //add style context to widgets
            entry.get_style_context ().add_class ("h2");
            button_del.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            button_add.get_style_context ().add_class ("h3");
            button_sub.get_style_context ().add_class ("h3");
            button_mult.get_style_context ().add_class ("h3");
            button_div.get_style_context ().add_class ("h3");
            button_calc.get_style_context ().add_class ("h2");
            button_calc.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            
            //set tooltips for widgets
            button_del.set_tooltip_text (_("Clear entry"));
            button_undo.set_tooltip_text (_("Backspace"));
            
            //set size for some widgets to get desired layout
            entry.set_size_request (0, 45);
            
            button_0.set_size_request (65, 45);
            button_1.set_size_request (65, 45);
            button_4.set_size_request (65, 45);
            button_7.set_size_request (65, 45);
            
            button_undo.set_size_request (65, 45);
            button_del.set_size_request (65, 45);
            button_percent.set_size_request (65, 45);
            button_add.set_size_request (65, 45);
            
            //attach all widgets
            sub_grid_1.attach (entry, 0, 0, 4, 1);
            
            sub_grid_1.attach (button_7, 0, 2, 1, 1);
            sub_grid_1.attach (button_8, 1, 2, 1, 1);
            sub_grid_1.attach (button_9, 2, 2, 1, 1);
            
            sub_grid_1.attach (button_4, 0, 3, 1, 1);
            sub_grid_1.attach (button_5, 1, 3, 1, 1);
            sub_grid_1.attach (button_6, 2, 3, 1, 1);
            
            sub_grid_1.attach (button_1, 0, 4, 1, 1);
            sub_grid_1.attach (button_2, 1, 4, 1, 1);
            sub_grid_1.attach (button_3, 2, 4, 1, 1);
            
            sub_grid_1.attach (button_0, 0, 5, 1, 1);
            sub_grid_1.attach (button_point, 1, 5, 1, 1);
            sub_grid_1.attach (button_percent, 2, 1, 1, 1);
            
            sub_grid_1.attach (button_undo, 1, 1, 1, 1);
            sub_grid_1.attach (button_add, 3, 1, 1, 1);
            sub_grid_1.attach (button_sub, 3, 2, 1, 1);
            sub_grid_1.attach (button_mult, 3, 3, 1, 1);
            sub_grid_1.attach (button_div, 3, 4, 1, 1);
            
            sub_grid_1.attach (button_del, 0, 1, 1, 1);
            sub_grid_1.attach (button_calc, 2, 5, 2, 1);
            
            //connect button_clicked methods to buttons
            entry.changed.connect (remove_error);
            entry.activate.connect (button_calc_clicked);
            
            button_0.clicked.connect (button_clicked);
            button_1.clicked.connect (button_clicked);
            button_2.clicked.connect (button_clicked);
            button_3.clicked.connect (button_clicked);
            button_4.clicked.connect (button_clicked);
            button_5.clicked.connect (button_clicked);
            button_6.clicked.connect (button_clicked);
            button_7.clicked.connect (button_clicked);
            button_8.clicked.connect (button_clicked);
            button_9.clicked.connect (button_clicked);
            
            button_add.clicked.connect (button_clicked);
            button_sub.clicked.connect (button_clicked);
            button_div.clicked.connect (button_clicked);
            button_mult.clicked.connect (button_clicked);
            
            button_point.clicked.connect (button_clicked);
            button_percent.clicked.connect (button_clicked);
            
            button_calc.clicked.connect (button_calc_clicked);
            button_undo.clicked.connect (button_undo_clicked);
            button_del.clicked.connect (button_del_clicked);
            
            sub_grid_1.show_all ();
        }
        
        
        private void build_grid_2 () {
            sub_grid_2 = new Gtk.Grid ();
            sub_grid_2.orientation = Gtk.Orientation.VERTICAL;
            sub_grid_2.set_column_spacing (2);
            sub_grid_2.set_row_spacing (2);
            sub_grid_2.margin = 5;
            sub_grid_2.margin_start = 0;
            
            //create all widgets
            var button_pow = new Gtk.Button.with_label ("^");
            var button_sin = new Gtk.Button.with_label ("sin");
            var button_cos = new Gtk.Button.with_label ("cos");
            var button_tan = new Gtk.Button.with_label ("tan");
            var button_pi = new Gtk.Button.with_label ("π");
            var button_par_left = new Gtk.Button.with_label ("(");
            
            var button_sr = new Gtk.Button.with_label ("√");
            var button_sinh = new Gtk.Button.with_label ("sinh");
            var button_cosh = new Gtk.Button.with_label ("cosh");
            var button_tanh = new Gtk.Button.with_label ("tanh");
            var button_e = new Gtk.Button.with_label ("e");
            var button_par_right = new Gtk.Button.with_label (")");
            
            //add style context to widgets
            button_pow.get_style_context ().add_class ("h3");
            
            //set size for some widgets to get desired layout
            button_pow.set_size_request (60, 45);
            button_sr.set_size_request (60, 45);
            
            button_sin.set_size_request (65, 45);
            button_cos.set_size_request (65, 45);
            button_tan.set_size_request (65, 45);
            button_pi.set_size_request (65, 45);
            button_par_left.set_size_request (65, 45);
            
            sub_grid_2.attach (button_par_left, 0, 0, 1, 1);
            sub_grid_2.attach (button_pow, 0, 1, 1, 1);
            sub_grid_2.attach (button_sin, 0, 2, 1, 1);
            sub_grid_2.attach (button_cos, 0, 3, 1, 1);
            sub_grid_2.attach (button_tan, 0, 4, 1, 1);
            sub_grid_2.attach (button_pi, 0, 5, 1, 1);
            
            sub_grid_2.attach (button_par_right, 1, 0, 1, 1);
            sub_grid_2.attach (button_sr, 1, 1, 1, 1);
            sub_grid_2.attach (button_sinh, 1, 2, 1, 1);
            sub_grid_2.attach (button_cosh, 1, 3, 1, 1);
            sub_grid_2.attach (button_tanh, 1, 4, 1, 1);
            sub_grid_2.attach (button_e, 1, 5, 1, 1);
            
            button_pow.clicked.connect (button_clicked);
            button_sin.clicked.connect (button_clicked);
            button_cos.clicked.connect (button_clicked);
            button_tan.clicked.connect (button_clicked);
            button_pi.clicked.connect (button_clicked);
            button_par_left.clicked.connect (button_clicked);
            
            button_sr.clicked.connect (button_clicked);
            button_sinh.clicked.connect (button_clicked);
            button_cosh.clicked.connect (button_clicked);
            button_tanh.clicked.connect (button_clicked);
            button_e.clicked.connect (button_clicked);
            button_par_right.clicked.connect (button_clicked);
            
            sub_grid_2.show_all ();
        }
        
        private void button_clicked (Gtk.Button btn) {
			this.position = entry.get_position ();
            var label = btn.get_label ();
            
            foreach (var val in button_types) {
                if (label == val) {
					entry.insert_at_cursor (label);
                    break;
                }
            }
            this.position += (label.length);

			entry.grab_focus ();
			entry.set_position (position);
        }
        
        private void button_calc_clicked () {
			this.position = entry.get_position ();
            this.remove_error ();
            if (entry.get_text () != "") {
                try {
                    var output = Evaluation.evaluate (entry.get_text (), round);
					if (entry.get_text () != output) {
                    	history.append (History () { exp = entry.get_text (), output = output } );
                    	entry.set_text (output);
						button_history.set_sensitive (true);

						position = output.length;
					}
                } catch (OUT_ERROR e) {
                    infobar = new Gtk.InfoBar ();
                    infobar.get_content_area ().add (new Gtk.Label (e.message));
                    infobar.set_show_close_button (false);
                    infobar.set_message_type (Gtk.MessageType.ERROR);
                    
                    main_grid.attach (infobar, 0, 0, 2, 1);
                    infobar.show_all ();
                }
            }

			entry.grab_focus ();
			entry.set_position (position);
        } 
        
        private void button_undo_clicked () {
			this.position = entry.get_position () - 1;
            entry.set_text (entry.get_text ().slice (0, entry.get_text ().length - 1));

			entry.grab_focus ();
			entry.set_position (position);
        }
        
        private void button_del_clicked () {
			this.position = 0;
            entry.set_text ("");
            this.set_focus (entry);
            this.remove_error ();

			entry.grab_focus ();
			entry.set_position (position);
        }
        
        private void toggle_grid (Gtk.ToggleButton button) {
			this.position = entry.get_position ();
            if (button.get_active ()) {
                //show extended functionality
                button.set_property ("image", extended_img_2);
                button.set_tooltip_text (_("Hide extended functionality"));
                sub_grid_2.show ();
            } else {
                //hide extended functionality
                button.set_property ("image", extended_img_1);
                button.set_tooltip_text (_("Show extended functionality"));
                sub_grid_2.hide ();
            }
            //focusing button_calc because without a new focus it will cause weird window drawing problems.
            entry.grab_focus ();
			entry.set_position (position);
        }
        
        private void show_history (Gtk.Button button) {
			this.position = entry.get_position ();

            var history_dialog = new HistoryDialog (history);
            history_dialog.added.connect (history_added);

			entry.grab_focus ();
			entry.set_position (position);
        }
        
        private void history_added (string input) {
            entry.set_text (entry.get_text () + input);
        }
        
        private void remove_error () {
            if (infobar != null)
                infobar.hide ();
        }
    }
}
