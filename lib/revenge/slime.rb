require_relative 'enemy.rb'

##
# The slime class

class Slime < Enemy
  ##
  # Slime width
  WIDTH = 16
  ##
  # Slime height
  HEIGHT = 8
  ##
  # Time before the slime turns harmless.
  # Same time until it disappears
  SLIME_TIME = 2000

  ##
  # Create a slime.
  # Record the time it was created
  def initialize window, x, y
    images = Gosu::Image::load_tiles(window, "media/SlugSlime.png", WIDTH, HEIGHT, true)

    super(window, x, y, WIDTH, HEIGHT, images)

    @creation_milliseconds = Gosu.milliseconds
  end

  ##
  # Check if the slime is harmless or if it disappears
  def update
    if Gosu.milliseconds - @creation_milliseconds >= SLIME_TIME * 2
      @window.level.enemies.delete(self)
    elsif Gosu.milliseconds - @creation_milliseconds >= SLIME_TIME
      @harmless = true
    end
  end

  ##
  # Draw the slime or the harmless slime
  def draw size, x_offset, y_offset
    image = @images[0]
    image = @images[1] if @harmless

    px = @x * size
    py = @y * size

    image.draw(px - x_offset, py - y_offset, 0, size, size)
  end
end
