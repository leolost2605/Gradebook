public class NewSubjectDialog : Gtk.Dialog {
    public Gtk.Entry name_entry;
    public Category[] categories;
    public Gtk.Box main_box;

    public NewSubjectDialog (Adw.ApplicationWindow parent) {
        Object (
            modal: true,
            title: _("New Subject"),
            use_header_bar: 1,
            transient_for: parent,
            default_height: 400,
            default_width: 500
        );

        categories = new Category[5];

        this.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        this.add_button (_("Add"), Gtk.ResponseType.ACCEPT).add_css_class ("suggested-action");

        this.set_response_sensitive (Gtk.ResponseType.ACCEPT, false);

        main_box = new Gtk.Box (VERTICAL, 0);
        this.get_content_area ().append (main_box);



        var name_entry_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20
        };
        main_box.append (name_entry_box);

        var name_label = new Gtk.Label (_("Name of the subject:"));
        name_entry_box.append (name_label);

        name_entry = new Gtk.Entry () {
            margin_top = 20
        };
        name_entry_box.append (name_entry);


        name_entry.changed.connect (() => {
            this.set_response_sensitive (Gtk.ResponseType.ACCEPT, true);
        });

        main_box.append(new Gtk.Label (_("This subject's categories:")) {margin_top = 20, halign = CENTER});

        categories_list_ui ();
        /*
        var cat_list_box = new Gtk.ListBox ();
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

        var bottom_box = new Gtk.Box (HORIZONTAL, 0) {
            margin_start = 20,
            margin_end = 20,
            margin_bottom = 20,
            homogeneous = true
        };
        main_box.append(bottom_box);
        var new_cat_button = new Gtk.Button.with_label (_("Add a new category")) {
            halign = END
        };
        bottom_box.append (new_cat_button);

        new_cat_button.clicked.connect (() => {
            var dialog = new AddCategoryDialog (this);

            dialog.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.ACCEPT) {
                    add_cat(dialog.name_entry.get_text(), dialog.percentage_spinbutton.get_value());
                }
                dialog.destroy ();
            });

            dialog.present ();
        });
    }

    public void add_cat (string n, double p) {
        for (int i = 0; i < categories.length; i++) {
            if(categories[i] == null) {
                categories[i] = new Category (n, p);
                i = categories.length;
                categories_list_ui ();
            }
        }
    }

    public void categories_list_ui () {
        if (main_box.get_first_child ().get_next_sibling ().get_next_sibling() != null && main_box.get_first_child ().get_next_sibling ().get_next_sibling().name == "GtkScrolledWindow") {
            main_box.remove (main_box.get_first_child ().get_next_sibling ().get_next_sibling());
        }

        var cat_list_box = new Gtk.ListBox ();
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
        main_box.insert_child_after(scroll_container, main_box.get_first_child ().get_next_sibling ());


        for (int i = 0; i < categories.length && categories[i] != null; i++) {
            var cat_row = new Adw.ActionRow () {
                title = categories[i].name,
                subtitle = categories[i].percentage.to_string () + "%"
            };
            cat_list_box.append(cat_row);
        }
    }
}
