public class NewGradeDialog : Gtk.Dialog {
    public string grade;
    public int day;
    public int month;
    public int year;
    public string note;
    private DateTime today;
    private Gtk.SpinButton d_spinbutton;
    private Gtk.SpinButton m_spinbutton;
    private Gtk.SpinButton y_spinbutton;
    private Gtk.SpinButton grade_spinbutton;
    private Gtk.Entry entry;
    //private Adw.EntryRow note_entry;



    public NewGradeDialog (Adw.ApplicationWindow parent) {
        Object (modal: true, transient_for: parent, title: ("New Grade"), use_header_bar: 1);
        this.set_default_size (350, 450);

        //BUTTONS
        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        var accept_button = add_button ("Add", Gtk.ResponseType.ACCEPT);
        accept_button.add_css_class ("suggested-action");


        var dialog_main_box = new Gtk.Box (VERTICAL, 0);

        this.get_content_area ().append (dialog_main_box);



        //CREATE FORM FOR ENTERING NEW GRADE
        //GRADE
        var grade_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 20,
            margin_end = 20
        };

        grade_box.append (new Gtk.Label ("Grade:") {height_request = 40});

        var grade_adjustment = new Gtk.Adjustment (0, 0, 15, 1, 0, 0);
        grade_spinbutton = new Gtk.SpinButton (grade_adjustment, 1, 0) {
            orientation = VERTICAL
        };

        grade_box.append (grade_spinbutton);
        dialog_main_box.append (grade_box);

        //DATE
        today = new DateTime.now_local ();

        var date_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20
        };
        dialog_main_box.append (date_box);

        date_box.append (new Gtk.Label ("Date:") {height_request = 30});


        var date_picker_box = new Gtk.Box (HORIZONTAL, 20) {
            homogeneous = false
        };
        date_box.append (date_picker_box);

        var y_adjustment = new Gtk.Adjustment (today.get_year (), 0, 2100, 1, 0, 0);
        y_spinbutton = new Gtk.SpinButton (y_adjustment, 1, 0) {
            orientation = VERTICAL,
            hexpand = true
        };

        var m_adjustment = new Gtk.Adjustment (today.get_month (), 1, 12, 1, 0, 0);
        m_spinbutton = new Gtk.SpinButton (m_adjustment, 1, 0) {
            orientation = VERTICAL,
            hexpand = true
        };

        var d_adjustment = new Gtk.Adjustment (today.get_day_of_month (), 1, 31, 1, 0, 0);
        d_spinbutton = new Gtk.SpinButton (d_adjustment, 1, 0) {
            orientation = VERTICAL,
            hexpand = true
        };

        date_picker_box.append (d_spinbutton);
        date_picker_box.append (new Gtk.Label ("/"));
        date_picker_box.append (m_spinbutton);
        date_picker_box.append (new Gtk.Label ("/"));
        date_picker_box.append (y_spinbutton);

        //NOTE
        var entry_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 20,
            margin_end = 20,
            margin_top = 20
        };
        dialog_main_box.append (entry_box);

        entry_box.append (new Gtk.Label ("A note:") {height_request = 30});

        entry = new Gtk.Entry() {
            has_frame = true
        };
        entry_box.append (entry);
    }

    public bool set_variables () {
        grade = grade_spinbutton.get_value (). to_string ();
        day = (int) d_spinbutton.get_value ();
        month = (int) m_spinbutton.get_value ();
        year = (int) y_spinbutton.get_value ();
        note = (string) entry.get_text ();
        return true;
    }

    public string get_grade () {
        return grade;
    }

    public int get_day () {
        return day;
    }


    public int get_month () {
        return month;
    }


    public int get_year () {
        return year;
    }

    public string get_note () {
        return note;
    }
}