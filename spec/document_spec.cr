require "./spec_helper"

describe HTSGrid::Document do
  it "rejects documents without columns" do
    expect_raises(HTSGrid::DocumentLoadError, /at least one column/) do
      HTSGrid::Document.new(HTSGrid::FileKind::Alignment, [] of String, [] of Array(String), "")
    end
  end

  it "rejects rows that do not match the column schema" do
    expect_raises(HTSGrid::DocumentLoadError, /1 columns, expected 2/) do
      HTSGrid::Document.new(
        HTSGrid::FileKind::Variant,
        ["CHROM", "POS"],
        [["chr1"]],
        ""
      )
    end
  end
end
