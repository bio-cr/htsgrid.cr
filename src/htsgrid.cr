require "gtk4"

app = Gtk::Application.new("htsgrid.kojix2.com", Gio::ApplicationFlags::None)
count = 0

app.activate_signal.connect do
  window = Gtk::ApplicationWindow.new(app)
  window.title = "HTSGrid"
  window.set_default_size(600, 200)
  window.present
end

exit(app.run)
