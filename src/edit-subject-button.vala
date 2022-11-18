public class EditSubjectButton : Gtk.Button {
    public int index;

    public EditSubjectButton (int i) {
        label = "Edit this subject";
        index = i;
        halign = END;
    }
}