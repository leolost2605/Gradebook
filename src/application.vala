public class MyApp : Adw.Application {
    private int filter_type = 0;
    private int sort_type = 0;
    private int number_of_subjects = 20;
    private Subject[] subjects;
    private Gtk.Box[] subject_boxes;
    private Adw.ApplicationWindow main_window;
    private Gtk.Label[] avg;
    private Gtk.Box main_box;



    public MyApp() {
        Object (
            application_id: "tech.landwatch.gradebook",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }



    construct {
        ActionEntry[] action_entries = {
            { "test", this.on_test_action },
            { "preferences", this.on_preferences_action },
            { "about", this.on_about_action },
            { "newsubject", this.on_newsubject_action}
        };
        this.add_action_entries (action_entries, this);
    }




    public void on_test_action () {
        print ("test_action");
    }




    public void on_newsubject_action () {
        var dialog = new NewSubjectDialog (main_window);
        dialog.response.connect ((rid) => {
            if(rid == Gtk.ResponseType.ACCEPT) {
                new_subject (dialog.name_entry.get_text ());
            }
            dialog.destroy();
        });
        dialog.present ();
    }




    public void on_preferences_action () {
        print ("prefrences");
    }




    public void on_about_action () {
        var about_window = new Gtk.AboutDialog () {
            //authors = "Leonhard Kargl",
            program_name = "Gradebook",
            comments = "My first project",
            copyright = "GPL something",
            license_type = GPL_3_0,
            modal = true,
            transient_for = main_window
        };
        about_window.present ();
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




    public void write_to_file (File file, string write_data)
    {
        uint8[] write_bytes = (uint8[]) write_data.to_utf8 ();

        try {
            file.replace_contents (write_bytes, null, false, FileCreateFlags.NONE, null, null);
        } catch (Error e) {
            print (e.message);
        }
    }




    public string read_from_file (File file)
    {
        try {
            string file_content = "";
            uint8[] contents;
            string etag_out;


            file.load_contents (null, out contents, out etag_out);

            file_content = (string) contents;

            return file_content;
        } catch (Error e) {
            print ("Error: %s\n", e.message);
        }
        return "-1";
    }




    public void read_data () {
        subjects = new Subject[number_of_subjects];

        for (int i = 0; i < subjects.length && FileUtils.test (@"savedata/subject$i/name", FileTest.EXISTS); i++) {
            File namefile = File.new_for_path (@"savedata/subject$i/name");

            if(read_from_file (namefile) != "") {
                subjects[i] = new Subject (read_from_file (namefile));

                for (int j = 0; j < subjects[i].grades.length && FileUtils.test (@"savedata/subject$i/grade$j", FileTest.EXISTS); j++) {
                   File gradefile = File.new_for_path (@"savedata/subject$i/grade$j");


                   string grade_obj_string = read_from_file (gradefile);

                    if (grade_obj_string != "") {
                        try {
                        //creating and loading Json Parser
                            Json.Parser parser = new Json.Parser ();
                            parser.load_from_data (grade_obj_string);


                            //creating Json Node
                            Json.Node grade_read_root = parser.get_root ();


                            //deserialize
                           subjects[i].grades[j] = Json.gobject_deserialize (typeof (Grade), grade_read_root) as Grade;


                        } catch (Error e) {
                        print ("Error: %s", e.message);
                        }
                    }
                }
            }
        }
    }




    async void write_data () throws ThreadError {
        ThreadFunc<bool> run = () => {
        for (int i = 0; i < subjects.length; i++) {
            try {
                File dirfile = File.new_for_path (@"savedata/subject$i");
                dirfile.make_directory();
            } catch (Error e) {
                if(e.code == 2) {

                } else {
                    print (e.message);
                }
            }

            File namefile = File.new_for_path (@"savedata/subject$i/name");

            //print ("%s \n", subjects[i].name);
            if(subjects[i] == null) {
                write_to_file (namefile, "");
                for (int j = 0; j < 20; j++) {
                    File gradefile = File.new_for_path (@"savedata/subject$i/grade$j");

                    write_to_file (gradefile, "");
                }
            } else {

                write_to_file (namefile, subjects[i].name);


                for (int j = 0; j < subjects[i].grades.length; j++) {
                    File gradefile = File.new_for_path (@"savedata/subject$i/grade$j");

                    if(subjects[i].grades[j] == null) {
                        write_to_file (gradefile, "");
                    } else {
                        Json.Node grade_save_root = Json.gobject_serialize (subjects[i].grades[j]);

                        //generator for string conversion
                        Json.Generator generator = new Json.Generator ();
                        generator.set_root (grade_save_root);

                        write_to_file (gradefile, generator.to_data (null));
                   }
                }
            }
        }
        main_window.destroy();
        return true;
        };
        new Thread<bool>("athread", run);

        yield;
    }




    public void new_grade (int index, string grade, int d, int m, int y, string note) {
        bool worked = false;


        for (int i = 0; i < subjects[index].grades.length; i++) {
            if (subjects[index].grades[i] == null) {
                subjects[index].grades[i] = new Grade (grade, d, m, y, note);
                i = subjects[index].grades.length;
                worked = true;
            }
        }


        if (worked == false) {
            print ("no more grades available");
        } else {
            window_grade_rows_ui (index);
        }
    }




    public void new_subject (string name) {
        bool worked = false;

        for (int i = 0; i < subjects.length; i++) {
            if (subjects[i] == null) {
                subjects[i] = new Subject (name);
                i = subjects.length;
                worked = true;
            }
        }

        if (worked == true) {
            window_stack_ui (0);
        } else {
            print ("No more subjects available!");
        }
    }




    public void new_grade_dialog (int index) {

        var dialog = new NewGradeDialog (main_window);

        dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT && dialog.set_variables ()) {
                new_grade (index, dialog.get_grade (), dialog.get_day (), dialog.get_month (), dialog.get_year (), dialog.get_note ());
            }
            dialog.destroy ();
        });
        dialog.present ();
    }




    public void window_stack_ui (int index) {
        if (main_box.get_last_child ().get_type () == typeof(Gtk.Box)) {
            main_box.remove (main_box.get_last_child());
        }
        var stack_box = new Gtk.Box (HORIZONTAL, 0) {
            vexpand = true,
            hexpand = true
        };
        var stack = new Gtk.Stack ();
        stack_box.append (stack);

        //Create StackPages for every subject
        for(int i = 0; subjects[i] != null; i++)
        {
            //SUBJECT BOX
            subject_boxes[i] = new Gtk.Box (VERTICAL, 0) {
                vexpand = true
            };

            
            //TOP BOX
            var top_box = new Gtk.Box (HORIZONTAL, 0) {
                margin_start = 20,
                margin_end = 20,
                margin_top = 20,
                height_request = 40,
                hexpand = true,
                homogeneous = true
            };
            subject_boxes[i].append (top_box);

            //AVERAGE LABEL
            var average_box = new Gtk.Box (HORIZONTAL, 10) {
                halign = START
            };
            top_box.append (average_box);

            var average_label = new Gtk.Label ("Your average:");
            average_box.append (average_label);

            avg[i] = new Gtk.Label ("0.00");
            average_box.append (avg[i]);



            //NEW GRADE BUTTON
            var new_grade_button = new NewGradeButton (i);
            new_grade_button.halign = END;
            new_grade_button.label = "+ New";
            new_grade_button.add_css_class ("suggested-action");

            top_box.append (new_grade_button);


            //FILL BOX
            var fill_box = new Gtk.Box (VERTICAL, 0) {
                margin_end = 20,
                margin_start = 20,
                vexpand = true,
                hexpand = true
            };
            subject_boxes[i].append (fill_box);

            //DELETE SUBJECT BUTTON
            var bottom_box = new Gtk.Box (HORIZONTAL, 0) {
                margin_end = 20,
                margin_start = 20,
                margin_bottom = 20,
                hexpand = true,
                homogeneous = true
            };
            subject_boxes[i].append (bottom_box);

            var delete_subject_button = new DeleteSubjectButton (i) {
                halign = END
            };
            delete_subject_button.add_css_class ("destructive-action");
            bottom_box.append (delete_subject_button);


            //CALL LISTBOX WITH GRADES
            window_grade_rows_ui (i);


            //add SUBJECT BOX to stackpage
            stack.add_titled (subject_boxes[i], subjects[i].name, subjects[i].name);


            //CONNECT BUTTONS
            new_grade_button.clicked.connect (() => {
                new_grade_dialog (new_grade_button.index);
            });

            delete_subject_button.clicked.connect (() => {
                delete_subject (delete_subject_button.index);
            });

            
        }

        stack.set_visible_child_name (subjects[index].name);

        //Create Stack Sidebar
        var sidebar = new Gtk.StackSidebar ();
        sidebar.set_stack (stack);
        sidebar.width_request = 200;
        stack_box.prepend(sidebar);

        main_box.append (stack_box);
    }
    




    public void window_grade_rows_ui (int i) {
        if (subject_boxes[i].get_first_child ().get_next_sibling ().name == "GtkScrolledWindow") {
            subject_boxes[i].remove (subject_boxes[i].get_first_child ().get_next_sibling ());
        }
        int average = 0;
        double number_of_grades = 0.0;
        double avg_calculated;

        var scroller = new Gtk.ScrolledWindow () {
            margin_bottom = 20,
            margin_end = 20,
            margin_start = 20,
            margin_top = 10,
            hexpand = true,
            propagate_natural_height = true
        };
        subject_boxes[i].insert_child_after (scroller, subject_boxes[i].get_first_child ());

        //LIST BOX
        var list_box = new Gtk.ListBox ();
        list_box.add_css_class("boxed-list");
        list_box.set_show_separators (false);
        list_box.set_sort_func (sort_list);
        list_box.set_filter_func (filter_list);
        scroller.set_child (list_box);

        if (subjects[i].grades[0] == null) {
            var action_row = new Adw.ActionRow () {
                title = "You didn't add any grades yet!"
            };
            list_box.append (action_row);
        }

        for(int j = 0; subjects[i].grades[j] != null; j++) {
            average += int.parse(subjects[i].grades[j].grade);
            number_of_grades++;



            //expander row
            var expander_row = new Adw.ExpanderRow ();
            expander_row.set_title (subjects[i].grades[j].grade.to_string ());
            expander_row.set_subtitle (subjects[i].grades[j].give_date ());


            //SUBROW
            var subrow = new Adw.ActionRow ();
            subrow.set_title (subjects[i].grades[j].note);

            //edit button
            var edit_button = new Gtk.Button.with_label ("Edit");
            subrow.add_suffix (edit_button);

            //delete button
            var delete_button = new DeleteButton ("Delete", i, j);
            subrow.add_suffix (delete_button);



            //put everything together
            expander_row.add_row (subrow);
            list_box.append (expander_row);



            //CONNECT BUTTONS
            delete_button.clicked.connect (() => {
                delete_grade (delete_button.subject_index, delete_button.grade_index);
            });
        }

        if(number_of_grades != 0) {
            avg_calculated = average / number_of_grades;
            string average_string = "%.2f".printf (avg_calculated);
            avg[i].set_label (average_string);
        }
    }




    public void delete_grade (int sub_index, int gra_index) {
        subjects[sub_index].grades[gra_index] = null;


        for (int i = gra_index; i < subjects[sub_index].grades.length - 1; i++) {
            subjects[sub_index].grades[i] = subjects[sub_index].grades[i + 1];
        }

        subjects[sub_index].grades[subjects[sub_index].grades.length - 1] = null;

        window_grade_rows_ui (sub_index);
    }




    public void delete_subject (int index) {
        subjects[index] = null;

        for (int i = index; i < subjects.length - 1; i++) {
            subjects[i] = subjects[i + 1];
        }

        subjects[subjects.length - 1] = null;

        if (subjects[index] != null) {
            window_stack_ui (index);
        } else {
            window_stack_ui (index - 1);
        }
    }




    protected override void activate () {
        main_window = new Adw.ApplicationWindow (this) {
            default_height = 600,
            default_width = 900,
            title = "Hello World"
        };

        //Variables
        read_data ();
        subject_boxes = new Gtk.Box[number_of_subjects];
        avg = new Gtk.Label[number_of_subjects];



        //WINDOW UI -------------------------------------------------------------------------------------------------------------------------------
        //Declare main box
        main_box = new Gtk.Box (VERTICAL, 1);

        //HEADER BAR
        var header_bar = new Gtk.HeaderBar ();


        var header_label = new Gtk.Label ("Gradebook");
        header_bar.set_title_widget (header_label);

        //MENU
        var menu_button = new Gtk.MenuButton ();
        var menu = new Menu ();
        var menu_section1 = new Menu ();
        var menu_section2 = new Menu ();
        var menu_section3 = new Menu ();
        menu.append_section (null, menu_section1);
        menu.append_section (null, menu_section2);
        menu.append_section (null, menu_section3);


        var add_subject_item = new MenuItem ("+ Add a new subject", "app.newsubject");
        menu_section1.append_item (add_subject_item);

        var test = new MenuItem ("Test", "app.test");
        menu_section2.append_item (test);

        var preferences_item = new MenuItem ("Preferences", "app.preferences");
        menu_section2.append_item (preferences_item);

        var about_item = new MenuItem ("About", "app.about");
        menu_section3.append_item (about_item);


        var menu_popover = new Gtk.PopoverMenu.from_model (menu);
        menu_button.set_popover (menu_popover);


        header_bar.pack_start(menu_button);
        main_box.append(header_bar);


        window_stack_ui (0);
        
        //PRESENT WINDOW
        main_window.set_content (main_box);
        main_window.present ();


        main_window.close_request.connect (() => {
            main_window.set_visible (false);
            write_data.begin ( (obj, res) => {
                try {
                    write_data.end(res);
                } catch (Error e) {
                    print (e.message);
                }
            });
            return true;
        });
    }

    public static int main (string[] args)
    {
        return new MyApp ().run (args);
    }
}