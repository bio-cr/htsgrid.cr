module HTSGrid
  module View
    class HeaderWindow
      def initialize(app : Gtk::Application, parent : Gtk::Window, text : String)
        window.application = app
        window.transient_for = parent
        text_view.buffer.text = text
        window.present
      end

      private def builder
        @builder ||= Gtk::Builder.new_from_resource("/dev/bio-cr/htsgrid/ui/header.ui")
      end

      private def window
        @window ||= Gtk::Window.cast(builder["header_window"])
      end

      private def text_view
        @text_view ||= Gtk::TextView.cast(builder["header_text_view"])
      end
    end
  end
end
