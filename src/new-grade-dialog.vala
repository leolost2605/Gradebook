public class NewGradeDialog : Adw.MessageDialog {
    public string grade;
    public string note;
    private Adw.SpinRow grade_spinbutton;
    private Adw.EntryRow entry;
    //private Adw.EntryRow note_entry;
    public Adw.ComboRow choose_cat_row;

    public NewGradeDialog (Adw.ApplicationWindow parent, Subject[] subjects, int index) {
        Object (
            heading: _("Add New Grade"),
            transient_for: parent,
            width_request: 360
        );

        //BUTTONS
        this.add_response ("cancel", _("Cancel"));
        this.add_response ("add", _("Add"));
        this.set_close_response ("cancel");
 	this.set_response_appearance ("add", SUGGESTED);
 	this.set_response_enabled ("add", false);

        var grade_adjustment = new Gtk.Adjustment (0, 0, 100, 1, 0, 0);

        //CATEGORY
        var cat_model = new Gtk.StringList (null);
        for (int i = 0; subjects[index].categories[i] != null; i++) {
            cat_model.append (subjects[index].categories[i].name);
        }

	grade_spinbutton = new Adw.SpinRow (grade_adjustment, 1, 2) {
		title = _("Grade")
        };
        choose_cat_row = new Adw.ComboRow () {
            title = _("Category"),
            model = cat_model
        };
 	entry = new Adw.EntryRow () {
		input_hints = SPELLCHECK,
		title = _("Note")
	};
        var preferences_group = new Adw.PreferencesGroup ();
 	preferences_group.add (grade_spinbutton);
        preferences_group.add (choose_cat_row);
        preferences_group.add (entry);
 	this.set_extra_child (preferences_group);

	grade_spinbutton.changed.connect (() => {
            this.set_response_enabled ("add", true);
        });
    }

    public bool set_variables () {
        grade = grade_spinbutton.get_value ().to_string ();
        note = (string) entry.get_text ();
        return true;
    }

    public string get_grade () {
        return grade;
    }

    public string get_note () {
        return note;
    }
}
