public class MyApp : Adw.Application {
    private int filter_type = 0;
    private int sort_type = 0;

    public MyApp() {
        Object (
            application_id: "com.github.leolosttt.hello_gtk_vala",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    public int sort_list (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        //Adw.ExpanderRow awidget = row1.get_child ();
        return 0;
    }

    public bool filter_list (Gtk.ListBoxRow row) {
        //TO DO: replace with switch/case and first of all get it to work
        if(filter_type == 0) {
            return true;
        } else if(filter_type == 1) {
            if(row.get_index () == 0) {
                return false;
            } else {
                return true;
            }

        } else {
            return true;
        }

    }

    protected override void activate () {
        var main_window = new Adw.ApplicationWindow (this) {
            default_height = 400,
            default_width = 600,
            title = "Hello World"
        };

        //Variables
        Subject[] subjects = new Subject[20];
        Gtk.Box[] subject_boxes = new Gtk.Box[20];
        subjects[0] = new Subject ("Physical");
        subjects[0].grades[0] = new Grade (15, "12.23.2033", "My first object grade");

        //Declare main box
        var main_box = new Gtk.Box (VERTICAL, 1);

        //Create Header Bar and add to main box
        var header_bar = new Gtk.HeaderBar ();
        var header_label = new Gtk.Label ("Gradebook");
        header_bar.set_title_widget (header_label);
        var menu = new Gtk.MenuButton ();
        var testlabel = new Gtk.Label ("test");
        menu.set_popover (testlabel);
        header_bar.pack_end(menu);
        main_box.append(header_bar);

        //Create a second horizontal box for the stack and add to main box
        var stack_box = new Gtk.Box (HORIZONTAL, 1);
        stack_box.set_vexpand (true);
        stack_box.set_hexpand (true);
        main_box.append(stack_box);

        //Create Stack
        var stack = new Gtk.Stack ();
        stack_box.append (stack);

        //Create StackPages for every subject
        for(int i = 0; subjects[i] != null; i++)
        {
            //LIST BOX
            var list_box = new Gtk.ListBox ();
            list_box.set_margin_top (20);
            list_box.set_margin_end (20);
            list_box.set_margin_start (20);
            list_box.set_margin_bottom (20);
            list_box.set_hexpand (true);
            list_box.add_css_class("boxed-list");
            list_box.set_show_separators (false);
            list_box.set_sort_func (sort_list);
            list_box.set_filter_func (filter_list);

            //SUBJECT BOX
            subject_boxes[i] = new Gtk.Box (VERTICAL, 0);

            //add rows to LIST BOX
            for(int j = 0; subjects[i].grades[j] != null; j++) {
                //expander row
                var expander_row = new Adw.ExpanderRow ();
                expander_row.set_title (subjects[i].grades[j].grade.to_string ());
                expander_row.set_subtitle (subjects[i].grades[j].date);
                //subrow
                var subrow = new Adw.ActionRow ();
                subrow.set_title (subjects[i].grades[j].note);
                var edit_button = new Gtk.Button.with_label ("Edit");
                subrow.add_suffix (edit_button);
                //put everything together
                expander_row.add_row (subrow);
                list_box.append (expander_row);
            }

            //ADD LIST BOX TO SUBJECT BOX
            subject_boxes[i].append (list_box);

            //add SUBJECT BOX to stackpage
            stack.add_titled (subject_boxes[i], subjects[i].name, subjects[i].name);
        }

        //Create Stack Sidebar
        var sidebar = new Gtk.StackSidebar ();
        sidebar.set_stack (stack);
        sidebar.width_request = 200;
        stack_box.prepend(sidebar);

        //PRESENT WINDOW
        main_window.set_content (main_box);
        main_window.present ();
    }

    public static int main (string[] args)
    {
        return new MyApp ().run (args);
    }
}