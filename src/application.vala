public class MyApp : Adw.Application {
    private int number_of_subjects = 20;
    private Subject[] subjects;
    private Gtk.Box[] subject_boxes;
    private Adw.ApplicationWindow main_window;
    private Gtk.Label[] avg;
    private Gtk.Box main_box;



    public MyApp() {
        Object (
            application_id: "io.github.leolost2605.gradebook",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }



    construct {
        ActionEntry[] action_entries = {
            { "test", this.on_test_action },
            { "preferences", this.on_preferences_action },
            { "help", this.on_help_action },
            { "about", this.on_about_action },
            { "newsubject", this.on_newsubject_action}
        };
        this.add_action_entries (action_entries, this);
    }




    public void on_test_action () {
        print ("test_action");
    }


    public void on_help_action () {
            Gtk.show_uri(main_window, "https://google.com", 0);
        }




    public void on_newsubject_action () {
        var dialog = new NewSubjectDialog (main_window);
        dialog.response.connect ((rid) => {
            if(rid == Gtk.ResponseType.ACCEPT) {
                new_subject (dialog.name_entry.get_text (), dialog.categories);
            }
            dialog.destroy();
        });
        dialog.present ();
    }




    public void on_preferences_action () {
        print ("prefrences");
    }




    public void on_about_action () {
        var about_window = new Adw.AboutWindow () {
            developer_name = "Leonhard Kargl",
            application_name = "Gradebook",
            comments = "A simple app to keep track of your grades!",
            version = "0.2",
            license_type = GPL_3_0,
            website = "https://github.com/leolost2605/Gradebook",
            modal = true,
            transient_for = main_window
        };
        about_window.present ();
    }



    /*
    public int sort_list (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        //Adw.ExpanderRow awidget = row1.get_child ();
        return 0;
    }*/



    /*
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

    }*/




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


    public void read_data() {
            subjects = new Subject[number_of_subjects];

            for (int i = 0; i < subjects.length && FileUtils.test (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i", FileTest.EXISTS); i++) {
                    File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

                    var parser = new SubjectParser();
                    Subject sub = parser.to_object(read_from_file(file));
                    subjects[i] = sub;
                }

        }

    public void write_data () {
        int z = 0;
            File dir = File.new_for_path(Environment.get_user_data_dir () + "/gradebook/savedata/");
            if(!dir.query_exists ()) {
                try {
                    dir.make_directory_with_parents();
                    } catch (Error e) {
                            print(e.message);
                        }
                }
            for (int i = 0; i < subjects.length && subjects[i] != null; i++) {
                    var parser = new SubjectParser ();
                    File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

                    write_to_file (file, parser.to_string(subjects[i]));
                    z = i + 1;
                }
            for (int i = z; i < subjects.length && FileUtils.test (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i", FileTest.EXISTS); i++) {
                    File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

                    try {
                        file.delete ();
                    } catch (Error e) {
                            print(e.message);
                    }
                }
            main_window.destroy();
        }



    public void new_grade (int index, string grade, int d, int m, int y, string note, int c) {
        bool worked = false;


        for (int i = 0; i < subjects[index].grades.length; i++) {
            if (subjects[index].grades[i] == null) {
                subjects[index].grades[i] = new Grade (grade, d, m, y, note, c);
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




    public void new_subject (string name, Category[] c) {
        bool worked = false;

        for (int i = 0; i < subjects.length; i++) {
            if (subjects[i] == null) {
                subjects[i] = new Subject (name);
                subjects[i].categories = c;
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

        if(subjects[index].categories[0] != null){
        var dialog = new NewGradeDialog (main_window, subjects, index);

        dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT && dialog.set_variables ()) {
                new_grade (index, dialog.get_grade (), dialog.get_day (), dialog.get_month (), dialog.get_year (), dialog.get_note (), (int) dialog.choose_cat_row.get_selected ());
            }
            dialog.destroy ();
        });
        dialog.present ();
        } else {
                print("Error: this subjects has no categories!");
            }
    }



    public void edit_subject_dialog (int index) {
        var dialog = new EditSubjectDialog (main_window, subjects[index]);

        dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT) {
                subjects[index] = dialog.subject;
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

        if(subjects[0] == null) {
            stack.add_titled (new Gtk.Label (_("It's empty in here...\n \nAdd new subjects using the + in the top left corner!")) {vexpand = true, hexpand = true}, "no_subjects_placeholder", _("You haven't added any subjects yet!"));
        } else {

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

            var average_label = new Gtk.Label (_("Your average:"));
            average_box.append (average_label);

            avg[i] = new Gtk.Label ("0.00");
            average_box.append (avg[i]);



            //NEW GRADE BUTTON
            var new_grade_button = new NewGradeButton (i) {
                icon_name = "add-list-symbolic"
            };
            new_grade_button.halign = END;
            new_grade_button.label = _("+ New");
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

            var bottom_end_box = new Gtk.Box (HORIZONTAL, 0) {halign = END};
            bottom_box.append (bottom_end_box);

            var edit_subject_button = new EditSubjectButton (i) {margin_end = 20};
            bottom_end_box.append (edit_subject_button);

            var delete_subject_button = new DeleteSubjectButton (i);
            delete_subject_button.add_css_class ("destructive-action");
            bottom_end_box.append (delete_subject_button);


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

            edit_subject_button.clicked.connect (() => {
                edit_subject_dialog (edit_subject_button.index);
            });


        }

        stack.set_visible_child_name (subjects[index].name);

        }

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


        int[] average = new int[subjects[i].categories.length];
        double[] number_of_grades = new double[subjects[i].categories.length];
        double[] avg_calculated = new double[subjects[i].categories.length];
        double final_avg = 0.00;


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
        //list_box.set_sort_func (sort_list);
        //list_box.set_filter_func (filter_list);
        scroller.set_child (list_box);

        if (subjects[i].grades[0] == null) {
            var action_row = new Adw.ActionRow () {
                title = _("You haven't added any grades yet!")
            };
            list_box.append (action_row);
        }

        for(int j = 0; subjects[i].grades[j] != null; j++) {
            average[subjects[i].grades[j].cat] += int.parse(subjects[i].grades[j].grade);
            number_of_grades[subjects[i].grades[j].cat]++;



            //expander row
            var expander_row = new Adw.ExpanderRow ();
            expander_row.set_title (subjects[i].grades[j].grade.to_string ());
            expander_row.set_subtitle (subjects[i].grades[j].give_date () + " (" + subjects[i].categories[subjects[i].grades[j].cat].name + ")");


            //SUBROW
            var subrow = new Adw.ActionRow ();
            subrow.set_title (subjects[i].grades[j].note);

            //edit button
            //var edit_button = new Gtk.Button.with_label (_("Edit"));
            //subrow.add_suffix (edit_button);

            //delete button
            var delete_button = new DeleteButton (_("Delete"), i, j);
            subrow.add_suffix (delete_button);



            //put everything together
            expander_row.add_row (subrow);
            list_box.append (expander_row);



            //CONNECT BUTTONS
            delete_button.clicked.connect (() => {
                delete_grade (delete_button.subject_index, delete_button.grade_index);
            });
        }

        double percentage_divider = 0;

        for (int j = 0; j < subjects[i].categories.length && subjects[i].categories[j] != null; j++) {
            if(number_of_grades[j] != 0) {
                avg_calculated[j] = average[j] / number_of_grades[j];
                final_avg += avg_calculated[j] * subjects[i].categories[j].percentage;
                percentage_divider += subjects[i].categories[j].percentage;
            }
        }
        if(percentage_divider != 0) {
            string average_string = "%.2f".printf (final_avg / percentage_divider);
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
            title = "Gradebook"
        };

        //Variables
        read_data ();
        subject_boxes = new Gtk.Box[number_of_subjects];
        avg = new Gtk.Label[number_of_subjects];



        //WINDOW UI -------------------------------------------------------------------------------------------------------------------------------
        //Declare main box
        main_box = new Gtk.Box (VERTICAL, 1);
        main_window.set_content (main_box);

        //HEADER BAR
        var header_bar = new Gtk.HeaderBar ();
        main_box.append(header_bar);


        var header_label = new Gtk.Label ("Gradebook");
        header_bar.set_title_widget (header_label);

        //PRIMARY MENU
        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic"
        };
        header_bar.pack_end(menu_button);

        var menu = new Menu ();
        var menu_section1 = new Menu ();
        var menu_section2 = new Menu ();
        menu.append_section (null, menu_section1);
        menu.append_section (null, menu_section2);

        var preferences_item = new MenuItem (_("Help"), "app.help");
        menu_section1.append_item (preferences_item);

        var about_item = new MenuItem (_("About Gradebook"), "app.about");
        menu_section2.append_item (about_item);


        var menu_popover = new Gtk.PopoverMenu.from_model (menu);
        menu_button.set_popover (menu_popover);




        //NEW SUBJECT MENU
        var new_menu = new Menu ();
        var add_subject_menu_item = new MenuItem (_("Add a new subject"), "app.newsubject");
        new_menu.append_item (add_subject_menu_item);


        var new_popover = new Gtk.PopoverMenu.from_model (new_menu);

        var new_menu_button = new Gtk.MenuButton () {
            popover = new_popover,
            icon_name = "list-add-symbolic"
        };
        header_bar.pack_start (new_menu_button);


        window_stack_ui (0);
        
        //PRESENT WINDOW
        main_window.present ();


        main_window.close_request.connect (() => {
            main_window.set_visible (false);
            write_data();
            return true;
        });
    }

    public static int main (string[] args)
    {
        return new MyApp ().run (args);
    }
}
