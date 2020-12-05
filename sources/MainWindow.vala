public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    Gtk.HeaderBar header;
    ColorGridWidget color_grid_widget;
    ColorSelectionWidget selection_widget;
    Gtk.Button refill_button;
    Gtk.Label refill_num_label;
    Gtk.DropDown number_dropdown;

    public MainWindow (Gtk.Application app) {
        Object (application: app);

        this.set_default_size (960, 680);
        this.title = "Vala Colors";

        header = new Gtk.HeaderBar ();
        header.decoration_layout = ":close";

        var toggle_info = new Gtk.ToggleButton ();
        toggle_info.icon_name = "emblem-important-symbolic";
        toggle_info.tooltip_text = "Show selection info";

        refill_num_label = new Gtk.Label ("4096 /"); /* default num */
        var attrs = new Pango.AttrList ();
        attrs.insert (new Pango.AttrFontFeatures ("tnum"));
        refill_num_label.xalign = 1;
        refill_num_label.attributes = attrs;

        var refill_button = new Gtk.Button.with_label ("refill");
        var label = new Gtk.Label ("Color Num:");
        var number_dropdown = new Gtk.DropDown.from_strings (
        {
            "8", "64", "512", "4096", "32768", "262144", "2097152", "16777216",
        });
        refill_button = new Gtk.Button.with_label ("Refill");
        refill_button.clicked.connect (refill_button_clicked_cb);


        var format_factory = new Gtk.SignalListItemFactory ();
        format_factory.setup.connect (setup_format_factory);
        format_factory.bind.connect (bind_format_factory);

        number_dropdown.set_selected (3); /* 4096 */
        number_dropdown.factory = format_factory;
        number_dropdown.notify["selected"].connect (number_dropdown_item_selected);

        header.pack_start (toggle_info);
        header.pack_start (refill_button);
        header.pack_start (label);
        header.pack_start (number_dropdown);

        label = new Gtk.Label ("Sort By:");
        var sort_by_dropdown = new Gtk.DropDown.from_strings (
        {
            "Unsorted",
            "Name",
            "Red",
            "Green",
            "Blue",
            "RGB",
            "Hue",
            "Saturation",
            "Value",
            "HSV",
        });
        sort_by_dropdown.selected = 1; /* Name */
        sort_by_dropdown.notify["selected"].connect (sort_by_dropdown_item_selected);

        header.pack_end (sort_by_dropdown);
        header.pack_end (label);

        label = new Gtk.Label ("Show:");
        var details_dropdown = new Gtk.DropDown.from_strings ({ "Colors", "Everything" });
        details_dropdown.notify["selected"].connect (details_dropdown_item_selected);

        header.pack_end (details_dropdown);
        header.pack_end (label);

        this.set_titlebar (header);

        color_grid_widget = new ColorGridWidget ();
        color_grid_widget.hexpand = color_grid_widget.vexpand = true;

        var sort_model = color_grid_widget.get_sort_list_model ();
        var selection_model = color_grid_widget.get_selection_model ();

        selection_widget = new ColorSelectionWidget (sort_model, selection_model);
        
        toggle_info.bind_property ("active", selection_widget, "selection-shown");

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (selection_widget);
        box.append (color_grid_widget);

        this.set_child (box);
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

    void sort_by_dropdown_item_selected (GLib.Object object, GLib.ParamSpec pspec) {
        var dropdown = (Gtk.DropDown)object;
        var item = (Gtk.StringObject)dropdown.get_selected_item ();

        switch (item.string) {
            case "Unsorted":
                color_grid_widget.update_sort_by (SortBy.UNSORTED); break;
            case "Name":
                color_grid_widget.update_sort_by (SortBy.NAME); break;
            case    "Red":
                color_grid_widget.update_sort_by (SortBy.RED); break;
            case    "Green":
                color_grid_widget.update_sort_by (SortBy.GREEN); break;
            case    "Blue":
                color_grid_widget.update_sort_by (SortBy.BLUE); break;
            case    "RGB":
                color_grid_widget.update_sort_by (SortBy.RGB); break;
            case    "Hue":
                color_grid_widget.update_sort_by (SortBy.HUE); break;
            case    "Saturation":
                color_grid_widget.update_sort_by (SortBy.SATURAION); break;
            case    "Value":
                color_grid_widget.update_sort_by (SortBy.VALUE); break;
            case    "HSV":
                color_grid_widget.update_sort_by (SortBy.HSV); break;
            default:
                assert_not_reached ();
        }
    }

    void setup_format_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var attrs = new Pango.AttrList ();
        attrs.insert (new Pango.AttrFontFeatures ("tnum"));

        var label = new Gtk.Label ("");
        label.xalign = 1;
        label.attributes = attrs;

        list_item.child = label;
    }

    void bind_format_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var label = (Gtk.Label)list_item.child;
        var item = (Gtk.StringObject)list_item.item;

        var num = int.parse (item.string);
        var str = "%'u".printf (num);

        label.label = str;
    }
}
