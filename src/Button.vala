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

    public Button (string label) {
        var lbl = new Gtk.Label (label) {
            use_markup = true
        };

        child = lbl;
    }

    public Button.from_icon_name (string icon_name) {
        var image = new Gtk.Image.from_icon_name (icon_name);
        child = image;
    }

    construct {
        width_request = WIDTH;
        height_request = HEIGHT;
    }
}
