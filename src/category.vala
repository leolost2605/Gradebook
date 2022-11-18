public class Category : Object {
    public string name { get; set; }
    public double percentage { get; set; }

    public Category (string n, double p) {
        name = n;
        percentage = p;
    }
}