require_relative 'rectangle.rb'

##
# Enemy base class
#
# contains the position, dimensions, and images
# along with base methods for drawing and updating

class Enemy < Rectangle
  attr_reader :images

  ##
  # Creates a new enemy
  #
  # Positioned at (x, y) and with the given width and height
  def initialize x, y, width, height, images
    super x, y, width, height
    @images = images
  end

  # basic update loop, override in specific enemy classes
  def update level
  end

  ##
  # draw the image or if an array, the first image of the array
  def draw size, x_offset, y_offset
    px = @x * size
    py = @y * size

    image = @images.is_a?(Array) ? @images[0] : @images
    image.draw(px - x_offset, py - y_offset, 0, size, size)
  end

  ##
  # check if the enemy will kill the player
  # default is not harmless - if the player intersects the enemy they will die
  def harmless?
    false
  end
end
