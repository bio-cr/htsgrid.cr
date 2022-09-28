require "gtk4"
require "hts"

HTS_VERSION = String.new(HTS::LibHTS.hts_version)

def activate(app : Gtk::Application)
  window = Gtk::ApplicationWindow.new(app)
  window.title = "HTSGrid"
  window.set_default_size(600, 200)

  builder = Gtk::Builder.new_from_file("#{__DIR__}/../data/tree.cmb.ui")
  model = Gtk::TreeStore.cast(builder["tree_model"])
  label = Gtk::Label.cast(builder["label"])
  fill_model(model)

  view = Gtk::TreeView.cast(builder["tree_view"])
  view.row_activated_signal.connect do |path, column|
    iter = model.iter(path)

    value = model.value(iter, 0)
    label.text = "You Clicked on #{value.as_s}"
  end

  box = Gtk::Box.new(orientation: Gtk::Orientation::Vertical)
  label = Gtk::Label.new(HTS_VERSION)
  button = Gtk::Button.new
  button.label = "Hello!"
  button.clicked_signal.connect do
    d = Gtk::FileChooserDialog.new(application: app, title: "Open", action: :open)
    d.add_button("Cancel", Gtk::ResponseType::Cancel.value)
    d.add_button("Open", Gtk::ResponseType::Accept.value)
    d.response_signal.connect do |response|
      case Gtk::ResponseType.from_value(response)
      when .cancel? then puts "Cancelled."
      when .accept? then puts "You choose: #{d.file.try(&.path)}"
      end
      d.destroy
    end
    d.present
  end
  box.append button
  box.append label
  box.append Gtk::Widget.cast(builder["root"])
  window.child = box
  window.present
end

def fill_model(model)
  root = model.append(nil)
  model.set(root, {0}, {"Root"})
  model.insert(root, {0}, {"Child!"}, -1)
end

app = Gtk::Application.new("htsgrid.kojix2.com", Gio::ApplicationFlags::None)
app.activate_signal.connect(->activate(Gtk::Application))

exit(app.run)
