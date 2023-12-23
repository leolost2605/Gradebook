public class Subject : Object{
    public string name { get; set; }
    public ListStore grades_model { get; construct; }
    public HashTable<string, Category> categories_by_name { get; set; }
    public bool deleted { get; set; default = false; }

    public Subject (string name) {
        Object (name: name);
    }

    construct {
        grades_model = new ListStore (typeof (Grade));
        categories_by_name = new HashTable<string, Category> (str_hash, str_equal);
    }

    public void new_grade (string grade, string note, string category) {
        grades_model.insert (0, new Grade (grade, note, category));
    }

    public void add_grade (Grade grade) {
        grades_model.insert (0, grade);
    }

    public void add_category (Category category) {
        categories_by_name[category.name] = category;
    }

    public void delete_grade (Grade grade) {
        uint pos;
        if (grades_model.find (grade, out pos)) {
            grades_model.remove (pos);
        }
    }
}
