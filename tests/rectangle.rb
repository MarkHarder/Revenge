require_relative '../src/rectangle.rb'

describe Rectangle do
  it "collides with rectangles" do
    a = Rectangle.new(0, 0, 10, 10)
    b = Rectangle.new(5, 5, 10, 10)

    a.intersect?(b).should eq(true)
  end
end
