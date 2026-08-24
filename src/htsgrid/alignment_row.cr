module HTSGrid
  module AlignmentRow
    extend self

    COLUMNS = %w[QNAME FLAG RNAME POS MAPQ CIGAR RNEXT PNEXT TLEN SEQ QUAL]

    def from(record : HTS::Bam::Record) : Array(String)
      chrom = record.chrom
      mate_chrom = record.mate_chrom

      [
        value_or_missing(record.qname),
        record.flag_value.to_s,
        value_or_missing(chrom),
        (record.pos + 1).to_s,
        record.mapq.to_s,
        value_or_missing(record.cigar.to_s),
        mate_reference(chrom, mate_chrom),
        (record.mate_pos + 1).to_s,
        record.insert_size.to_s,
        value_or_missing(record.sequence),
        value_or_missing(record.qual_string),
      ]
    end

    private def value_or_missing(value : String) : String
      value.empty? ? "*" : value
    end

    private def mate_reference(chrom : String, mate_chrom : String) : String
      return "*" if mate_chrom.empty?
      return "=" if !chrom.empty? && mate_chrom == chrom

      mate_chrom
    end
  end
end
