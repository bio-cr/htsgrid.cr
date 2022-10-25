module HTSGrid
  module Action
    class About
      def initialize(app : Gtk::Application)
        action = Gio::SimpleAction.new("about", nil)
        app.add_action(action)
    
        action.activate_signal.connect do
          Gtk.show_about_dialog(
            app.active_window,
            name: "About HTSGrid",
            application: app,
            program_name: "HTSGrid",
            version: VERSION,
            logo_icon_name: "dev.bio-cr.htsgrid",
            copyright: "© 2022 kojix2",
            website: "https://github.com/bio-cr/htsgrid.cr",
            authors: ["kojix2"],
            artists: ["kojix2"],
            #translator_credits: THANKS,
          )
        end
      end
    end
  end
end