module HTSGrid
  module View
    class MainWindow
      def initialize
        @app = Gtk::Application.new("htsgrid.kojix2.com", Gio::ApplicationFlags::None)
        @app.activate_signal.connect(->activate(Gtk::Application))
      end

      def run
        @app.run
      end

      def builder
        @builder ||= Gtk::Builder.new_from_resource("/dev/kojix2/htsgrid/ui/app.ui")
      end

      def list_model
        @list_model ||= Gtk::ListStore.cast(builder["list_model"])
      end

      def window
        @window ||= window = Gtk::ApplicationWindow.cast(builder["window"])
      end

      def activate(app : Gtk::Application)
        open_button = Gtk::Button.cast(builder["open_button"])
        entry = Gtk::Entry.cast(builder["entry"])
        open_button.clicked_signal.connect do
          open_button_clicked(entry.text)
        end
        HTSGrid::Action::About.new(app)
        window.application = app
        tree_view = Gtk::TreeView.cast(builder["tree_view"])
        window.present
      end

      def open_button_clicked(path : String)
        file_chooser_dialog
      end

      def file_chooser_dialog
        dialog = Gtk::FileChooserDialog.new(
          application: @app,
          title: "Open File",
          action: Gtk::FileChooserAction::Open,
          transient_for: window,
          modal: true
        )
        dialog.add_button("Cancel", Gtk::ResponseType::Cancel.value)
        dialog.add_button("Open", Gtk::ResponseType::Accept.value)
        dialog.response_signal.connect do |response|
          case Gtk::ResponseType.from_value(response)
          when .cancel?
          when .accept?
            file_path = dialog.file.try(&.path)
            unless file_path.nil?
              file_path = File.expand_path(file_path, home: Path.home)
              list_model.try { |model| fill_model(model, file_path) }
            end
          end
          dialog.destroy
        end
        dialog.present
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
    end
  end
end
