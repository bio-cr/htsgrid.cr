require "gtk4"
require "hts"

HTS_VERSION = String.new(HTS::LibHTS.hts_version)

def activate(app : Gtk::Application)
  builder = Gtk::Builder.new_from_file("#{__DIR__}/../data/tree.ui")
  list_model = Gtk::ListStore.cast(builder["list_model"])
  open_button = Gtk::Button.cast(builder["open_button"])
  entry = Gtk::Entry.cast(builder["entry"])
  open_button.clicked_signal.connect do
    file_path = entry.text
    unless file_path.nil?
      fill_model(list_model, file_path)
    end
  end
  window = Gtk::ApplicationWindow.cast(builder["window"])
  window.application = app
  tree_view = Gtk::TreeView.cast(builder["tree_view"])
  window.present
end

def get_file_path(app)
  file_path = ""
  # dialog = Gtk::FileChooserDialog.new(application: app, title: "Open File", action: :open)
  # dialog.add_button("Cancel", Gtk::ResponseType::Cancel.value)
  # dialog.add_button("Open", Gtk::ResponseType::Accept.value)
  # dialog.response_signal.connect do |response|
  #   case Gtk::ResponseType.from_value(response)
  #   when .cancel?
  #   when .accept?
  #     file_path = dialog.file.try(&.path)
  #     puts "File selected: #{file_path}"
  #   end
  #   dialog.destroy
  # end
  # dialog.show
  # dialog.visible = true
  # dialog.present
  file_path
end

def fill_model(model : Gtk::ListStore, file_path)
  begin
    bam = HTS::Bam.open(file_path)
  rescue
    return
  end
  model.clear
  bam.each do |r|
    itr = model.append
    row = [
      r.qname,
      r.flag.to_s,
      r.chrom,
      (r.pos + 1).to_s,
      (r.mapq).to_s,
      r.cigar.to_s,
      r.mate_chrom,
      (r.mpos + 1).to_s,
      r.isize.to_s,
      r.seq,
    ]
    model.set(itr, (0..10), row)
  end
  bam.close
end

app = Gtk::Application.new("htsgrid.kojix2.com", Gio::ApplicationFlags::None)
app.activate_signal.connect(->activate(Gtk::Application))

exit(app.run)
