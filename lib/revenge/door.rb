require_relative 'rectangle.rb'

##
# The exit

class Door < Rectangle
  WIDTH = 32
  HEIGHT = 64

  def initialize(window, x, y)
    super(x, y, WIDTH, HEIGHT)
    @window = window
    @images = Gosu::Image::load_tiles(window, "media/Door.png", WIDTH, HEIGHT, true)
    @leaving = false
  end

  ##
  # Draw the door or animate the player leaving
  def draw(size, x_offset, y_offset)
    image = @images[0]

    px = @x * size
    py = @y * size

    if @leaving
      elapsed_time = Gosu.milliseconds - @leave_start_milliseconds
      image = @images[(elapsed_time / 200).to_i + 1] || @images[-1]
    end

    image.draw(px - x_offset, py - y_offset, 0, size, size)
  end

  ##
  # animate the player leaving
  def leave
    @leaving = true
    @leave_start_milliseconds = Gosu.milliseconds
  end
end
