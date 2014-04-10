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
    @leaving = false
  end

  ##
  # Draw the door or animate the player leaving
  def draw size, x_offset, y_offset
    image = @images[0]

    px = @x * size
    py = @y * size

    if @leaving
      if Gosu.milliseconds - @leave_start_milliseconds <= 200
        image = @images[1]
      elsif Gosu.milliseconds - @leave_start_milliseconds <= 400
        image = @images[2]
      elsif Gosu.milliseconds - @leave_start_milliseconds <= 600
        image = @images[3]
      elsif Gosu.milliseconds - @leave_start_milliseconds <= 800
        image = @images[4]
      elsif Gosu.milliseconds - @leave_start_milliseconds <= 1000
        image = @images[5]
      end
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
