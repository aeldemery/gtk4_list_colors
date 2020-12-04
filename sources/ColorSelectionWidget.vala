public class Gtk4Demo.ColorSelectionWidget : Gtk.Widget {
    private Gtk.SortListModel sort_model;
    private Gtk.SelectionModel selected_model;
    private Gtk.GridView selection_view;
    private Gtk.Revealer revealer;
    private Gtk.Box box;
    private Gtk.Label selection_size_label;
    private Gtk.ProgressBar progress;
    private Gtk.Picture selection_average_pic;

    /** Property if this widget is revealed */
    public bool selection_shown {
        get {
            return revealer.child_revealed;
        }
        set {
            revealer.set_reveal_child (value);
        }
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        revealer = new Gtk.Revealer ();
        progress = new Gtk.ProgressBar ();

        progress.hexpand = true;
        progress.valign = Gtk.Align.START;

        var grid = new Gtk.Grid ();
        with (grid) {
            margin_bottom = margin_end = margin_start = margin_top = row_spacing = column_spacing = 10;
        }

        var label = new Gtk.Label ("Selections");
        label.add_css_class ("title-3");
        label.hexpand = true;

        grid.attach (label, 0, 0, 5, 1);

        var sw = new Gtk.ScrolledWindow ();
        sw.hexpand = true;
        sw.hscrollbar_policy = Gtk.PolicyType.NEVER;
        sw.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

        grid.attach (sw, 0, 1, 5, 1);
        grid.attach (new Gtk.Label ("Size: "), 0, 2, 1, 1);
        grid.attach (new Gtk.Label ("Average: "), 2, 2, 1, 1);

        var dummy_label = new Gtk.Label ("");
        dummy_label.hexpand = true;
        grid.attach (dummy_label, 4, 2, 1, 1);

        selection_size_label = new Gtk.Label ("0");
        grid.attach (selection_size_label, 1, 2, 1, 1);

        selection_average_pic = new Gtk.Picture ();
        selection_average_pic.set_size_request (32, 32);
        grid.attach (selection_average_pic, 3, 2, 1, 1);

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_selection_factory_cb);
        /* we will initiate the model from the sort_model passed to us in the constructor */
        selection_view = new Gtk.GridView (null, factory);
        selection_view.add_css_class ("compact");
        selection_view.max_columns = 100;
        sw.set_child (selection_view);

        revealer.child = grid;
        
        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (progress);
        box.append (revealer);

        box.set_parent (this);
    }

    public ColorSelectionWidget (Gtk.SortListModel sort_model, Gtk.SelectionModel selected_model) {
        this.sort_model = sort_model;
        this.selected_model = selected_model;

        var filtered_items = new Gtk.SelectionFilterModel (selected_model);
        filtered_items.items_changed.connect (update_selected_count);
        filtered_items.items_changed.connect (update_selected_average);
        var no_selection = new Gtk.NoSelection (filtered_items);

        selection_view.model = no_selection;

        sort_model.incremental = true;
        sort_model.notify["pending"].connect (update_progress_cb);
    }

    public void toggle_show_selections () {
        if (revealer.child_revealed) {
            revealer.set_reveal_child (false);
        } else {
            revealer.set_reveal_child (true);
        }
    }

    protected override void dispose () {
        box.unparent ();
        base.dispose ();
    }

    void update_progress_cb (GLib.Object obj, GLib.ParamSpec pspec) {
        var model = (Gtk.SortListModel)obj;
        var total = uint.max (model.get_n_items (), 1);
        var pending = model.get_pending ();

        progress.visible = pending != 0;
        progress.fraction = (total - pending) / (double) total;
    }

    void update_selected_count (GLib.ListModel model, uint position, uint removed, uint added) {
        selection_size_label.label = model.get_n_items ().to_string ();
    }

    void update_selected_average (GLib.ListModel model, uint position, uint removed, uint added) {
        Gdk.RGBA c = { 0, 0, 0, 1 };
        var num = model.get_n_items ();

        for (int i = 0; i < num; i++) {
            var color = (ColorWidget) model.get_item (i);

            c.red += color.red;
            c.green += color.green;
            c.blue += color.blue;
        }

        var average = new ColorWidget ("", c.red / num, c.green / num, c.blue / num);
        selection_average_pic.paintable = average;
    }

    void setup_selection_factory_cb (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        /*
         * If we use expressions we don't need to add a bind callback,
         * the expression bind properties form the returned item form the model with our created child.
         */
        var item_expression = new Gtk.ConstantExpression.for_value (list_item);
        var color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), item_expression, "item");

        var pic = new Gtk.Picture ();
        pic.set_size_request (8, 8);

        color_expression.bind (pic, "paintable", null);
        list_item.set_child (pic);
    }
}