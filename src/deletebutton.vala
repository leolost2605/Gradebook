public class DeleteButton : Gtk.Button{
    public int subject_index;
    public int grade_index;

    public DeleteButton (string l, int si, int gi) {
        this.label = l;
        subject_index = si;
        grade_index = gi;
        add_css_class ("destructive-action");
    }
}