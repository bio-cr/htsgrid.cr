module HTSGrid
  module DocumentLoader
    extend self

    def load(file_path : Path | String) : Document
      path = file_path.to_s
      format = detect_format(path)
      case format
      when .sam?, .bam?, .cram?
        load_alignment(path)
      when .vcf?, .bcf?
        load_variant(path)
      else
        raise DocumentLoadError.new("Unsupported file format: #{format}")
      end
    rescue ex : HTS::Error
      raise DocumentLoadError.new(ex.message || "Failed to read #{path}", ex)
    end

    private def detect_format(file_path : Path | String) : HTS::LibHTS::HtsExactFormat
      path = file_path.to_s
      hts_file = HTS::LibHTS.hts_open(path, "r")
      raise DocumentLoadError.new("Failed to open #{path}") if hts_file.null?

      begin
        format = HTS::LibHTS.hts_get_format(hts_file)
        raise DocumentLoadError.new("Failed to inspect the format of #{path}") if format.null?

        format.value.format
      ensure
        HTS::LibHTS.hts_close(hts_file)
      end
    end

    private def load_alignment(file_path : String) : Document
      rows = [] of Array(String)
      header_text = ""
      HTS::Bam.open(file_path) do |bam|
        header_text = bam.header.to_s
        bam.each { |record| rows << AlignmentRow.from(record) }
      end
      Document.new(AlignmentRow::COLUMNS.dup, rows, header_text)
    end

    private def load_variant(file_path : String) : Document
      rows = [] of Array(String)
      columns = VariantRow::COLUMNS.dup
      header_text = ""
      HTS::Bcf.open(file_path) do |bcf|
        header_text = bcf.header.to_s
        samples = bcf.header.samples
        columns.concat(["FORMAT"] + samples) unless samples.empty?
        bcf.each { |record| rows << VariantRow.from(record, columns.size) }
      end
      Document.new(columns, rows, header_text)
    end
  end
end
