module HTSGrid
  enum FileKind
    Alignment
    Variant
  end

  class Document
    getter kind : FileKind
    getter columns : Array(String)
    getter rows : Array(Array(String))
    getter header_text : String

    def initialize(@kind, @columns, @rows, @header_text)
      if @columns.empty?
        raise DocumentLoadError.new("A document must have at least one column")
      end

      if row = @rows.find { |values| values.size != @columns.size }
        raise DocumentLoadError.new(
          "Document row has #{row.size} columns, expected #{@columns.size}"
        )
      end
    end
  end

  class DocumentLoadError < Exception
  end
end
