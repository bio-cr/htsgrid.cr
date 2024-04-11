module HTSGrid
  module View
    class MainWindow
      getter file_path : String? = nil

      def initialize
        @app_instance = Gtk::Application.new("htsgrid.bio-cr.com", Gio::ApplicationFlags::None)
        @app_instance.activate_signal.connect { activate(@app_instance) }
      end

      def run
        @app_instance.run
      end

      private def ui_builder
        @ui_builder ||= Gtk::Builder.new_from_resource("/dev/bio-cr/htsgrid/ui/app.ui")
      end

      private def list_model
        @list_model ||= Gtk::ListStore.cast(ui_builder["list_model"])
      end

      private def window
        @window ||= Gtk::ApplicationWindow.cast(ui_builder["window"])
      end

      def activate(app_instance : Gtk::Application)
        setup_button("open_button", ->open_button_clicked)
        setup_button("header_button", ->header_button_clicked)

        HTSGrid::Action::About.new(app_instance)
        window.application = app_instance
        Gtk::TreeView.cast(ui_builder["tree_view"])
        window.present
      end

      def setup_button(button_name, callback)
        button = Gtk::Button.cast(ui_builder[button_name])
        button.clicked_signal.connect(&callback)
      end

      def open_button_clicked
        dialog = setup_file_chooser_dialog
        setup_dialog_response(dialog)
        dialog.present
      end

      private def setup_file_chooser_dialog
        Gtk::FileChooserDialog.new(
          application: @app_instance,
          title: "Open File",
          action: Gtk::FileChooserAction::Open,
          transient_for: window,
          modal: true
        ).tap do |dialog|
          dialog.add_button("Cancel", Gtk::ResponseType::Cancel.value)
          dialog.add_button("Open", Gtk::ResponseType::Accept.value)
        end
      end

      private def setup_dialog_response(dialog)
        dialog.response_signal.connect do |response|
          case Gtk::ResponseType.from_value(response)
          when .cancel?
          when .accept?
            execute_file_response(dialog)
          end
          dialog.destroy
        end
      end

      private def execute_file_response(dialog)
        if (file_path = dialog.file.try(&.path))
          file_path = File.expand_path(file_path, home: Path.home)
          list_model.try { |m| fill_model(m, file_path) }
          window.title = file_path
          @file_path = file_path
        end
      end

      def header_button_clicked
        if (header_string = fetch_header_from_file)
          instantiate_header_window(header_string)
        end
      end

      private def instantiate_header_window(header_string)
        header_window = HeaderWindow.new(@app_instance)
        header_window.text = header_string
      end

      private def fetch_header_from_file
        if file_path
          bam_handle = HTS::Bam.open(file_path.not_nil!)
          bam_handle.header.to_s
        end
      end

      def fill_model(model : Gtk::ListStore, file_path)
        begin
          bam = HTS::Bam.open(file_path)
        rescue
          return
        end
        model.clear
        bam.each do |record|
          new_row = model.append
          row = prepare_row(record)
          model.set(new_row, (0..10), row)
        end
        bam.close
      end

      private def prepare_row(record)
        [
          record.qname,
          record.flag.to_s,
          record.chrom,
          record.pos.to_s,
          record.mapq.to_s,
          record.cigar.to_s,
          record.mate_chrom,
          (record.mpos + 1).to_s,
          record.isize.to_s,
          record.seq,
        ]
      end
    end
  end
end
