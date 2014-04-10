require_relative 'rectangle.rb'

##
# The exit

class Door < Rectangle
  WIDTH = 32
  HEIGHT = 64

  def initialize window, x, y
    super(x, y, WIDTH, HEIGHT)
    @window = window
    @images = Gosu::Image::load_tiles(window, "media/Door.png", WIDTH, HEIGHT, true)
  end

  ##
  # Draw the door or animate the player leaving
  def draw size, x_offset, y_offset
    image = @images[0]

    px = @x * size
    py = @y * size

    image.draw(px - x_offset, py - y_offset, 0, size, size)
  end
end
