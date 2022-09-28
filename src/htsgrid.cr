require "gtk4"
require "hts"

HTS_VERSION = String.new(HTS::LibHTS.hts_version)

def activate(app : Gtk::Application)
  builder = Gtk::Builder.new_from_file("#{__DIR__}/../data/tree.ui")
  list_model = Gtk::ListStore.cast(builder["list_model"])
  fill_model(list_model)
  window = Gtk::ApplicationWindow.cast(builder["window"])
  window.application = app
  tree_view = Gtk::TreeView.cast(builder["tree_view"])
  window.present
end

def fill_model(model : Gtk::ListStore)
  HTS::Bam.open("/home/kojix2/Ruby/ruby-htslib/test/fixtures/poo.sort.bam") do |bam|
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
  end
end

app = Gtk::Application.new("htsgrid.kojix2.com", Gio::ApplicationFlags::None)
app.activate_signal.connect(->activate(Gtk::Application))

exit(app.run)
