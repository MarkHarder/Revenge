# Stephen Quenzer
# Mark Harder
# ----------
# Candy base class
# contains position, dimensions, images, and a value

require_relative 'rectangle.rb'

class Candy < Rectangle
  attr_reader :value

  def initialize x, y, width, height, images, value
    super x, y, width, height
    @images = images
    @value = value
  end

  # draw the image or if an array, the first image of the array
  def draw size
    px = @x * size
    py = @y * size

    image = @images.is_a?(Array) ? @images[0] : @images
    image.draw(px, py, 0, size, size)
  end
end
