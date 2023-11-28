public class NewSubjectDialog : Adw.Window {
    public Category[] categories;
    public Gtk.Box main_box;
    public Adw.EntryRow name_entry_box;
    private Gtk.Button new_cat_button;
    public bool accept;

    public NewSubjectDialog (Adw.ApplicationWindow parent) {
    Object (
        modal: true,
        title: _("New Subject"),
        transient_for: parent,
        default_height: 400,
        default_width: 500,
        width_request: 360,
        height_request: 360
    );

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

	var ab = new Gtk.Button.with_label (_("Save")) { css_classes = { "suggested-action" }, sensitive = false };
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

	Gtk.ListBox lisbox = new Gtk.ListBox () {margin_start = 1, margin_end = 1};
	lisbox.add_css_class ("boxed-list");
        name_entry_box = new Adw.EntryRow () {
		input_hints = Gtk.InputHints.SPELLCHECK,
		title = _("Subject Title"),
	};
	lisbox.append (name_entry_box);
        main_box.append (lisbox);


        name_entry_box.changed.connect (() => {
            ab.sensitive = true;
        });

        categories_list_ui ();
        /*var cat_list_box = new Gtk.ListBox ();
        cat_list_box.add_css_class("boxed-list");

        var scroll_container = new Gtk.ScrolledWindow () {
            margin_bottom = 20,
            margin_top = 20,
            margin_start = 20,
            margin_end = 20,
            hexpand = true,
            vexpand = true
        };
        scroll_container.set_child(cat_list_box);
        main_box.append(scroll_container);


        for (int i = 0; i < subject.categories.length && subject.categories[i] != null; i++) {
            var cat_row = new Adw.ActionRow () {
                title = subject.categories[i].name,
                subtitle = subject.categories[i].percentage.to_string () + "%"
            };
            cat_list_box.append(cat_row);
        }*/
    }

    public void add_cat (string n, double p) {
        for (int i = 0; i < categories.length; i++) {
            if (categories[i] == null) {
                categories[i] = new Category (n, p);
                i = categories.length;
                categories_list_ui ();
            }
        }
    }

    public void categories_list_ui () {
        if (main_box.get_first_child ().get_next_sibling () != null && main_box.get_first_child ().get_next_sibling ().name == "AdwPreferencesGroup") {
            main_box.remove (main_box.get_first_child ().get_next_sibling ());
        }

        var cat_list_box = new Adw.PreferencesGroup () {
            margin_top = 20,
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
        main_box.insert_child_after (cat_list_box, main_box.get_first_child ());


        for (int i = 0; i < categories.length && categories[i] != null; i++) {
            var cat_row = new Adw.ActionRow () {
                title = categories[i].name,
                subtitle = categories[i].percentage.to_string () + "%"
            };
            cat_list_box.add (cat_row);
        }
    }
}
