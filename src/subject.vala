public class Subject : Object{
    public string name { get; set; }
    public Grade[] grades { get; set; }
    public ListStore grades_model { get; set; }
    public Category[] categories { get; set; }
    public ListStore categories_model { get; set; }
    public int cat_arr_size = 5;
    public int grade_arr_size = 20;

    public Subject (string n) {
        name = n;
        grades = new Grade[grade_arr_size];
        grades_model = new ListStore (typeof (Grade));
        categories = new Category[cat_arr_size];
        categories_model = new ListStore (typeof (Category));
    }

    public void new_grade (string grade, string note, int c) {
        grades_model.append (new Grade (grade, note, c));
    }
}
