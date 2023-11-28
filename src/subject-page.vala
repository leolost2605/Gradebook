public class SubjectPage : Gtk.Box {
    public Subject subject { get; construct; }

    public SubjectPage (Subject subject) {
        Object (subject: subject);
    }

    construct {
        var menu = new Menu ();
        var menu_section1 = new Menu ();
        var menu_section2 = new Menu ();
        menu.append_section (null, menu_section1);
        menu.append_section (null, menu_section2);

        var preferences_item = new MenuItem (_("_Help"), "app.help");
        menu_section1.append_item (preferences_item);

        var about_item = new MenuItem (_("_About Gradebook"), "app.about");
        menu_section2.append_item (about_item);

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            menu_model = menu
        };

        var toggle_button = new Gtk.ToggleButton () {
            icon_name =  "dock-left-symbolic",
            tooltip_text = _("Toggle Sidebar"),
            visible = false
        };
        // toggle_button.bind_property ("active", ((Window) get_root ()).split_view, "show_sidebar", BindingFlags.BIDIRECTIONAL);
        // ((Window) get_root ()).bpoint.add_setter (toggle_button, "visible", true);

        // var new_menu_button = new Gtk.Button () {
        //     icon_name = "list-add-symbolic",
        //     action_name = "app.newsubject",
        //     tooltip_text = _("Add a New Subject")
        // };

        var edit_subject_button = new Gtk.Button () {
            icon_name = "document-edit-symbolic"
        };

        var header_bar = new Adw.HeaderBar ();
        header_bar.pack_end (menu_button);
        header_bar.pack_end (edit_subject_button);

        header_bar.pack_start (toggle_button);
        // header_bar.pack_start (new_menu_button);

        //SUBJECT BOX
        var nyttbox = new Gtk.Box (VERTICAL, 0) {
            vexpand = true,
            margin_start = 1,
            margin_end = 1
        };
        var gtk_sw = new Gtk.ScrolledWindow ();
        var adw_c = new Adw.Clamp () {
            margin_start = 19,
            margin_end = 19,
            margin_top = 20,
            margin_bottom = 20,
            maximum_size = 600,
            tightening_threshold = 400
        };
        gtk_sw.set_child (adw_c);
        adw_c.set_child (nyttbox);

        //TOP BOX
        var top_box = new Gtk.Box (HORIZONTAL, 0) {
            height_request = 40,
            hexpand = true,
            homogeneous = true
        };
        nyttbox.append (top_box);

        //AVERAGE LABEL
        var average_box = new Gtk.Box (HORIZONTAL, 10) {
            halign = START
        };
        top_box.append (average_box);

        var average_label = new Gtk.Label (_("Average:")) { css_classes = { "title-3" } };
        average_box.append (average_label);

        var avg_label = new Gtk.Label ("0.00") { css_classes = { "title-3" } };
        average_box.append (avg_label);

        //NEW GRADE BUTTON
        var new_grade_button = new NewGradeButton (0) {
            icon_name = "add-list-symbolic"
        };
        new_grade_button.halign = END;
        new_grade_button.label = _("New Grade…");
        new_grade_button.add_css_class ("suggested-action");
        new_grade_button.add_css_class ("pill");

        top_box.append (new_grade_button);

        var toolbar_view = new Adw.ToolbarView () {
            hexpand = true,
            content = gtk_sw
        };
        toolbar_view.add_top_bar (header_bar);
        append (toolbar_view);
        // window_grade_rows_ui (i, nyttbox);

        //add SUBJECT BOX to stackpage
        // stack.add_titled (subject_boxes[i], subjects[i].name, subjects[i].name);


        //CONNECT BUTTONS
        // new_grade_button.clicked.connect (() => {
        //     // new_grade_dialog (new_grade_button.index);
        // });

        // edit_subject_button.clicked.connect (() => {
        //     // edit_subject_dialog (edit_subject_button.index);
        // });
    }
}
