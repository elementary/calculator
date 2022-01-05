/*-
 * Copyright (c) 2012-2018 elementary LLC. (https://elementary.io)
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
 * Authored by: Corentin Noël <corentin@elementaryos.io>
 */

public class PantheonCalculator.Button : Gtk.Button {
    private const int WIDTH = 65;
    private const int HEIGHT = 43;
    public string function = null;

    public Button (string label, string? description = null) {
        function = label;

        var lbl = new Gtk.Label (label) {
            use_markup = true
        };

        child = lbl;
        tooltip_text = description;
    }

    construct {
        width_request = WIDTH;
        height_request = HEIGHT;
    }

    // public override void get_preferred_width (out int minimum_width, out int natural_width) {
    //     minimum_width = WIDTH;
    //     natural_width = WIDTH;
    // }

    // public override void get_preferred_height (out int minimum_height, out int natural_height) {
    //     minimum_height = HEIGHT;
    //     natural_height = HEIGHT;
    // }
}
