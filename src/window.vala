public class Window : Adw.ApplicationWindow {
    public Adw.OverlaySplitView split_view;
    public Adw.Breakpoint bpoint;
    private Gtk.Stack stack;

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
        stack = new Gtk.Stack ();

        var new_subject_button = new Gtk.Button () {
            icon_name = "list-add-symbolic",
            action_name = "app.newsubject",
            tooltip_text = _("Add a New Subject")
        };

        var header_bar = new Adw.HeaderBar () { hexpand = true };
        header_bar.pack_end (new_subject_button);

        var stack_sidebar = new Gtk.StackSidebar () {
            stack = stack
        };
 	    stack_sidebar.set_css_classes ({ "" });

        var scrolled_window = new Gtk.ScrolledWindow () {
            vexpand = true,
            child = stack_sidebar
        };

        var sidebar = new Adw.ToolbarView () {
            content = scrolled_window
        };
        sidebar.add_top_bar (header_bar);

        split_view = new Adw.OverlaySplitView () {
            sidebar = sidebar,
            content = stack
        };

        bpoint = new Adw.Breakpoint (Adw.BreakpointCondition.parse ("max-width: 530px"));
        bpoint.add_setter (split_view, "show_sidebar", false);
        bpoint.add_setter (split_view, "collapsed", true);
        add_breakpoint (bpoint);

        content = split_view;

        var subject_manager = SubjectManager.get_default ();

        subject_manager.read_data ();

        foreach (var subject in subject_manager.subjects.get_values ()) {
            subject.notify["deleted"].connect (() => {
                if (subject.deleted) {
                    //TODO: Remove without crash
                }
                warning ("removed");
            });
            stack.add_titled (new SubjectPage (subject), subject.name, subject.name);
        }

        close_request.connect (() => {
            set_visible (false);
            subject_manager.write_data ();
            return true;
        });
    }
}
