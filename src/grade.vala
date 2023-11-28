public class Grade : Object{
    public string grade { get; set; }
    public string note { get; set; }
    public string category_name { get; set; }
    public int cat { get; set; }

    public Grade (string g, string n, int c) {
        this.grade = g;
 	this.note = n;
        this.cat = c;
    }

}
