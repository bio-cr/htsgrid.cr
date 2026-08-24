module HTSGrid
  module View
    class TableItem < GObject::Object
      getter values : Array(String)

      def initialize(@values : Array(String))
        super()
      end
    end

    class TableModel < GObject::Object
      include Gio::ListModel

      @items = [] of TableItem

      def replace(rows : Enumerable(Array(String))) : Nil
        removed = @items.size.to_u32
        new_items = rows.map { |values| TableItem.new(values) }.to_a
        return if removed == 0 && new_items.empty?

        @items = new_items
        items_changed(0, removed, @items.size.to_u32)
      end

      @[GObject::Virtual]
      def get_n_items : UInt32
        @items.size.to_u32
      end

      @[GObject::Virtual]
      def get_item(position : UInt32) : GObject::Object?
        @items[position]?
      end

      @[GObject::Virtual]
      def get_item_type : UInt64
        TableItem.g_type
      end
    end
  end
end
