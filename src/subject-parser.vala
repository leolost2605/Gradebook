public class SubjectParser : Object {
    public int cat_arr_size = 5;
    public int grade_arr_size = 20;

    public SubjectParser () {}

    public Subject to_object (string str) {
        Regex regex_for_main;
        Regex regex_for_sub;

            try {
                regex_for_main = new Regex ("%");
                regex_for_sub = new Regex ("#");
            } catch (Error e) {
                print(e.message);
                return null;
            }

            var subject_string_arr = new string[3];
            var cat_string_arr = new string[10];
            var grade_string_arr = new string[10];

            subject_string_arr = regex_for_main.split(str);

            cat_string_arr = regex_for_sub.split(subject_string_arr[1]);
            grade_string_arr = regex_for_sub.split(subject_string_arr[2]);

            var result_subject = new Subject(subject_string_arr[0]);


            var cats = new Category[cat_arr_size];
            int j1 = 0;
            for (int i = 0; i < cat_string_arr.length && cat_string_arr[j1] != null; i++) {
                    cats[i] = new Category ("", 0);
                    cats[i].name = cat_string_arr[j1];
                    j1++;
                    cats[i].percentage = int.parse(cat_string_arr[j1]);
                    j1++;
                }


            var grades = new Grade[grade_arr_size];
            int j2 = 0;
            for (int i = 0; i < grade_string_arr.length && grade_string_arr[j2] != null; i++) {
                    grades[i] = new Grade ("", "", 0);
                    grades[i].grade = grade_string_arr[j2];
                    j2++;
                    grades[i].note = grade_string_arr[j2];
                    j2++;
                    grades[i].cat = int.parse(grade_string_arr[j2]);
                    j2++;
                }

            result_subject.categories = cats;
            result_subject.grades = grades;

            return result_subject;
        }

    public string to_string (Subject sub) {
            string result;

            result = sub.name + "%";

            for (int i = 0; i < sub.categories.length && sub.categories[i] != null; i++) {
                    result = result + sub.categories[i].name + "#";
                    result = result + sub.categories[i].percentage.to_string ();
                    if(sub.categories[i + 1] != null) {
                            result = result + "#";
                        }
                }
            result = result + "%";

            for (int i = 0; i < sub.grades.length && sub.grades[i] != null; i++) {
                    result = result + sub.grades[i].grade + "#";
                    result = result + sub.grades[i].note + "#";
                    result = result + sub.grades[i].cat.to_string() + "#";
                    if(sub.grades[i + 1] != null) {
                            result = result + "#";
                        }
                }

            return result;
        }

}
