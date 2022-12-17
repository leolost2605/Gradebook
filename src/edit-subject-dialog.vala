public class EditSubjectDialog : Gtk.Dialog {
    public Subject subject;
    public Gtk.ScrolledWindow scroll_container;

    public EditSubjectDialog (Adw.ApplicationWindow parent, Subject s, Adw.Application app) {
        Object (
            modal: true,
            title: _("Edit Subject"),
            use_header_bar: 1,
            transient_for: parent,
            default_height: 500,
            default_width: 600
        );

        subject = s;

        this.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        this.add_button (_("Apply"), Gtk.ResponseType.ACCEPT).add_css_class ("suggested-action");

        //this.set_response_sensitive (Gtk.ResponseType.ACCEPT, false);

        var main_box = new Gtk.Box (VERTICAL, 0);
        this.get_content_area ().append (main_box);

        main_box.append(new Gtk.Label (_("This subject's categories:")) {margin_top = 20, halign = CENTER});

        scroll_container = new Gtk.ScrolledWindow () {
            margin_bottom = 20,
            margin_top = 20,
            margin_start = 20,
            margin_end = 20,
            hexpand = true,
            vexpand = true
        };
        main_box.append(scroll_container);

        load_list();

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


        main_box.append(new Gtk.Separator(HORIZONTAL));


        var bottom_delete_box = new Gtk.Box (HORIZONTAL, 0) {
            margin_top = 20,
            margin_start = 20,
            margin_end = 20,
            margin_bottom = 20,
            homogeneous = true
        };
        main_box.append(bottom_delete_box);

        var subject_delete_button = new Gtk.Button.with_label(_("Delete subject")) {
                halign = END
            };
        subject_delete_button.add_css_class("destructive-action");
        bottom_delete_box.append(subject_delete_button);

        subject_delete_button.clicked.connect (() => {
                string n = s.name;
                ///TRANSLATORS: $n is the name of a school subject
                var message_dialog = new Adw.MessageDialog(this, _(@"Are you sure you want to delete $n?"), null);
                message_dialog.add_response("0", _("Cancel"));
                message_dialog.add_response("1", _("Yes"));
                message_dialog.set_response_appearance("1", DESTRUCTIVE);
                message_dialog.present();
                message_dialog.response.connect ((id) => {
                        switch (id) {
                            case "0":
                                break;
                            case "1":
                                subject = null;

                                this.response(Gtk.ResponseType.ACCEPT);
                                break;
                            }
                    });
            });

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

        /*
        name_entry.changed.connect (() => {
            this.set_response_sensitive (Gtk.ResponseType.ACCEPT, true);
        });*/
    }


    public void add_cat (string n, double p) {
        for (int i = 0; i < subject.categories.length; i++) {
            if(subject.categories[i] == null) {
                subject.categories[i] = new Category (n, p);
                i = subject.categories.length;
                load_list();
            }
        }
    }

    public void load_list () {
        var cat_list_box = new Gtk.ListBox ();
        cat_list_box.add_css_class("boxed-list");

        scroll_container.set_child(cat_list_box);

        for (int i = 0; i < subject.categories.length && subject.categories[i] != null; i++) {
            var cat_row = new Adw.ActionRow () {
                title = subject.categories[i].name,
                subtitle = subject.categories[i].percentage.to_string () + "%"
            };
            cat_list_box.append(cat_row);
        }
    }
}
