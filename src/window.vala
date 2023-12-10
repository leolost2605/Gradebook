public class Window : Adw.ApplicationWindow {
    public Adw.OverlaySplitView split_view;
    public Adw.Breakpoint bpoint;
    private SubjectPage subject_page;

    public Window (MyApp app) {
        Object (
            default_height: 600,
            default_width: 900,
            width_request: 360,
            height_request: 360,
            title: _("Gradebook"),
            application: app
        );
    }

    construct {
        var subject_manager = SubjectManager.get_default ();

        var new_subject_button = new Gtk.Button () {
            icon_name = "list-add-symbolic",
            action_name = "app.newsubject",
            tooltip_text = _("Add a New Subject")
        };

        var header_bar = new Adw.HeaderBar () {
            hexpand = true
        };
        header_bar.pack_end (new_subject_button);

        var navigation_sidebar = new Gtk.ListBox ();
 	    navigation_sidebar.add_css_class ("navigation-sidebar");
 	    navigation_sidebar.bind_model (subject_manager.subjects, (obj) => {
 	        var sub = (Subject) obj;
 	        return new Gtk.Label (sub.name) { xalign = 0 };
 	    });

        var scrolled_window = new Gtk.ScrolledWindow () {
            vexpand = true,
            child = navigation_sidebar
        };

        var sidebar = new Adw.ToolbarView () {
            content = scrolled_window
        };
        sidebar.add_top_bar (header_bar);

        subject_page = new SubjectPage ();

        split_view = new Adw.OverlaySplitView () {
            sidebar = sidebar,
            content = subject_page
        };

        bpoint = new Adw.Breakpoint (Adw.BreakpointCondition.parse ("max-width: 530px"));
        bpoint.add_setter (split_view, "show_sidebar", false);
        bpoint.add_setter (split_view, "collapsed", true);
        add_breakpoint (bpoint);

        content = split_view;

        navigation_sidebar.row_activated.connect ((row) => {
            subject_page.subject = (Subject) subject_manager.subjects.get_item (row.get_index ());
        });

        subject_manager.subjects.items_changed.connect ((pos, rem, added) => {
            subject_page.subject = (Subject) subject_manager.subjects.get_item (pos);
        });

        subject_manager.read_data ();

        close_request.connect (() => {
            set_visible (false);
            subject_manager.write_data_new.begin (() => {
                destroy ();
            });
            return Gdk.EVENT_STOP;
        });
    }
}
