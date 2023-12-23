public class SubjectManager : Object {
    private static Once<SubjectManager> instance;
    public static SubjectManager get_default () {
        return instance.once (() => new SubjectManager ());
    }

    public ListStore subjects { get; construct; }

    construct {
        subjects = new ListStore (typeof (Subject));
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
            warning ("Error: %s\n", e.message);
        }
        return "-1";
    }

    public void read_data_legacy () {
        for (int i = 0; i < 20 && FileUtils.test (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i", FileTest.EXISTS); i++) {
            File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

            Subject sub = SubjectParser.to_object (read_from_file (file));
            add_subject (sub);
        }
    }

    public async void read_data () {
        var keyfile = new KeyFile ();

        try {
            keyfile.load_from_file (Environment.get_user_data_dir () + "/gradebook/subjects", NONE);
        } catch (Error e) {
            warning ("Failed to load keyfile: %s", e.message);
            return;
        }

        try {
            foreach (var group in keyfile.get_groups ()) {
                var subject = new Subject (group);
                SubjectParser.load_categories (subject, keyfile.get_string_list (group, "categories"));
                SubjectParser.load_grades (subject, keyfile.get_string_list (group, "grades"));

                add_subject (subject);
            }
        } catch (Error e) {
            critical ("Failed to read data: %s", e.message);
        }
    }

    public async void write_data () {
        var keyfile = new KeyFile ();

        var parser = new SubjectParser ();
        for (int i = 0; i < subjects.get_n_items (); i++) {
            var subject = (Subject) subjects.get_item (i);

            if (subject.deleted) {
                continue;
            }

            keyfile.set_string (subject.name, "name", subject.name);
            keyfile.set_string_list (subject.name, "categories", SubjectParser.categories_to_string_list (subject));
            keyfile.set_string_list (subject.name, "grades", SubjectParser.grades_to_string_list (subject));
        }

        try {
            keyfile.save_to_file (Environment.get_user_data_dir () + "/gradebook/subjects");
        } catch (Error e) {
            critical ("Failed to save keyfile: %s", e.message);
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
        });
    }
}
