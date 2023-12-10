public class SubjectManager : Object {
    private static Once<SubjectManager> instance;
    public static SubjectManager get_default () {
        return instance.once (() => new SubjectManager ());
    }

    public ListStore subjects { get; construct; }

    private ListStore deleted_subjects;

    construct {
        subjects = new ListStore (typeof (Subject));
        deleted_subjects = new ListStore (typeof (Subject));
    }

    public async void write_to_file (File file, string write_data) {
        uint8[] write_bytes = (uint8[]) write_data.to_utf8 ();

        try {
            yield file.replace_contents_async (write_bytes, null, false, FileCreateFlags.NONE, null, null);
        } catch (Error e) {
            print (e.message);
        }
    }

    public string read_from_file (File file) {
        try {
            string file_content = "";
            uint8[] contents;
            string etag_out;


            file.load_contents (null, out contents, out etag_out);

            file_content = (string) contents;

            return file_content;
        } catch (Error e) {
            print ("Error: %s\n", e.message);
        }
        return "-1";
    }


    public void read_data () {
        for (int i = 0; i < 20 && FileUtils.test (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i", FileTest.EXISTS); i++) {
            File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

            var parser = new SubjectParser ();
            Subject sub = parser.to_object (read_from_file (file));
            add_subject (sub);
        }
    }

    public void writes_data () {
        File dir = File.new_for_path (Environment.get_user_data_dir () + "/gradebook/savedata/");
        if (!dir.query_exists ()) {
            try {
                dir.make_directory_with_parents ();
            } catch (Error e) {
                print (e.message);
            }
        }

        for (int i = 0; i < subjects.get_n_items (); i++) {
            var subject = (Subject) subjects.get_item (i);

            var parser = new SubjectParser ();
            File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");
            //TODO: Delete old files
            write_to_file (file, parser.to_string (subject));
            warning ("write: %s", parser.to_string (subject));
        }
    }

    public async void write_data_new () {
        File dir = File.new_for_path (Environment.get_user_data_dir () + "/gradebook/savedata/");
        if (!dir.query_exists ()) {
            try {
                dir.make_directory_with_parents ();
            } catch (Error e) {
                critical ("Failed to save subjects: Failed to create savedata directory: %s", e.message);
            }
        }

        var parser = new SubjectParser ();
        for (int i = 0; i < subjects.get_n_items (); i++) {
            var subject = (Subject) subjects.get_item (i);

            var file = dir.get_child (subject.name);
            yield write_to_file (file, parser.to_string (subject));
        }

        for (int i = 0; i < deleted_subjects.get_n_items (); i++) {
            var subject = (Subject) subjects.get_item (i);

            var file = dir.get_child (subject.name);

            try {
                yield file.delete_async ();
            } catch (Error e) {
                warning ("Failed to delete save file for subject '%s': %s", subject.name, e.message);
            }
        }
    }

    public void new_subject (string name, Category[] c) {
        var subject = new Subject (name);

        foreach (var cat in c) {
            subject.categories_by_name[cat.name] = cat;
        }

        add_subject (subject);
    }

    private void add_subject (Subject subject) {
        subjects.append (subject);
        subject.notify["deleted"].connect (() => {
            uint pos;
            if (subjects.find (subject, out pos)) {
                subjects.remove (pos);
            }
            deleted_subjects.append (subject);
        });
    }
}
