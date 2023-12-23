public class SubjectParser : Object {
    // public static Subject? legacy_to_object (string str) {
    //     Regex regex_for_main;
    //     Regex regex_for_sub;

    //     try {
    //         regex_for_main = new Regex ("%");
    //         regex_for_sub = new Regex ("#");
    //     } catch (Error e) {
    //         print (e.message);
    //         return null;
    //     }

    //     var subject_string_arr = new string[3];
    //     var cat_string_arr = new string[10];
    //     var grade_string_arr = new string[10];

    //     subject_string_arr = str.split_set ("%");
    //     cat_string_arr = regex_for_sub.split (subject_string_arr[1]);
    //     grade_string_arr = regex_for_sub.split (subject_string_arr[2]);

    //     var result_subject = new Subject (subject_string_arr[0]);

    //     var cats = new Category[cat_arr_size];
    //     int j1 = 0;
    //     for (int i = 0; i < cat_string_arr.length && cat_string_arr[j1] != null; i++) {
    //         cats[i] = new Category ("", 0);
    //         cats[i].name = cat_string_arr[j1];
    //         j1++;
    //         cats[i].percentage = int.parse (cat_string_arr[j1]);
    //         j1++;
    //     }


    //     var grades = new Grade[grade_arr_size];
    //     int j2 = 0;
    //     for (int i = 0; i < grade_string_arr.length && grade_string_arr[j2] != null; i++) {
    //         grades[i] = new Grade ("", "", 0);
    //         grades[i].grade = grade_string_arr[j2];
    //         j2++;
    //         grades[i].note = grade_string_arr[j2];
    //         j2++;
    //         grades[i].cat = int.parse (grade_string_arr[j2]);
    //         j2++;
    //     }

    //     result_subject.categories = cats;
    //     result_subject.grades = grades;

    //     return result_subject;
    // }

    public static Subject? to_object (string str) {
        var subject_string_arr = str.split_set ("%");
        var cat_string_arr = subject_string_arr[1].split_set ("#");
        var grade_string_arr = subject_string_arr[2].split_set ("#");

        var result_subject = new Subject (subject_string_arr[0]);

        int j1 = 0;
        while (j1 < cat_string_arr.length) {
            result_subject.categories_by_name[cat_string_arr[j1]] = new Category (cat_string_arr[j1++], int.parse (cat_string_arr[j1++]));
        }

        int j2 = 0;
        while (j2 < grade_string_arr.length) {
            result_subject.grades_model.append (new Grade (grade_string_arr[j2++], grade_string_arr[j2++], grade_string_arr[j2++]));
        }

        return result_subject;
    }

    public static string[] categories_to_string_list (Subject subject) {
        string[] result = {};

        foreach (var category in subject.categories_by_name.get_values ()) {
            var node = Json.gobject_serialize (category);
            var generator = new Json.Generator () {
                root = node
            };
            result += generator.to_data (null);
            print (generator.to_data (null));
        }

        return result;
    }

    public static string[] grades_to_string_list (Subject subject) {
        string[] result = {};

        for (int i = 0; i < subject.grades_model.get_n_items (); i++) {
            result += Json.gobject_to_data (subject.grades_model.get_item (i), null);
        }

        return result;
    }

    public static void load_grades (Subject subject, string[] grades) {
        foreach (var grade_str in grades) {
            try {
                subject.add_grade ((Grade) Json.gobject_from_data (typeof (Grade), grade_str));
            } catch (Error e) {
                warning ("Failed to load grade %s: %s", grade_str, e.message);
            }
        }
    }

    public static void load_categories (Subject subject, string[] categories) {
        foreach (var category_str in categories) {
            try {
                subject.add_category ((Category) Json.gobject_from_data (typeof (Category), category_str));
            } catch (Error e) {
                warning ("Failed to load category %s: %s", category_str, e.message);
            }
        }
    }
}
