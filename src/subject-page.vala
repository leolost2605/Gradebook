public class SubjectPage : Gtk.Box {
    private Subject _subject;
    public Subject subject {
        get {
            return _subject;
        } set {
            if (_subject != null) {
                _subject.grades_model.items_changed.disconnect (on_items_changed);
            }

            _subject = value;
            _subject.grades_model.items_changed.connect (on_items_changed);
            list_box.bind_model (_subject.grades_model, widget_create_func);

            on_items_changed ();
        }
    }

    private Gtk.Label avg_label;
    private Gtk.Box content_box;
    private Gtk.ListBox list_box;
    private Adw.StatusPage status_page;

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

        var edit_subject_button = new Gtk.Button () {
            icon_name = "document-edit-symbolic"
        };

        var header_bar = new Adw.HeaderBar ();
        header_bar.pack_end (menu_button);
        header_bar.pack_end (edit_subject_button);

        header_bar.pack_start (toggle_button);

        //TOP BOX
        var top_box = new Gtk.Box (HORIZONTAL, 0) {
            height_request = 40,
            hexpand = true,
            homogeneous = true
        };

        //AVERAGE LABEL
        var average_box = new Gtk.Box (HORIZONTAL, 10) {
            halign = START
        };
        top_box.append (average_box);

        var average_label = new Gtk.Label (_("Average:")) { css_classes = { "title-3" } };
        average_box.append (average_label);

        avg_label = new Gtk.Label ("0.00") { css_classes = { "title-3" } };
        average_box.append (avg_label);

        //NEW GRADE BUTTON
        var new_grade_button = new Gtk.Button () {
            icon_name = "add-list-symbolic"
        };
        new_grade_button.halign = END;
        new_grade_button.label = _("New Grade…");
        new_grade_button.add_css_class ("suggested-action");
        new_grade_button.add_css_class ("pill");

        top_box.append (new_grade_button);

        status_page = new Adw.StatusPage () {
            title = _("No Grades"),
            description = _("Add new grades by clicking the “New Grade…” button."),
            vexpand = true
        };

	    list_box = new Gtk.ListBox () {vexpand = false, margin_top = 20};
        list_box.add_css_class ("boxed-list");

        content_box = new Gtk.Box (VERTICAL, 0) {
            vexpand = true,
            margin_start = 1,
            margin_end = 1
        };
        content_box.append (top_box);
        content_box.append (status_page);

        var adw_c = new Adw.Clamp () {
            margin_start = 19,
            margin_end = 19,
            margin_top = 20,
            margin_bottom = 20,
            maximum_size = 600,
            tightening_threshold = 400,
            child = content_box
        };

        var gtk_sw = new Gtk.ScrolledWindow () {
            child = adw_c
        };

        var toolbar_view = new Adw.ToolbarView () {
            hexpand = true,
            content = gtk_sw
        };
        toolbar_view.add_top_bar (header_bar);
        append (toolbar_view);

        new_grade_button.clicked.connect (new_grade_dialog);

        edit_subject_button.clicked.connect (() => {
            edit_subject_dialog ();
        });
    }

    private void calculate_average () {
        if (subject.grades_model.get_n_items () == 0) {
            avg_label.label = "0.00";
            return;
        }

        var table = new HashTable<string, double?> (str_hash, str_equal);
        var table2 = new HashTable<string, int?> (str_hash, str_equal);

        for (int i = 0; i < subject.grades_model.get_n_items (); i++) {
            var grade = (Grade) subject.grades_model.get_item (i);
            table[grade.category_name] = table[grade.category_name] == null ? double.parse (grade.grade) : table[grade.category_name] + double.parse (grade.grade);
            table2[grade.category_name] += table2[grade.category_name] == null ? 1 : table2[grade.category_name] + 1;
        }

        double percentage_divider = 0;
        double avg = 0;
        foreach (var cat in table.get_keys ()) {
            avg += (table[cat] / table2[cat]) * subject.categories_by_name[cat].percentage;
            percentage_divider += subject.categories_by_name[cat].percentage;
        }

        avg_label.label = "%.2f".printf (avg / percentage_divider);
    }

    private void on_items_changed () {
        if (subject.grades_model.get_n_items () > 0 && content_box.get_last_child () == status_page) {
            content_box.remove (status_page);
            content_box.append (list_box);
        } else if (subject.grades_model.get_n_items () == 0 && content_box.get_last_child () == list_box) {
            content_box.remove (list_box);
            content_box.append (status_page);
        }

        calculate_average ();
    }

    public void new_grade_dialog () {
        if (subject.categories_by_name.length > 0){
            var dialog = new NewGradeDialog ((Window) get_root (), subject);
            dialog.present ();
        } else {
            var ErrorDialog = new Adw.MessageDialog ((Window) get_root (), _("Error"), _("This subject has no categories. Add at least one category in order to add a grade."));
            ErrorDialog.add_css_class ("error");
            ErrorDialog.add_response ("ok", _("OK"));
            ErrorDialog.present ();
        }
    }

    public void edit_subject_dialog () {
        new EditSubjectDialog ((Window) get_root (), subject).present ();
    }

    private Gtk.Widget widget_create_func (Object obj) {
        var grade = (Grade) obj;

        var delete_button = new Gtk.Button () {
            icon_name = "user-trash-symbolic",
         	valign = CENTER
        };
        delete_button.add_css_class ("flat");

        var expander_row = new Adw.ActionRow ();
        expander_row.set_title (grade.grade.to_string ());
        expander_row.add_suffix (delete_button);

        if (grade.note == "") {
            expander_row.set_subtitle (grade.category_name);
        } else {
	        expander_row.set_subtitle (grade.category_name + " — " + grade.note);
        }

        delete_button.clicked.connect (() => {
		    Adw.MessageDialog msg = new Adw.MessageDialog (
			    (Window) get_root (),
			    _("Delete Grade?"),
			    _("If you delete this grade, its information will be deleted permanently.")
		    );
		    msg.add_response ("cancel", _("Cancel"));
            msg.add_response ("delete", _("Delete"));
		    msg.set_response_appearance ("delete", DESTRUCTIVE);
		    msg.set_close_response ("cancel");
		    msg.response.connect ((response) => {
			    if (response == "delete") {
				    subject.delete_grade (grade);
			    }
			    msg.destroy ();
		    });

		    msg.present ();
        });

        return expander_row;
    }



 //    public Gtk.Box window_grade_rows_ui (int i, Gtk.Box? nyttbox = null) {
	// nyttbox = nyttbox ?? nyabox[i];
 //        if ((nyttbox.get_first_child ().get_next_sibling ().name == "GtkListBox") || (nyttbox.get_first_child ().get_next_sibling ().name == "AdwStatusPage")) {
 //            nyttbox.remove (nyttbox.get_first_child ().get_next_sibling ());
	// }


 //        int[] average = new int[subjects[i].categories.length];
 //        double[] number_of_grades = new double[subjects[i].categories.length];
 //        double[] avg_calculated = new double[subjects[i].categories.length];
 //        double final_avg = 0.00;

 //        //LIST BOX
 //        if (subjects[i].grades[0] == null) {
 //            var adw_page = new Adw.StatusPage () {
 //                title = _("No Grades"),
 //                description = _("Add new grades by clicking the “New Grade…” button."),
 //                vexpand = true
 //            };
 // 	    nyttbox.append (adw_page);
 // 	    return nyttbox;
 //        } else {

	//     var list_box = new Gtk.ListBox () {vexpand = false, margin_top = 20};
 //        list_box.add_css_class ("boxed-list");
 //        //list_box.set_sort_func (sort_list);
 //        //list_box.set_filter_func (filter_list);
 //        nyttbox.append (list_box);

 //        for (int j = 0; subjects[i].grades[j] != null; j++) {
 //            average[subjects[i].grades[j].cat] += int.parse (subjects[i].grades[j].grade);
 //            number_of_grades[subjects[i].grades[j].cat]++;



 //            //expander row
 //            var expander_row = new Adw.ActionRow ();
 //            expander_row.set_title (subjects[i].grades[j].grade.to_string ());
 // 	    if (subjects[i].grades[j].note == "") {
	// 	expander_row.set_subtitle (subjects[i].categories[subjects[i].grades[j].cat].name);
	//     } else {
 //            	expander_row.set_subtitle (subjects[i].categories[subjects[i].grades[j].cat].name + " — " + subjects[i].grades[j].note);
 //            }
 //            var delete_button = new DeleteButton (i, j);
 //            expander_row.add_suffix (delete_button);



 //            //put everything together
 //            list_box.append (expander_row);



 //            //CONNECT BUTTONS
 //            delete_button.clicked.connect (() => {
	// 	Adw.MessageDialog msg = new Adw.MessageDialog (
	// 		main_window,
	// 		_("Delete Grade?"),
	// 		_("If you delete this grade, its information will be deleted permanently.")
	// 	);
	// 	msg.add_response ("cancel", _("Cancel"));
 //                msg.add_response ("delete", _("Delete"));
	// 	msg.set_response_appearance ("delete", DESTRUCTIVE);
	// 	msg.set_close_response ("cancel");
	// 	msg.response.connect ((response) => {
	// 		if (response == "delete") {
	// 			delete_grade (delete_button.subject_index, delete_button.grade_index);
	// 		}
	// 		msg.destroy ();
	// 	});

	// 	msg.present ();
 //            });
 // //        }

 //        double percentage_divider = 0;

 //        for (int j = 0; j < subjects[i].categories.length && subjects[i].categories[j] != null; j++) {
 //            if (number_of_grades[j] != 0) {
 //                avg_calculated[j] = average[j] / number_of_grades[j];
 //                final_avg += avg_calculated[j] * subjects[i].categories[j].percentage;
 //                percentage_divider += subjects[i].categories[j].percentage;
 //            }
 //        }
 //        if (percentage_divider != 0) {
 //            string average_string = "%.2f".printf (final_avg / percentage_divider);
 //            avg[i].set_label (average_string);
 //        }

	//  return nyttbox;
 //        }
 //    }
}
