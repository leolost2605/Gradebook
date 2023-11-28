public class EditSubjectDialog : Adw.Window {
    public Category[] categories;
    public Gtk.Box main_box;
    public Adw.EntryRow name_entry_box;
    private Gtk.Button new_cat_button;
    private Gtk.Button subject_delete_button;
    public bool accept = false;
    public Subject subject;

    public EditSubjectDialog (Adw.ApplicationWindow parent, Subject s) {
        Object (
            modal: true,
            title: _("Edit Subject"),
            transient_for: parent,
            default_height: 400,
            default_width: 500,
            width_request: 360,
            height_request: 360
        );

 	    subject = s;

        categories = new Category[5];

	    var tbv = new Adw.ToolbarView ();
	    this.set_content (tbv);

	    var hb = new Adw.HeaderBar () {
		    show_end_title_buttons = false,
		    show_start_title_buttons = false,
	    };

	    var cb = new Gtk.Button.with_label (_("Cancel"));
	    cb.clicked.connect (() => {
		    accept = false;
		    this.close ();
	    });

	    var ab = new Gtk.Button.with_label (_("Save")) { css_classes = { "suggested-action" } };
	    ab.clicked.connect (() => {
		    accept = true;
		    this.close ();
	    });

	    hb.pack_start (cb);
	    hb.pack_end (ab);

	    tbv.add_top_bar (hb);

        Adw.Clamp ac = new Adw.Clamp () {
		    margin_start = 19,
		    margin_end = 19,
		    maximum_size = 500,
		    tightening_threshold = 400
	    };

	    var sw = new Gtk.ScrolledWindow ();
            main_box = new Gtk.Box (VERTICAL, 0) {
		    margin_top = 20,
		    margin_bottom = 20
	    };
	    tbv.set_content (sw);

            this.set_content (tbv);
     	sw.set_child (ac);
	    ac.set_child (main_box);

        load_list ();

 	    subject_delete_button = new Gtk.Button.with_label (_("Delete Subject…")) { hexpand = false, halign = Gtk.Align.START, margin_top = 20 };
        subject_delete_button.add_css_class ("destructive-action");
 	    main_box.append (subject_delete_button);

        subject_delete_button.clicked.connect (() => {
                string n = s.name;
                ///TRANSLATORS: %s is the name of a school subject
                var message_dialog = new Adw.MessageDialog(    this, _("Delete %s?").printf(    n), null);
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
                                subject = null;
 				accept = true;
                                this.close ();
                                break;
                            }
                    });
            });
    }

    public void add_cat (string n, double p) {
        for (int i = 0; i < categories.length; i++) {
            if (categories[i] == null) {
                categories[i] = new Category (n, p);
                i = categories.length;
                load_list ();
            }
        }
    }

    public void load_list () {
	    main_box.remove (main_box.get_first_child ());
	    main_box.remove (main_box.get_first_child ());

        var cat_list_box = new Adw.PreferencesGroup () {
            margin_start = 1,
            margin_end = 1,
            hexpand = true,
            vexpand = true,
            title = _("Subject Categories"),
        };

 	    new_cat_button = new Gtk.Button () {
            icon_name = "list-add-symbolic",
            tooltip_text = _("Add New Category"),
            css_classes = { "flat" }
        };

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

 	    cat_list_box.set_header_suffix (new_cat_button);

        main_box.append (cat_list_box);
 	    main_box.append (subject_delete_button);

        for (int i = 0; i < subject.categories.length && subject.categories[i] != null; i++) {
            var cat_row = new Adw.ActionRow () {
                title = subject.categories[i].name,
                subtitle = subject.categories[i].percentage.to_string () + "%"
            };
            cat_list_box.add (cat_row);
        }
    }
}
