public class DeleteButton : Gtk.Button{
    public int subject_index;
    public int grade_index;

    public DeleteButton (int si, int gi) {
        this.icon_name = "user-trash-symbolic";
        subject_index = si;
        grade_index = gi;
        add_css_class ("flat");
 	this.vexpand = false;
 	this.valign = CENTER;
    }
}