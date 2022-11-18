public class Subject : Object{
    public string name { get; set; }
    public Grade[] grades { get; set; }
    public Category[] categories { get; set; }

    public Subject (string n, Category[] c) {
        name = n;
        grades = new Grade[20];
        categories = c;
    }
}
