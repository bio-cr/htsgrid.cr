module HTSGrid
  module View
    class HeaderWindow
      def initialize(app : Gtk::Application)
        @app = app
        activate
      end

      private def builder
        @builder ||= Gtk::Builder.new_from_resource("/dev/bio-cr/htsgrid/ui/app.ui")
      end

      private def window
        @window ||= Gtk::Window.cast(builder["header_window"])
      end

      private def text_view
        @text_view ||= Gtk::TextView.cast(builder["header_text_view"])
      end

      def activate
        window.application = @app
        window.present
      end

      def text=(text : String)
        text_view.buffer.text = text
      end
    end
  end
end