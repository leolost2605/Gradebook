public class SubjectParser : Object {
    public int cat_arr_size = 5;
    public int grade_arr_size = 20;

    public SubjectParser () {}

    public Subject? to_object (string str) {
        var subject_string_arr = str.split_set ("%");
        var cat_string_arr = subject_string_arr[1].split_set ("#");
        var grade_string_arr = subject_string_arr[2].split_set ("#");

        var result_subject = new Subject (subject_string_arr[0]);

        // var cats = new Category[cat_arr_size];
        // int j1 = 0;
        // for (int i = 0; i < cat_string_arr.length; i++) {
        //     result_subject.categories_by_name[cat_string_arr[j1]] = new Category (cat_string_arr[j1++], int.parse (cat_string_arr[j1++]));
        // }


        // var grades = new Grade[grade_arr_size];
        // int j2 = 0;
        // for (int i = 0; i < grade_string_arr.length; i++) {
        //     result_subject.grades_model.append (new Grade (grade_string_arr[j2++], grade_string_arr[j2++], int.parse (grade_string_arr[j2++])));
        // }

        // result_subject.categories = cats;
        // result_subject.grades = grades;

        return result_subject;
    }

    public string to_string (Subject sub) {
        string result = sub.name + "%";

        bool first = true;
        foreach (var category in sub.categories_by_name.get_values ()) {
            if (!first) {
                result = result + "#";
            } else {
                first = false;
            }
            result = result + category.name + "#";
            result = result + category.percentage.to_string ();
        }

        result = result + "%";

        first = true;
        for (int i = 0; i < sub.grades_model.get_n_items (); i++) {
            if (!first) {
                result = result + "#";
            } else {
                first = false;
            }
            result = result + ((Grade) sub.grades_model.get_item (i)).grade + "#";
            result = result + ((Grade) sub.grades_model.get_item (i)).note + "#";
            result = result + ((Grade) sub.grades_model.get_item (i)).cat.to_string () + "#";
        }

        return result;
    }
}
