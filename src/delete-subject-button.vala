public class DeleteSubjectButton : Gtk.Button {
    public int index;

    public DeleteSubjectButton (int i) {
        label = "Delete this subject";
        index = i;
        halign = END;
 	vexpand = false;
    }
}
