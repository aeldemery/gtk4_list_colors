public class Gtk4Demo.ColorGridWidget : Gtk.Widget {
    private Gtk.GridView grid_view;
    private Gtk.ScrolledWindow sw;
    private ColorListModel color_model;
    private Gtk.SelectionModel selection_model;
    private Gtk.SignalListItemFactory simple_color_factory;
    private Gtk.SignalListItemFactory detailed_color_factory;
    private Gtk.MultiSorter multi_sorter;

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/gtk4_list_colors/styles/listview_colors.css");
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_USER);

        /* create model with the default color numbers */
        color_model = new ColorListModel (4096);
        selection_model = new Gtk.MultiSelection (color_model);

        simple_color_factory = new Gtk.SignalListItemFactory ();
        simple_color_factory.setup.connect (setup_simple_color_factory);
        simple_color_factory.bind.connect (bind_simple_color_factory);

        detailed_color_factory = new Gtk.SignalListItemFactory ();
        detailed_color_factory.setup.connect (setup_detailed_color_factory);
        detailed_color_factory.bind.connect (bind_detailed_color_factory);

        sw = new Gtk.ScrolledWindow ();
        sw.hscrollbar_policy = Gtk.PolicyType.NEVER;

        grid_view = new Gtk.GridView (selection_model, simple_color_factory);
        grid_view.enable_rubberband = true;
        grid_view.max_columns = 24;
        grid_view.hscroll_policy = grid_view.vscroll_policy = Gtk.ScrollablePolicy.NATURAL;

        sw.set_child (grid_view);
        sw.set_parent (this);
    }
    public ColorGridWidget () {
    }

    /** Update the underling color listmodel size */
    public void update_list_size (uint new_size) {
        color_model.size = new_size;
        // grid_view.queue_draw ();
        // this.queue_draw ();
    }

    public void update_show_details (bool details = false) {
        if (details == false) {
            grid_view.factory = simple_color_factory;
        } else {
            grid_view.factory = detailed_color_factory;
        }
    }

    public void update_sort_by (Gtk4Demo.SortBy param) {
        
    }

    protected override void dispose () {
        sw.unparent ();
        base.dispose ();
    }

    void setup_simple_color_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var pic = new Gtk.Picture ();
        // pic.set_size_request (32, 32);

        list_item.set_child (pic);
    }

    void bind_simple_color_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var color_item = list_item.get_item () as ColorWidget;
        var pic = list_item.get_child () as Gtk.Picture;
        pic.set_paintable (color_item);
    }

    void setup_detailed_color_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var pic = new Gtk.Picture ();
        var name_label = new Gtk.Label (null);
        var rgb_label = new Gtk.Label (null);
        rgb_label.use_markup = true;
        var hsv_label = new Gtk.Label (null);
        hsv_label.use_markup = true;

        box.append (name_label);
        box.append (pic);
        box.append (rgb_label);
        box.append (hsv_label);

        list_item.set_child (box);
    }

    void bind_detailed_color_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var box = (Gtk.Box)list_item.get_child ();
        var color_item = (ColorWidget)list_item.get_item ();

        var label = (Gtk.Label)box.get_first_child ();
        label.label = color_item.color_name;

        var pic = (Gtk.Picture)label.get_next_sibling ();
        pic.set_paintable (color_item);

        var rgb_label = (Gtk.Label)pic.get_next_sibling ();
        rgb_label.label = color_item.get_rgb_markup ();

        var hsv_label = (Gtk.Label)rgb_label.get_next_sibling ();
        hsv_label.label = color_item.get_hsv_markup ();
    }
}

public enum Gtk4Demo.SortBy {
    UNSORTED,
    NAME,
    RED,
    GREEN,
    BLUE,
    RGB,
    HUE,
    SATURAION,
    VALUE,
    HSV
}
