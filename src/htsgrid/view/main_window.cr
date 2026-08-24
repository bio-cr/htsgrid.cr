module HTSGrid
  module View
    class MainWindow
      getter file_path : String? = nil

      def initialize
        @app_instance = Gtk::Application.new("htsgrid.bio-cr.com", Gio::ApplicationFlags::None)
        @activated = false
        @document = nil.as(Document?)
        @columns = [] of Gtk::ColumnViewColumn
        @app_instance.activate_signal.connect { activate(@app_instance) }
      end

      def run
        @app_instance.run
      end

      private def ui_builder
        @ui_builder ||= Gtk::Builder.new_from_resource("/dev/bio-cr/htsgrid/ui/app.ui")
      end

      private def table_model
        @table_model ||= TableModel.new
      end

      private def table_view
        @table_view ||= Gtk::ColumnView.cast(ui_builder["table_view"])
      end

      private def window
        @window ||= Gtk::ApplicationWindow.cast(ui_builder["window"])
      end

      def activate(app_instance : Gtk::Application)
        unless @activated
          setup_button("open_button", ->open_button_clicked)
          setup_button("header_button", ->header_button_clicked)
          HTSGrid::Action::About.new(app_instance)
          window.application = app_instance
          setup_table_view
          @activated = true
        end
        window.present
      end

      private def setup_table_view
        table_view.model = Gtk::NoSelection.new(model: table_model)
        configure_columns(DocumentLoader::ALIGNMENT_COLUMNS)
      end

      private def build_column(title : String, index : Int32) : Gtk::ColumnViewColumn
        factory = Gtk::SignalListItemFactory.new
        factory.setup_signal.connect do |object|
          Gtk::ListItem.cast(object).child = Gtk::Label.new(xalign: 0.0_f32)
        end
        factory.bind_signal.connect do |object|
          list_item = Gtk::ListItem.cast(object)
          item = list_item.item.as(TableItem)
          list_item.child.as(Gtk::Label).label = item.values[index]
        end
        Gtk::ColumnViewColumn.new(title: title, factory: factory, resizable: true)
      end

      def setup_button(button_name, callback)
        button = Gtk::Button.cast(ui_builder[button_name])
        button.clicked_signal.connect(&callback)
      end

      def open_button_clicked
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

      private def execute_file_response(file : Gio::File)
        if (path = file.path)
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
          patterns: ["*.sam", "*.bam", "*.cram", "*.vcf", "*.vcf.gz", "*.bcf"]
        )
        all_filter = Gtk::FileFilter.new(name: "All files", patterns: ["*"])
        filters = Gio::ListStore.new(Gtk::FileFilter.g_type)
        filters.append(supported_filter)
        filters.append(all_filter)
        {filters, supported_filter}
      end

      def header_button_clicked
        if (document = @document)
          instantiate_header_window(document.header_text)
        end
      end

      private def instantiate_header_window(header_string)
        header_window = HeaderWindow.new(@app_instance)
        header_window.text = header_string
      end

      private def load_document(file_path : String) : Document?
        DocumentLoader.load(file_path)
      rescue ex : DocumentLoadError
        STDERR.puts "Failed to read #{file_path}: #{ex.message}"
        nil
      end

      private def apply_document(document : Document) : Nil
        table_model.replace([] of Array(String))
        configure_columns(document.columns)
        table_model.replace(document.rows)
        @document = document
      end

      private def configure_columns(titles : Enumerable(String)) : Nil
        @columns.each { |column| table_view.remove_column(column) }
        @columns.clear
        titles.each_with_index do |title, index|
          column = build_column(title, index)
          @columns << column
          table_view.append_column(column)
        end
      end
    end
  end
end
