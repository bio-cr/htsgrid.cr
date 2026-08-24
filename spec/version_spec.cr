require "./spec_helper"

describe HTSGrid::VERSION do
  it "is a string" do
    HTSGrid::VERSION.should be_a(String)
  end
end
