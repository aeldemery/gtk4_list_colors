public class Gtk4Demo.ColorGridWidget : Gtk.Widget {
    private Gtk.GridView grid_view;
    private Gtk.ScrolledWindow sw;

    private ColorListModel color_model;

    private Gtk.SelectionModel selection_model;

    private Gtk.SignalListItemFactory simple_color_factory;
    private Gtk.SignalListItemFactory detailed_color_factory;

    private Gtk.StringSorter name_sorter;
    private Gtk.NumericSorter red_sorter;
    private Gtk.NumericSorter green_sorter;
    private Gtk.NumericSorter blue_sorter;
    private Gtk.NumericSorter hue_sorter;
    private Gtk.NumericSorter saturation_sorter;
    private Gtk.NumericSorter value_sorter;

    private Gtk.SortListModel sort_list_model;

    private Gtk.MultiSorter rgb_sorter;
    private Gtk.MultiSorter hsv_sorter;
    private Gtk.MultiSorter unsorted;

    private Gtk.Expression expression;

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

        /* list item factory with simple color grid */
        simple_color_factory = new Gtk.SignalListItemFactory ();
        simple_color_factory.setup.connect (setup_simple_color_factory);
        simple_color_factory.bind.connect (bind_simple_color_factory);

        /* list item factory with detailed grid, i.e color name and values */
        detailed_color_factory = new Gtk.SignalListItemFactory ();
        detailed_color_factory.setup.connect (setup_detailed_color_factory);
        detailed_color_factory.bind.connect (bind_detailed_color_factory);

        sw = new Gtk.ScrolledWindow ();
        sw.hscrollbar_policy = Gtk.PolicyType.NEVER;

        /* An empty multisorter doesn't do any sorting and the sortmodel is
         * smart enough to know that.
         */
        unsorted = new Gtk.MultiSorter ();

        /* rgb_sorter will append different sortings mechanisms and apply them one by one
         *  i.e apply red sorter then green then blue to produce RGB sorter
         */
        rgb_sorter = new Gtk.MultiSorter ();

        /* expression will get the corresponding property on demand for each item */
        expression = new Gtk.PropertyExpression (typeof (ColorWidget), null, "color_name");
        name_sorter = new Gtk.StringSorter (expression);

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), null, "red");
        red_sorter = new Gtk.NumericSorter (expression);
        red_sorter.sort_order = Gtk.SortType.DESCENDING;
        rgb_sorter.append (red_sorter);

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), null, "green");
        green_sorter = new Gtk.NumericSorter (expression);
        green_sorter.sort_order = Gtk.SortType.DESCENDING;
        rgb_sorter.append (green_sorter);

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), null, "blue");
        blue_sorter = new Gtk.NumericSorter (expression);
        blue_sorter.sort_order = Gtk.SortType.DESCENDING;
        rgb_sorter.append (blue_sorter);

        hsv_sorter = new Gtk.MultiSorter ();

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), null, "hue");
        hue_sorter = new Gtk.NumericSorter (expression);
        hue_sorter.sort_order = Gtk.SortType.DESCENDING;
        hsv_sorter.append (hue_sorter);

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), null, "saturation");
        saturation_sorter = new Gtk.NumericSorter (expression);
        saturation_sorter.sort_order = Gtk.SortType.DESCENDING;
        hsv_sorter.append (saturation_sorter);

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), null, "value");
        value_sorter = new Gtk.NumericSorter (expression);
        value_sorter.sort_order = Gtk.SortType.DESCENDING;
        hsv_sorter.append (value_sorter);

        /* create a SortListModel and initialize it with the model and default sorting, i.e name_sorter */
        sort_list_model = new Gtk.SortListModel (color_model, name_sorter);
        /* without incremental sorting the UI will hangs for a long time if you sort 16 Million items */
        sort_list_model.incremental = true;

        /* Wrap the sort models in a selection models to pass it the GridView initializer */
        selection_model = new Gtk.MultiSelection (sort_list_model);

        grid_view = new Gtk.GridView (selection_model, simple_color_factory);
        grid_view.enable_rubberband = true;
        /* max columns has a performance penalty, so choose this according to the planed size of the list item */
        grid_view.max_columns = 20;
        grid_view.hscroll_policy = grid_view.vscroll_policy = Gtk.ScrollablePolicy.NATURAL;

        sw.set_child (grid_view);
        sw.set_parent (this);
    }
    public ColorGridWidget () {
    }

    /** Update the underling color listmodel size */
    public void update_list_size (uint new_size) {
        color_model.size = new_size;
    }

    /** Get the underlying model size */
    public uint get_list_size () {
        return color_model.size;
    }

    /** Update color grid to either show or hide the details  */
    public void update_show_details (bool details = false) {
        if (details == false) {
            grid_view.max_columns = 20;
            grid_view.factory = simple_color_factory;
        } else {
            grid_view.max_columns = 6;
            grid_view.factory = detailed_color_factory;
        }
    }

    /** Update the sorting mechanism */
    public void update_sort_by (Gtk4Demo.SortBy sortby) {
        switch (sortby) {
            case SortBy.UNSORTED:
                sort_list_model.sorter = unsorted;
                break;
            case SortBy.NAME:
                sort_list_model.sorter = name_sorter;
                break;
            case SortBy.RED:
                sort_list_model.sorter = red_sorter;
                break;
            case SortBy.GREEN:
                sort_list_model.sorter = green_sorter;
                break;
            case SortBy.BLUE:
                sort_list_model.sorter = blue_sorter;
                break;
            case SortBy.RGB:
                sort_list_model.sorter = rgb_sorter;
                break;
            case SortBy.HUE:
                sort_list_model.sorter = hue_sorter;
                break;
            case SortBy.SATURAION:
                sort_list_model.sorter = saturation_sorter;
                break;
            case SortBy.VALUE:
                sort_list_model.sorter = value_sorter;
                break;
            case SortBy.HSV:
                sort_list_model.sorter = hsv_sorter;
                break;
            default:
                assert_not_reached ();
        }
    }

    /**
     * Get the underlying SelectionModel, to be able to retrieve currently selected items.
     */
    public Gtk.SelectionModel get_selection_model () {
        return selection_model;
    }

    /**
     * Get the underlying SortListModel to be able to get the number of
     * pending items during incremental sorting.
     */
    public Gtk.SortListModel get_sort_list_model () {
        return sort_list_model;
    }

    protected override void dispose () {
        sw.unparent ();
        base.dispose ();
    }

    void setup_simple_color_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var pic = new Gtk.Picture ();
        list_item.set_child (pic);
    }

    void bind_simple_color_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var color_item = (ColorWidget) list_item.get_item ();
        var pic = (Gtk.Picture)list_item.get_child ();
        pic.set_paintable (color_item);
    }

    void setup_detailed_color_factory (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var pic = new Gtk.Picture ();

        var name_label = new Gtk.Label (null);
        name_label.ellipsize = Pango.EllipsizeMode.END;
        name_label.max_width_chars = 12;

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
        var color_item = (ColorWidget) list_item.get_item ();

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
