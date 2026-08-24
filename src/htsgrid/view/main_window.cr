module HTSGrid
  module View
    class MainWindow
      APPLICATION_ID = "dev.bio-cr.htsgrid"
      FILE_PATTERNS  = ["*.sam", "*.bam", "*.cram", "*.vcf", "*.vcf.gz", "*.bcf"]

      getter file_path : String? = nil

      def initialize
        @application = Gtk::Application.new(APPLICATION_ID, Gio::ApplicationFlags::None)
        @activated = false
        @document = nil.as(Document?)
        @application.activate_signal.connect { activate }
      end

      def run
        @application.run
      end

      private def ui_builder
        @ui_builder ||= Gtk::Builder.new_from_resource("/dev/bio-cr/htsgrid/ui/app.ui")
      end

      private def table_view
        @table_view ||= Gtk::ColumnView.cast(ui_builder["table_view"])
      end

      private def document_table
        @document_table ||= DocumentTable.new(table_view)
      end

      private def window
        @window ||= Gtk::ApplicationWindow.cast(ui_builder["window"])
      end

      private def activate : Nil
        unless @activated
          setup_button("open_button", ->open_button_clicked)
          setup_button("header_button", ->header_button_clicked)
          HTSGrid::Action::About.register(@application)
          window.application = @application
          document_table
          @activated = true
        end
        window.present
      end

      private def setup_button(button_name : String, callback) : Nil
        button = Gtk::Button.cast(ui_builder[button_name])
        button.clicked_signal.connect(&callback)
      end

      private def open_button_clicked : Nil
        filters, default_filter = build_file_filters
        dialog = Gtk::FileDialog.new(
          title: "Open File",
          modal: true,
          filters: filters,
          default_filter: default_filter
        )
        dialog.open(window, nil) do |_, result|
          execute_file_response(dialog.open_finish(result))
        rescue Gio::IOErrorEnum::Cancelled
          # Closing the dialog is an expected outcome.
        rescue ex
          STDERR.puts "Failed to select a file: #{ex.message}"
        end
      end

      private def execute_file_response(file : Gio::File) : Nil
        if path = file.path
          file_path = path.to_s
          file_path = File.expand_path(file_path, home: Path.home)
          document = load_document(file_path)
          return unless document

          apply_document(document)
          window.title = file_path
          @file_path = file_path
        end
      end

      private def build_file_filters : Tuple(Gio::ListStore, Gtk::FileFilter)
        supported_filter = Gtk::FileFilter.new(
          name: "HTS files",
          patterns: FILE_PATTERNS
        )
        all_filter = Gtk::FileFilter.new(name: "All files", patterns: ["*"])
        filters = Gio::ListStore.new(Gtk::FileFilter.g_type)
        filters.append(supported_filter)
        filters.append(all_filter)
        {filters, supported_filter}
      end

      private def header_button_clicked : Nil
        if document = @document
          HeaderWindow.new(@application, window, document.header_text)
        end
      end

      private def load_document(file_path : String) : Document?
        DocumentLoader.load(file_path)
      rescue ex : DocumentLoadError
        STDERR.puts "Failed to read #{file_path}: #{ex.message}"
        nil
      end

      private def apply_document(document : Document) : Nil
        document_table.display(document)
        @document = document
      end
    end
  end
end
