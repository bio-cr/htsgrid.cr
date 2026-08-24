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
    end
  end

  class DocumentLoadError < Exception
  end
end
