public class Grade : Object{
    public string grade { get; set; }
    public string note { get; set; }
    public string category_name { get; set; }

    public Grade (string grade, string note, string category) {
        Object (
            grade: grade,
            note: note,
            category_name: category
        );
    }
}
