require "./spec_helper"
require "hts"
require "../src/htsgrid/version"
require "../src/htsgrid/alignment_row"

describe "HTSGrid::VERSION" do
  it "should be a string" do
    HTSGrid::VERSION.should be_a(String)
  end
end

describe HTSGrid::AlignmentRow do
  header = HTS::Bam::Header.parse("@HD\tVN:1.6\n@SQ\tSN:chr1\tLN:1000\n")

  it "formats all eleven SAM columns with one-based coordinates" do
    record = HTS::Bam::Record.new(
      header: header,
      qname: "read1",
      flag: 99,
      tid: 0,
      pos: 9_i64,
      mapq: 60,
      cigar_words: HTS::Bam::Cigar.encode("4M"),
      seq: "ACGT",
      qual: [30_u8, 30_u8, 30_u8, 30_u8],
      mtid: 0,
      mpos: 19_i64,
      isize: 14_i64
    )

    HTSGrid::AlignmentRow.from(record).should eq([
      "read1", "99", "chr1", "10", "60", "4M",
      "=", "20", "14", "ACGT", "????",
    ])
  end

  it "uses SAM missing-value conventions for an unmapped record" do
    record = HTS::Bam::Record.new(
      header: header,
      qname: "unmapped",
      flag: 4,
      tid: -1,
      pos: -1_i64,
      mapq: 0,
      cigar_words: [] of UInt32,
      seq: "",
      qual: [] of UInt8,
      mtid: -1,
      mpos: -1_i64
    )

    HTSGrid::AlignmentRow.from(record).should eq([
      "unmapped", "4", "*", "0", "0", "*",
      "*", "0", "0", "*", "*",
    ])
  end

  it "formats a record read through the current hts.cr API" do
    File.tempfile("htsgrid", ".sam") do |file|
      file << "@HD\tVN:1.6\n"
      file << "@SQ\tSN:chr1\tLN:1000\n"
      file << "read1\t99\tchr1\t10\t60\t4M\t=\t20\t14\tACGT\t????\n"
      file.flush

      HTS::Bam.open(file.path) do |bam|
        HTSGrid::AlignmentRow.from(bam.first).should eq([
          "read1", "99", "chr1", "10", "60", "4M",
          "=", "20", "14", "ACGT", "????",
        ])
      end
    end
  end
end
