module HTSGrid
  module View
    class MainWindow
      getter file_path : String

      def initialize
        @app = Gtk::Application.new("htsgrid.bio-cr.com", Gio::ApplicationFlags::None)
        @app.activate_signal.connect(->activate(Gtk::Application))
        @file_path = ""
      end

      def run
        @app.run
      end

      private def builder
        @builder ||= Gtk::Builder.new_from_resource("/dev/bio-cr/htsgrid/ui/app.ui")
      end

      private def list_model
        @list_model ||= Gtk::ListStore.cast(builder["list_model"])
      end

      private def window
        @window ||= window = Gtk::ApplicationWindow.cast(builder["window"])
      end

      def activate(app : Gtk::Application)
        open_button = Gtk::Button.cast(builder["open_button"])
        open_button.clicked_signal.connect(->open_button_clicked)

        header_button = Gtk::Button.cast(builder["header_button"])
        header_button.clicked_signal.connect(->header_button_clicked)

        HTSGrid::Action::About.new(app)
        window.application = app
        tree_view = Gtk::TreeView.cast(builder["tree_view"])
        window.present
      end

      def open_button_clicked
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
            execute_file_response(dialog)
          end
          dialog.destroy
        end
        dialog.present
      end

      private def execute_file_response(dialog)
        file_path = dialog.file.try(&.path)
        return if file_path.nil?

        file_path = File.expand_path(file_path, home: Path.home)
        list_model.try { |m| fill_model(m, file_path) }
        window.title = file_path
        @file_path = file_path
      end

      def header_button_clicked
        header_string = fetch_header_from_file
        return if header_string.nil?

        instantiate_header_window(header_string)
      end

      private def instantiate_header_window(header_string)
        hw = HeaderWindow.new(@app)
        hw.text = header_string
      end

      private def fetch_header_from_file
        hts = HTS::Bam.open(file_path)
        hts.header.to_s
      rescue
        nil
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
          row = prepare_row(r)
          model.set(itr, (0..10), row)
        end
        bam.close
      end

      private def prepare_row(r)
        [
          r.qname,
          r.flag.to_s,
          r.chrom,
          r.pos.to_s,
          r.mapq.to_s,
          r.cigar.to_s,
          r.mate_chrom,
          (r.mpos + 1).to_s,
          r.isize.to_s,
          r.seq,
        ]
      end
    end
  end
end
