public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    Gtk.HeaderBar header;
    ColorGridWidget color_grid_widget;
    public MainWindow (Gtk.Application app) {
        Object (application: app);

        this.set_default_size (800, 600);
        this.title = "Vala Colors";

        header = new Gtk.HeaderBar ();
        header.decoration_layout = ":close";

        var toggle_info = new Gtk.ToggleButton ();
        toggle_info.icon_name = "emblem-important-symbolic";

        var refill_button = new Gtk.Button.with_label ("refill");
        var label = new Gtk.Label ("Color Num:");
        var number_dropdown = new Gtk.DropDown.from_strings (
        {
            "8", "64", "512", "4096", "32768", "262144", "2097152", "16777216",
        });
        number_dropdown.notify["selected"].connect (number_dropdown_item_selected);

        header.pack_start (toggle_info);
        header.pack_start (refill_button);
        header.pack_start (label);
        header.pack_start (number_dropdown);

        label = new Gtk.Label ("Show:");
        var details_dropdown = new Gtk.DropDown.from_strings ({ "Colors", "Everything" });
        details_dropdown.notify["selected"].connect (details_dropdown_item_selected);

        header.pack_end (details_dropdown);
        header.pack_end (label);


        this.set_titlebar (header);

        color_grid_widget = new ColorGridWidget ();
        color_grid_widget.hexpand = color_grid_widget.vexpand = true;
        this.set_child (color_grid_widget);
    }

    void number_dropdown_item_selected (GLib.Object object, GLib.ParamSpec pspec) {
        var dropdown = (Gtk.DropDown)object;
        var item = (Gtk.StringObject)dropdown.get_selected_item ();
        var i = int.parse (item.string);
        color_grid_widget.update_list_size (i);
    }

    void details_dropdown_item_selected (GLib.Object object, GLib.ParamSpec psepc) {
        var dropdown = (Gtk.DropDown)object;
        var item = (Gtk.StringObject)dropdown.get_selected_item ();
        
        if (item.string == "Colors") {
            color_grid_widget.update_show_details (false);
        } else if (item.string == "Everything") {
            color_grid_widget.update_show_details (true);
        } else {
            assert_not_reached ();
        }
    }
}
