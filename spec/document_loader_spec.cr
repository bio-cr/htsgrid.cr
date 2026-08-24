require "./spec_helper"
require "hts"
require "compress/gzip"
require "../src/htsgrid/document"
require "../src/htsgrid/alignment_row"
require "../src/htsgrid/variant_row"
require "../src/htsgrid/document_loader"

private def with_temp_hts_file(contents : String, &)
  File.tempfile("htsgrid", ".data") do |file|
    file << contents
    file.flush
    yield file.path
  end
end

private def multisample_vcf : String
  <<-VCF
  ##fileformat=VCFv4.3
  ##contig=<ID=chr1,length=1000>
  ##FILTER=<ID=q10,Description="Quality below 10">
  ##FILTER=<ID=s50,Description="Less than 50 percent samples">
  ##INFO=<ID=DP,Number=1,Type=Integer,Description="Read depth">
  ##INFO=<ID=SOMATIC,Number=0,Type=Flag,Description="Somatic variant">
  ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
  ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Sample depth">
  #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	sample1	sample2
  chr1	10	rs1	A	C,G	42.5	q10;s50	DP=12;SOMATIC	GT:DP	0/1:7	1/2:5
  VCF
end

describe HTSGrid::DocumentLoader do
  it "detects and loads alignment data independently of the extension" do
    sam = "@HD\tVN:1.6\n@SQ\tSN:chr1\tLN:1000\nread1\t0\tchr1\t10\t60\t4M\t*\t0\t0\tACGT\t????\n"

    with_temp_hts_file(sam) do |path|
      document = HTSGrid::DocumentLoader.load(path)
      document.kind.alignment?.should be_true
      document.columns.should eq(HTSGrid::DocumentLoader::ALIGNMENT_COLUMNS)
      document.rows.should eq([
        ["read1", "0", "chr1", "10", "60", "4M", "*", "0", "0", "ACGT", "????"],
      ])
      document.header_text.should contain("@SQ\tSN:chr1")
    end
  end

  it "loads all VCF columns including FORMAT and multiple samples" do
    with_temp_hts_file(multisample_vcf) do |path|
      document = HTSGrid::DocumentLoader.load(path)
      document.kind.variant?.should be_true
      document.columns.should eq([
        "CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO",
        "FORMAT", "sample1", "sample2",
      ])
      document.rows.should eq([
        ["chr1", "10", "rs1", "A", "C,G", "42.5", "q10;s50", "DP=12;SOMATIC", "GT:DP", "0/1:7", "1/2:5"],
      ])
      document.header_text.should contain("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsample1\tsample2")
    end
  end

  it "loads a sample-free VCF and preserves missing values" do
    vcf = <<-VCF
    ##fileformat=VCFv4.3
    ##contig=<ID=chr1,length=1000>
    #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
    chr1	20	.	G	T	.	.	.
    VCF

    with_temp_hts_file(vcf) do |path|
      document = HTSGrid::DocumentLoader.load(path)
      document.columns.should eq(HTSGrid::DocumentLoader::VARIANT_COLUMNS)
      document.rows.should eq([
        ["chr1", "20", ".", "G", "T", ".", ".", "."],
      ])
    end
  end

  it "loads gzip-compressed VCF by its content" do
    File.tempfile("htsgrid", ".data") do |file|
      path = file.path
      file.close
      Compress::Gzip::Writer.open(path) { |gzip| gzip << multisample_vcf }

      document = HTSGrid::DocumentLoader.load(path)
      document.kind.variant?.should be_true
      document.rows.first[0, 5].should eq(["chr1", "10", "rs1", "A", "C,G"])
    end
  end

  it "loads BCF as the same VCF table independently of the extension" do
    with_temp_hts_file(multisample_vcf) do |vcf_path|
      expected = HTSGrid::DocumentLoader.load(vcf_path)

      File.tempfile("htsgrid", ".data") do |bcf_file|
        bcf_path = bcf_file.path
        bcf_file.close
        HTS::Bcf.open(vcf_path) do |source|
          HTS::Bcf.open(bcf_path, "wb") do |destination|
            destination.write_header(source.header)
            source.each { |record| destination << record }
          end
        end

        document = HTSGrid::DocumentLoader.load(bcf_path)
        document.kind.variant?.should be_true
        document.columns.should eq(expected.columns)
        document.rows.should eq(expected.rows)
        document.header_text.should contain("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsample1\tsample2")
      end
    end
  end

  it "rejects unsupported content" do
    with_temp_hts_file("not an HTS file\n") do |path|
      expect_raises(HTSGrid::DocumentLoadError, /Unsupported file format/) do
        HTSGrid::DocumentLoader.load(path)
      end
    end
  end

  it "rejects a normalized VCF record whose columns do not match the expected schema" do
    vcf = <<-VCF
    ##fileformat=VCFv4.3
    ##contig=<ID=chr1,length=1000>
    #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
    chr1	20	.	G	T	.	.	.
    VCF

    with_temp_hts_file(vcf) do |path|
      HTS::Bcf.open(path) do |bcf|
        expect_raises(HTSGrid::DocumentLoadError, /8 columns, expected 9/) do
          HTSGrid::VariantRow.from(bcf.first, 9)
        end
      end
    end
  end
end
