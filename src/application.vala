public class MyApp : Adw.Application {
    private int number_of_subjects = 20;
    private Subject[] subjects;
    private Adw.ToolbarView[] subject_boxes;
    private Window main_window;
    private Gtk.Label[] avg;
    private Gtk.ToggleButton toggle_button;
    private Gtk.Box[] nyabox;
    private EditSubjectButton edit_subject_button;



    public MyApp () {
        Object (
            application_id: "io.github.leolost2605.gradebook",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }



    construct {
        ActionEntry[] action_entries = {
            { "test", this.on_test_action },
            { "help", this.on_help_action },
            { "about", this.on_about_action },
            { "newsubject", this.on_newsubject_action},
        };
        this.add_action_entries (action_entries, this);
    }




    public void on_test_action () {
        print ("test_action");
    }


    public void on_help_action () {
            Gtk.show_uri (main_window, "https://github.com/leolost2605/Gradebook/wiki", 0);
        }




    public void on_newsubject_action () {
        var dialog = new NewSubjectDialog (main_window);
        dialog.close_request.connect (() => {
            if (dialog.accept) {
                new_subject (dialog.name_entry_box.get_text (), dialog.categories);
            }
            dialog.destroy ();
 	    return true;
        });
        dialog.present ();
    }




    public void on_about_action () {
        var about_window = new Adw.AboutWindow () {
            developer_name = "Leonhard Kargl",
            developers = {"Leonhard Kargl", "ConfusedAlex", "skøldis <gradebook@turtle.garden>"},
            artists = {"Brage Fuglseth"},
            translator_credits = _("translator-credits"),
            application_name = _("Gradebook"),
            application_icon = "io.github.leolost2605.gradebook",
            version = "1.1.1",
            license_type = GPL_3_0,
            website = "https://github.com/leolost2605/Gradebook",
            issue_url = "https://github.com/leolost2605/Gradebook/issues",
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


    public void read_data () {
            subjects = new Subject[number_of_subjects];

            for (int i = 0; i < subjects.length && FileUtils.test (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i", FileTest.EXISTS); i++) {
                    File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

                    var parser = new SubjectParser ();
                    Subject sub = parser.to_object (read_from_file (file));
                    subjects[i] = sub;
                }

        }

    public void write_data () {
        int z = 0;
            File dir = File.new_for_path (Environment.get_user_data_dir () + "/gradebook/savedata/");
            if (!dir.query_exists ()) {
                try {
                    dir.make_directory_with_parents ();
                    } catch (Error e) {
                            print (e.message);
                        }
                }
            for (int i = 0; i < subjects.length && subjects[i] != null; i++) {
                    var parser = new SubjectParser ();
                    File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

                    write_to_file (file, parser.to_string (subjects[i]));
                    z = i + 1;
                }
            for (int i = z; i < subjects.length && FileUtils.test (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i", FileTest.EXISTS); i++) {
                    File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

                    try {
                        file.delete ();
                    } catch (Error e) {
                            print (e.message);
                    }
                }
            main_window.destroy ();
        }



    public void new_grade (int index, string grade, string note, int c) {
        bool worked = false;

        for (int i = 0; i < subjects[index].grades.length; i++) {
            if (subjects[index].grades[i] == null) {
                subjects[index].grades[i] = new Grade (grade, note, c);
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

        if (subjects[index].categories[0] != null){
        var dialog = new NewGradeDialog (main_window, subjects, index);

        dialog.response.connect ((response_id) => {
            if (response_id == "add") {
		dialog.set_variables ();
                new_grade (index, dialog.get_grade (), dialog.get_note (), (int) dialog.choose_cat_row.get_selected ());
            }
            dialog.destroy ();
        });
        dialog.present ();
        } else {
                var ErrorDialog = new Adw.MessageDialog (main_window, _("Error"), _("This subject has no categories. Add at least one category in order to add a grade."));
                ErrorDialog.add_css_class ("error");
                ErrorDialog.add_response ("ok", _("OK"));
                ErrorDialog.present ();
            }
    }



    public void edit_subject_dialog (int index) {
        var dialog = new EditSubjectDialog (main_window, subjects[index], this);

        dialog.close_request.connect ((response_id) => {
            if (dialog.accept) {
                if (dialog.subject != null) {
                        subjects[index] = dialog.subject;
                } else {
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
            }
            dialog.destroy ();
 	    return true;
        });
        dialog.present ();
    }




    public void window_stack_ui (int index) {}
 //        /*if (stack_box.get_last_child ().get_type () == typeof(Adw.ToolbarView)) {
 //            stack_box.remove (stack_box.get_last_child());
 //        }*/
 //        stack = new Gtk.Stack ();

	// debug (subjects[0].name);
 //        if (subjects[0].name == null) {
	// 	    var stack_box = new Adw.ToolbarView ();
	// 	    var header_bar = new Adw.HeaderBar ();

	// 	    //PRIMARY MENU
 //        	var menu_button = new Gtk.MenuButton () {
 //        	    icon_name = "open-menu-symbolic"
 //        	};
 //        	header_bar.pack_end (menu_button);

 //        	var menu = new Menu ();
 //        	var menu_section1 = new Menu ();
 //        	var menu_section2 = new Menu ();
 //        	menu.append_section (null, menu_section1);
 //        	menu.append_section (null, menu_section2);

 //        	var preferences_item = new MenuItem (_("_Help"), "app.help");
 //        	menu_section1.append_item (preferences_item);

 //        	var about_item = new MenuItem (_("_About Gradebook"), "app.about");
 //        	menu_section2.append_item (about_item);


 //        	var menu_popover = new Gtk.PopoverMenu.from_model (menu);
 //        	menu_button.set_popover (menu_popover);

 //     		toggle_button = new Gtk.ToggleButton () {
	// 		    icon_name =  "dock-left-symbolic",
	// 		    tooltip_text = _("Toggle Sidebar"),
	// 		    visible = false
	// 	    };
	// 	    toggle_button.bind_property ("active", main_box, "show_sidebar", BindingFlags.BIDIRECTIONAL);
	// 	    bpoint.add_setter (toggle_button, "visible", true);

	// 	    header_bar.pack_start (toggle_button);

 //        	var new_menu_button = new Gtk.Button () {
 //        	    icon_name = "list-add-symbolic",
 //        	    action_name = "app.newsubject",
 //        	    tooltip_text = _("Add a New Subject")
 //        	};

 //        	header_bar.pack_start (new_menu_button);

 //        	stack_box.add_top_bar (header_bar);

 //        	 var placeholderlabel = new Adw.StatusPage () {
	// 		vexpand = true,
	// 		hexpand = true,
	// 		title = _("No Subjects"),
	// 		description =  _("Add new subjects using the “+” button in the top left corner.")
	// 	    };
 //    		stack_box.set_content (placeholderlabel);
 //        	    stack.add_titled (stack_box , "no_subjects_placeholder", _("Gradebook"));
 //        } else {

 //        //Create StackPages for every subject
 //        for(    int i = 0; subjects[i] != null; i++)
 //        {

	// subject_boxes[i] = new Adw.ToolbarView ();
	// var header_bar = new Adw.HeaderBar ();

	// 		//PRIMARY MENU
 //        var menu_button = new Gtk.MenuButton () {
 //            icon_name = "open-menu-symbolic"
 //        };
 //        header_bar.pack_end (menu_button);

 //        var menu = new Menu ();
 //        var menu_section1 = new Menu ();
 //        var menu_section2 = new Menu ();
 //        menu.append_section (null, menu_section1);
 //        menu.append_section (null, menu_section2);

 //        var preferences_item = new MenuItem (_("_Help"), "app.help");
 //        menu_section1.append_item (preferences_item);

 //        var about_item = new MenuItem (_("_About Gradebook"), "app.about");
 //        menu_section2.append_item (about_item);


 //        var menu_popover = new Gtk.PopoverMenu.from_model (menu);
 //        menu_button.set_popover (menu_popover);

 // 	toggle_button = new Gtk.ToggleButton () {
	// 	icon_name =  "dock-left-symbolic",
	// 	tooltip_text = _("Toggle Sidebar"),
	// 	visible = false
	// };
	// toggle_button.bind_property ("active", main_box, "show_sidebar", BindingFlags.BIDIRECTIONAL);
	// bpoint.add_setter (toggle_button, "visible", true);

	// header_bar.pack_start (toggle_button);

 //        var new_menu_button = new Gtk.Button () {
 //            icon_name = "list-add-symbolic",
 //            action_name = "app.newsubject",
 //            tooltip_text = _("Add a New Subject")
 //        };

 //        header_bar.pack_start (new_menu_button);

	// // edit subject button
	// edit_subject_button = new EditSubjectButton () {
 //            icon_name = "document-edit-symbolic"
 //        };
 // 	header_bar.pack_end (edit_subject_button);

	// subject_boxes[i].add_top_bar (header_bar);

 //            //SUBJECT BOX
 //            var nyttbox = new Gtk.Box (VERTICAL, 0) {
 //                vexpand = true,
 //                margin_start = 1,
 //                margin_end = 1
 //            };
	//     var gtk_sw = new Gtk.ScrolledWindow ();
 //    	    var adw_c = new Adw.Clamp () {
	// 	margin_start = 19,
	// 	margin_end = 19,
	// 	margin_top = 20,
	// 	margin_bottom = 20,
	// 	maximum_size = 600,
	// 	tightening_threshold = 400
	//     };
 //    	    gtk_sw.set_child (adw_c);
 //            adw_c.set_child (nyttbox);

 //            //TOP BOX
 //            var top_box = new Gtk.Box (HORIZONTAL, 0) {
 //                height_request = 40,
 //                hexpand = true,
 //                homogeneous = true
 //            };
 //            nyttbox.append (top_box);

 //            //AVERAGE LABEL
 //            var average_box = new Gtk.Box (HORIZONTAL, 10) {
 //                halign = START
 //            };
 //            top_box.append (average_box);

 //            var average_label = new Gtk.Label (_("Average:")) { css_classes = { "title-3" } };
 //            average_box.append (average_label);

 //            avg[i] = new Gtk.Label ("0.00") { css_classes = { "title-3" } };
 //            average_box.append (avg[i]);



 //            //NEW GRADE BUTTON
 //            var new_grade_button = new NewGradeButton (i) {
 //                icon_name = "add-list-symbolic"
 //            };
 //            new_grade_button.halign = END;
 //            new_grade_button.label = _("New Grade…");
 //            new_grade_button.add_css_class ("suggested-action");
 // 	    new_grade_button.add_css_class ("pill");

 //            top_box.append (new_grade_button);


 //            /*//FILL BOX
 //            var fill_box = new Gtk.Box (VERTICAL, 0) {
 //                margin_end = 20,
 //                margin_start = 20,
 //                vexpand = true,
 //                hexpand = true
 //            };
 //            subject_boxes[i].append (fill_box);

 //            //DELETE SUBJECT BUTTON
 //            var bottom_box = new Gtk.Box (HORIZONTAL, 0) {
 //                margin_end = 20,
 //                margin_start = 20,
 //                margin_bottom = 20,
 //                hexpand = true,
 //                homogeneous = true
 //            };
 //            subject_boxes[i].append (bottom_box);

 //            var bottom_end_box = new Gtk.Box (HORIZONTAL, 0) {halign = END};
 //            bottom_box.append (bottom_end_box);*/

 //            //CALL LISTBOX WITH GRADES

 //            subject_boxes[i].set_content (gtk_sw);
 //            window_grade_rows_ui (i, nyttbox);
 // 	    nyabox[i] = nyttbox;


 //            //add SUBJECT BOX to stackpage
 //            stack.add_titled (subject_boxes[i], subjects[i].name, subjects[i].name);


 //            //CONNECT BUTTONS
 //            new_grade_button.clicked.connect (() => {
 //                new_grade_dialog (new_grade_button.index);
 //            });

 // 	    edit_subject_button.index = i;

 //            edit_subject_button.clicked.connect (() => {
 //                edit_subject_dialog (edit_subject_button.index);
 //            });


    //     }

    //     stack.set_visible_child_name (subjects[index].name);

    //     }
    // }





    public Gtk.Box window_grade_rows_ui (int i, Gtk.Box? nyttbox = null) {
	nyttbox = nyttbox ?? nyabox[i];
        if ((nyttbox.get_first_child ().get_next_sibling ().name == "GtkListBox") || (nyttbox.get_first_child ().get_next_sibling ().name == "AdwStatusPage")) {
            nyttbox.remove (nyttbox.get_first_child ().get_next_sibling ());
	}


        int[] average = new int[subjects[i].categories.length];
        double[] number_of_grades = new double[subjects[i].categories.length];
        double[] avg_calculated = new double[subjects[i].categories.length];
        double final_avg = 0.00;

        //LIST BOX
        if (subjects[i].grades[0] == null) {
            var adw_page = new Adw.StatusPage () {
                title = _("No Grades"),
                description = _("Add new grades by clicking the “New Grade…” button."),
                vexpand = true
            };
 	    nyttbox.append (adw_page);
 	    return nyttbox;
        } else {

	var list_box = new Gtk.ListBox () {vexpand = false, margin_top = 20};
        list_box.add_css_class ("boxed-list");
        //list_box.set_sort_func (sort_list);
        //list_box.set_filter_func (filter_list);
        nyttbox.append (list_box);

        for (int j = 0; subjects[i].grades[j] != null; j++) {
            average[subjects[i].grades[j].cat] += int.parse (subjects[i].grades[j].grade);
            number_of_grades[subjects[i].grades[j].cat]++;



            //expander row
            var expander_row = new Adw.ActionRow ();
            expander_row.set_title (subjects[i].grades[j].grade.to_string ());
 	    if (subjects[i].grades[j].note == "") {
		expander_row.set_subtitle (subjects[i].categories[subjects[i].grades[j].cat].name);
	    } else {
            	expander_row.set_subtitle (subjects[i].categories[subjects[i].grades[j].cat].name + " — " + subjects[i].grades[j].note);
            }
            var delete_button = new DeleteButton (i, j);
            expander_row.add_suffix (delete_button);



            //put everything together
            list_box.append (expander_row);



            //CONNECT BUTTONS
            delete_button.clicked.connect (() => {
		Adw.MessageDialog msg = new Adw.MessageDialog (
			main_window,
			_("Delete Grade?"),
			_("If you delete this grade, its information will be deleted permanently.")
		);
		msg.add_response ("cancel", _("Cancel"));
                msg.add_response ("delete", _("Delete"));
		msg.set_response_appearance ("delete", DESTRUCTIVE);
		msg.set_close_response ("cancel");
		msg.response.connect ((response) => {
			if (response == "delete") {
				delete_grade (delete_button.subject_index, delete_button.grade_index);
			}
			msg.destroy ();
		});

		msg.present ();
            });
        }

        double percentage_divider = 0;

        for (int j = 0; j < subjects[i].categories.length && subjects[i].categories[j] != null; j++) {
            if (number_of_grades[j] != 0) {
                avg_calculated[j] = average[j] / number_of_grades[j];
                final_avg += avg_calculated[j] * subjects[i].categories[j].percentage;
                percentage_divider += subjects[i].categories[j].percentage;
            }
        }
        if (percentage_divider != 0) {
            string average_string = "%.2f".printf (final_avg / percentage_divider);
            avg[i].set_label (average_string);
        }

	 return nyttbox;
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


    protected override void activate () {
        main_window = new Window (this);

        //Variables
        // read_data ();

     	// window_stack_ui (0);

        //PRESENT WINDOW
        main_window.present ();


        main_window.close_request.connect (() => {
            main_window.set_visible (false);
            write_data ();
            return true;
        });
    }

    public static int main (string[] args)
    {
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);
        return new MyApp ().run (args);
    }
}
