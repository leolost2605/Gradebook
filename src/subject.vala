public class Subject : Object{
    public string name { get; set; }
    public Grade[] grades { get; set; }
    public Category[] categories { get; set; }
    public int cat_arr_size = 5;
    public int grade_arr_size = 20;

    public Subject (string n) {
        name = n;
        grades = new Grade[grade_arr_size];
        categories = new Category[cat_arr_size];
    }
}
