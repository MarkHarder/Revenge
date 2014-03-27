# Stephen Quenzer
# Mark Harder
# ----------
# Enemy base class
# contains the position, dimensions, and images
# along with base methods for drawing and updating

require_relative 'rectangle.rb'

class Enemy < Rectangle
  attr_reader :images

  def initialize x, y, width, height, images
    super x, y, width, height
    @images = images
  end

  # basic update loop, override in specific enemy classes
  def update level
  end

  # draw the first image of the given array
  def draw size
    px = @x * size
    py = @y * size

    image = @images.is_a?(Array) ? @images[0] : @images
    image.draw(px, py, 0, size, size)
  end

  # check if the enemy will kill you or not
  # default is not harmless
  def harmless?
    false
  end
end
