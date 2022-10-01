public class NewSubjectDialog : Gtk.Dialog {
    public Gtk.Entry name_entry;

    public NewSubjectDialog (Adw.ApplicationWindow parent) {
        Object (
            modal: true,
            title: "New Subject",
            use_header_bar: 1,
            transient_for: parent,
            default_height: 200,
            default_width: 400
        );

        this.add_button ("Cancel", Gtk.ResponseType.CANCEL);
        this.add_button ("Add", Gtk.ResponseType.ACCEPT).add_css_class ("suggested-action");

        this.set_response_sensitive (Gtk.ResponseType.ACCEPT, false);

        var main_box = new Gtk.Box (VERTICAL, 0);
        this.get_content_area ().append (main_box);



        var name_entry_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20
        };
        main_box.append (name_entry_box);

        var name_label = new Gtk.Label ("Name of the subject:");
        name_entry_box.append (name_label);

        name_entry = new Gtk.Entry () {
            margin_top = 20
        };
        name_entry_box.append (name_entry);


        name_entry.changed.connect (() => {
            this.set_response_sensitive (Gtk.ResponseType.ACCEPT, true);
        });
    }
}