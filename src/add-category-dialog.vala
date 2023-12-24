public class AddCategoryDialog : Adw.MessageDialog {
    public Gtk.Adjustment percentage;
    public Adw.EntryRow name_entry;

    public AddCategoryDialog (Gtk.Window parent) {
        Object (
            heading: _("Add New Category"),
            transient_for: parent,
            width_request: 360
        );

        this.add_response ("cancel", _("Cancel"));
        this.add_response ("add", _("Add"));
        this.set_response_appearance ("add", Adw.ResponseAppearance.SUGGESTED);

        this.set_response_enabled ("add", false);
 	    this.set_close_response ("cancel");

        var lb = new Gtk.ListBox () { css_classes = { "boxed-list" } };
        name_entry = new Adw.EntryRow () {
            input_hints = Gtk.InputHints.SPELLCHECK,
            title = _("Category Name")
        };
        lb.append (name_entry);

        percentage = new Gtk.Adjustment (0, 0, 100, 1, 10, 0);
        var percent = new Adw.SpinRow (percentage, 1, 2) {
            title = _("Category Percent")
        };
        lb.append (percent);

	    this.set_extra_child (lb);

        name_entry.changed.connect (() => set_response_enabled ("add", name_entry.text.strip () != ""));

 	    present ();
    }
}
