# Stephen Quenzer
# Mark Harder
# ----------
# Enemy

require_relative 'rectangle.rb'

class Candy < Rectangle
  attr_reader :value

  def initialize x, y, width, height, images, value
    super x, y, width, height
    @images = images
    @value = value
  end

  def draw size
    px = @x * size
    py = @y * size
    @images[0].draw(px, py, 0, size, size)
  end
end
