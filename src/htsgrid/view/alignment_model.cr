module HTSGrid
  module View
    class AlignmentItem < GObject::Object
      getter values : Array(String)

      def initialize(@values : Array(String))
        super()
      end
    end

    class AlignmentModel < GObject::Object
      include Gio::ListModel

      @items = [] of AlignmentItem

      def add(values : Array(String)) : Nil
        position = @items.size.to_u32
        @items << AlignmentItem.new(values)
        items_changed(position, 0, 1)
      end

      def clear : Nil
        removed = @items.size.to_u32
        return if removed == 0

        @items.clear
        items_changed(0, removed, 0)
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
        AlignmentItem.g_type
      end
    end
  end
end
