module HTSGrid
  module View
    class DocumentTable
      def initialize(@view : Gtk::ColumnView)
        @model = TableModel.new
        @columns = [] of Gtk::ColumnViewColumn
        @view.model = Gtk::NoSelection.new(model: @model)
        configure_columns(AlignmentRow::COLUMNS)
      end

      def display(document : Document) : Nil
        @model.replace([] of Array(String))
        configure_columns(document.columns)
        @model.replace(document.rows)
      end

      private def configure_columns(titles : Enumerable(String)) : Nil
        @columns.each { |column| @view.remove_column(column) }
        @columns.clear

        titles.each_with_index do |title, index|
          column = build_column(title, index)
          @columns << column
          @view.append_column(column)
        end
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
    end
  end
end
