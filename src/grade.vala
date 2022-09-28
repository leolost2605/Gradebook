public class Grade : Object {
    public int grade { get; set; }
    public string date { get; set; }
    public string note { get; set; }
    
    public Grade (int g, string d, string n) {
        this.grade = g;
        this.date = d;
        this.note = n;
    }

}