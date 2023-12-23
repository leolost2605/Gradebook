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
            { "test", this.on_test_action },
            { "help", this.on_help_action },
            { "about", this.on_about_action },
            { "newsubject", this.on_newsubject_action},
        };
        this.add_action_entries (action_entries, this);
    }

    public void on_test_action () {
        print ("test_action");
    }


    public void on_help_action () {
        Gtk.show_uri (main_window, "https://github.com/leolost2605/Gradebook/wiki", 0);
    }

    public void on_newsubject_action () {
        var dialog = new NewSubjectDialog (main_window);
        dialog.close_request.connect (() => {
            if (dialog.accept) {
                SubjectManager.get_default ().new_subject (dialog.name_entry_box.get_text (), dialog.get_categories ());
            }
            dialog.destroy ();
 	    return true;
        });
        dialog.present ();
    }

    public void on_about_action () {
        var about_window = new Adw.AboutWindow () {
            developer_name = "Leonhard Kargl",
            developers = {"Leonhard Kargl", "ConfusedAlex", "skøldis <gradebook@turtle.garden>"},
            artists = {"Brage Fuglseth"},
            translator_credits = _("translator-credits"),
            application_name = _("Gradebook"),
            application_icon = "io.github.leolost2605.gradebook",
            version = "1.1.1",
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
