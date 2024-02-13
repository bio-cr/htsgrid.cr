require "./spec_helper"
require "../src/htsgrid/version"

describe "HTSGrid::VERSION" do
  it "should be a string" do
    HTSGrid::VERSION.should be_a(String)
  end
end
