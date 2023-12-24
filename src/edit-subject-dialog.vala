public class EditSubjectDialog : Adw.Window {
    public Subject? subject { get; construct; }
    private List<Adw.ActionRow> cat_rows;
    private HashTable<string, Category> categories;
    private Adw.PreferencesGroup cat_list_box;

    private string subject_name;

    public EditSubjectDialog (Adw.ApplicationWindow parent, Subject? subject) {
        Object (
            modal: true,
            title: subject == null ?  _("New Subject") : _("Edit Subject"),
            transient_for: parent,
            default_height: 400,
            default_width: 500,
            width_request: 360,
            height_request: 360,
            subject: subject
        );
    }

    construct {
        categories = new HashTable<string, Category> (str_hash, str_equal);
 	    cat_rows = new List<Adw.ActionRow> ();

        var cb = new Gtk.Button.with_label (_("Cancel"));
        cb.clicked.connect (() => {
            close ();
        });

        var ab = new Gtk.Button.with_label (_("Save")) {
            sensitive = false,
            css_classes = { "suggested-action" } 
        };
        ab.clicked.connect (() => {
            if (subject == null) {
                subject = new Subject (subject_name);
                subject.categories_by_name = categories;
                SubjectManager.get_default ().add_subject (subject);
            } else {
                subject.name = subject_name;
                subject.categories_by_name = categories;
            }
            close ();
        });

        var size_group = new Gtk.SizeGroup (BOTH);
        size_group.add_widget (cb);
        size_group.add_widget (ab);

	    var hb = new Adw.HeaderBar () {
		    show_end_title_buttons = false,
		    show_start_title_buttons = false,
	    };
	    hb.pack_start (cb);
	    hb.pack_end (ab);

        var name_entry_row = new Adw.EntryRow () {
            input_hints = SPELLCHECK,
            title = _("Subject Title"),
        };

        var name_list_box = new Gtk.ListBox () {
            margin_start = 1, 
            margin_end = 1
        };
        name_list_box.add_css_class ("boxed-list");
        name_list_box.append (name_entry_row);

 	    var new_cat_button = new Gtk.Button () {
            icon_name = "list-add-symbolic",
            tooltip_text = _("Add New Category"),
            css_classes = { "flat" }
        };

        cat_list_box = new Adw.PreferencesGroup () {
            margin_top = 20,
            margin_start = 1,
            margin_end = 1,
            hexpand = true,
            vexpand = true,
            title = _("Subject Categories"),
        };
 	    cat_list_box.set_header_suffix (new_cat_button);

 	    var subject_delete_button = new Gtk.Button.with_label (_("Delete Subject…")) { 
            hexpand = false, 
            halign = START, 
            margin_top = 20,
            visible = subject != null
        };
        subject_delete_button.add_css_class ("destructive-action");

        var main_box = new Gtk.Box (VERTICAL, 0) {
		    margin_top = 20,
		    margin_bottom = 20
	    };
        main_box.append (name_list_box);
        main_box.append (cat_list_box);
 	    main_box.append (subject_delete_button);


        var clamp = new Adw.Clamp () {
		    margin_start = 19,
		    margin_end = 19,
		    maximum_size = 500,
		    tightening_threshold = 400,
		    child = main_box
	    };

	    var scrolled_window = new Gtk.ScrolledWindow () {
	        child = clamp
	    };

	    var tbv = new Adw.ToolbarView () {
	        content = scrolled_window
	    };
        tbv.add_top_bar (hb);

	    content = tbv;

        name_entry_row.changed.connect (() => {
            subject_name = name_entry_row.text;
            ab.sensitive = subject_name.strip () != ""; //TODO: check whether another subject with the same name exists
        });

        if (subject != null) {
            name_entry_row.text = subject.name;
            subject.categories_by_name.@foreach ((key, val) => {
                categories[key] = val;
            });
        }

        load_list ();

        subject_delete_button.clicked.connect (() => {
            string n = subject.name;
            ///TRANSLATORS: %s is the name of a school subject
            var message_dialog = new Adw.MessageDialog(this, _("Delete %s?").printf(    n), null);
	        message_dialog.set_body (_("If you delete %s, its information will be deleted permanently.").printf(    n));
            message_dialog.add_response ("0", _("Cancel"));
            message_dialog.add_response ("1", _("Delete"));
            message_dialog.set_response_appearance ("1", DESTRUCTIVE);
            message_dialog.present ();
            message_dialog.response.connect ((id) => {
                    switch (id) {
                        case "0":
                            break;
                        case "1":
                            subject.deleted = true;
                            close ();
                            break;
                        }
                });
        });

 	    new_cat_button.clicked.connect (() => {
            var dialog = new AddCategoryDialog (this);

            dialog.response.connect ((response_id) => {
                if (response_id == "add") {
                    add_cat (dialog.name_entry.get_text (), dialog.percentage.get_value ());
                }
                dialog.destroy ();
            });

            dialog.present ();
        });
    }

    public void add_cat (string n, double p) {
        categories[n] = new Category (n, p);
        load_list ();
    }

    public void load_list () {
        foreach (var row in cat_rows) {
            cat_list_box.remove (row);
        }

        cat_rows = new List<Adw.ActionRow> ();

        foreach (var category in categories.get_values ()) {
            var cat_row = new Adw.ActionRow () {
                title = category.name,
                subtitle = category.percentage.to_string () + "%"
            };
            cat_rows.append (cat_row);
            cat_list_box.add (cat_row);
        }
    }
}
