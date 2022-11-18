public class AddCategoryDialog : Gtk.Dialog {
    public Gtk.SpinButton percentage_spinbutton;
    public Gtk.Entry name_entry;

    public AddCategoryDialog (Gtk.Window parent) {
        Object (
            modal: true,
            title: "Add new Category",
            use_header_bar: 1,
            transient_for: parent,
            default_height: 300,
            default_width: 400
        );

        this.add_button ("Cancel", Gtk.ResponseType.CANCEL);
        this.add_button ("Apply", Gtk.ResponseType.ACCEPT).add_css_class ("suggested-action");

        this.set_response_sensitive (Gtk.ResponseType.ACCEPT, false);

        var main_box = new Gtk.Box (VERTICAL, 0);
        this.get_content_area ().append (main_box);

        var name_entry_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20
        };
        main_box.append (name_entry_box);

        var name_label = new Gtk.Label ("Name of the category:") {height_request = 40};
        name_entry_box.append (name_label);

        name_entry = new Gtk.Entry ();
        name_entry_box.append (name_entry);


        var percentage_entry_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20,
            margin_bottom = 20
        };
        main_box.append (percentage_entry_box);

        var percentage_label = new Gtk.Label ("Weight of the category, in percentage:") {height_request = 40};
        percentage_entry_box.append (percentage_label);

        var percentage_adjustment = new Gtk.Adjustment (0, 0, 100, 0.5, 0, 0);
        percentage_spinbutton = new Gtk.SpinButton (percentage_adjustment, 1, 2) {
            orientation = VERTICAL
        };
        percentage_entry_box.append (percentage_spinbutton);


        name_entry.changed.connect (() => {
            this.set_response_sensitive (Gtk.ResponseType.ACCEPT, true);
        });
    }
}