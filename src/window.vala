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

     	var header_bar = new Adw.HeaderBar () { hexpand = true };

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

     	stack.add_titled (new SubjectPage (new Subject ("English")), "English", "English");
    }
}
