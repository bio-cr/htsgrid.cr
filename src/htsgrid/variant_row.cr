module HTSGrid
  module VariantRow
    extend self

    def from(record : HTS::Bcf::Record, expected_size : Int32) : Array(String)
      values = record.to_s.chomp.split('\t')
      unless values.size == expected_size
        raise DocumentLoadError.new(
          "VCF record has #{values.size} columns, expected #{expected_size}: #{record.chrom}:#{record.pos + 1}"
        )
      end
      values
    end
  end
end
