public class MyApp : Adw.Application {
    private Window main_window;

    public MyApp () {
        Object (
            application_id: "io.github.leolost2605.gradebook",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    construct {
        ActionEntry[] action_entries = {
            { "help", this.on_help_action },
            { "about", this.on_about_action },
            { "newsubject", this.on_newsubject_action},
        };
        this.add_action_entries (action_entries, this);
    }

    public void on_help_action () {
        var uri_launcher = new Gtk.UriLauncher ("https://github.com/leolost2605/Gradebook/wiki");
        uri_launcher.launch.begin (main_window, null);
    }

    public void on_newsubject_action () {
        new EditSubjectDialog (main_window, null).present ();
    }

    public void on_about_action () {
        var about_window = new Adw.AboutWindow () {
            developer_name = "Leonhard Kargl",
            developers = {"Leonhard Kargl", "ConfusedAlex", "skøldis <gradebook@turtle.garden>"},
            artists = {"Brage Fuglseth"},
            translator_credits = _("translator-credits"),
            application_name = _("Gradebook"),
            application_icon = "io.github.leolost2605.gradebook",
            version = "1.2",
            license_type = GPL_3_0,
            website = "https://github.com/leolost2605/Gradebook",
            issue_url = "https://github.com/leolost2605/Gradebook/issues",
            modal = true,
            transient_for = main_window
        };
        about_window.present ();
    }

    protected override void activate () {
        main_window = new Window (this);
        main_window.present ();
    }

    public static int main (string[] args)
    {
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);
        return new MyApp ().run (args);
    }
}
