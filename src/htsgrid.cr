require "gtk4"
require "hts"

HTS_VERSION = String.new(HTS::LibHTS.hts_version)

def activate(app : Gtk::Application)
  builder = Gtk::Builder.new_from_file("#{__DIR__}/../data/tree.cmb.ui")
  list_model = Gtk::ListStore.cast(builder["list_model"])
  itr = list_model.append()
  list_model.set(itr, {0}, {"Hello"})
  window = Gtk::ApplicationWindow.cast(builder["window"])
  window.application = app
  tree_view = Gtk::TreeView.cast(builder["tree_view"])
  window.present
end

app = Gtk::Application.new("htsgrid.kojix2.com", Gio::ApplicationFlags::None)
app.activate_signal.connect(->activate(Gtk::Application))

exit(app.run)
