public class Grade : Object {
    public string grade { get; set; }
    public string date2 { get; set; }
    public string note { get; set; }
    public int day { get; set; }
    public int month { get; set; }
    public int year { get; set; }
    
    public Grade (string g, int d, int m, int y, string n) {
        this.grade = g;
        this.day = d;
        this.month = m;
        this.year = y;
        this.note = n;
    }

    public string give_date () {
        string date = day.to_string () + "/" + month.to_string () + "/" + year.to_string();
        return date;
    }

}