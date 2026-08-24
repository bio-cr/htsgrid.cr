module HTSGrid
  module View
    class MainWindow
      COLUMN_TITLES = %w[QNAME FLAG RNAME POS MAPQ CIGAR RNEXT PNEXT TLEN SEQ QUAL]

      getter file_path : String? = nil

      def initialize
        @app_instance = Gtk::Application.new("htsgrid.bio-cr.com", Gio::ApplicationFlags::None)
        @activated = false
        @app_instance.activate_signal.connect { activate(@app_instance) }
      end

      def run
        @app_instance.run
      end

      private def ui_builder
        @ui_builder ||= Gtk::Builder.new_from_resource("/dev/bio-cr/htsgrid/ui/app.ui")
      end

      private def alignment_model
        @alignment_model ||= AlignmentModel.new
      end

      private def column_view
        @column_view ||= Gtk::ColumnView.cast(ui_builder["alignment_view"])
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
          setup_alignment_view
          @activated = true
        end
        window.present
      end

      private def setup_alignment_view
        column_view.model = Gtk::NoSelection.new(model: alignment_model)
        COLUMN_TITLES.each_with_index do |title, index|
          column_view.append_column(build_column(title, index))
        end
      end

      private def build_column(title : String, index : Int32) : Gtk::ColumnViewColumn
        factory = Gtk::SignalListItemFactory.new
        factory.setup_signal.connect do |object|
          Gtk::ListItem.cast(object).child = Gtk::Label.new(xalign: 0.0_f32)
        end
        factory.bind_signal.connect do |object|
          list_item = Gtk::ListItem.cast(object)
          item = list_item.item.as(AlignmentItem)
          list_item.child.as(Gtk::Label).label = item.values[index]
        end
        Gtk::ColumnViewColumn.new(title: title, factory: factory, resizable: true)
      end

      def setup_button(button_name, callback)
        button = Gtk::Button.cast(ui_builder[button_name])
        button.clicked_signal.connect(&callback)
      end

      def open_button_clicked
        dialog = Gtk::FileDialog.new(
          title: "Open File",
          modal: true
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
          return unless fill_model(file_path)

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
          HTS::Bam.open(file_path.not_nil!) do |bam|
            bam.header.to_s
          end
        end
      rescue ex : HTS::Error
        STDERR.puts "Failed to read the header: #{ex.message}"
        nil
      end

      def fill_model(file_path) : Bool
        alignment_model.clear
        HTS::Bam.open(file_path) do |bam|
          bam.each do |record|
            alignment_model.add(HTSGrid::AlignmentRow.from(record))
          end
        end
        true
      rescue ex : HTS::Error
        STDERR.puts "Failed to read #{file_path}: #{ex.message}"
        false
      end
    end
  end
end
