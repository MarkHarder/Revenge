# Stephen Quenzer
# Mark Harder
# ----------
# The slime class, template for slug slime

require_relative 'enemy.rb'

class Slime < Enemy
  attr_reader :images

  WIDTH = 16
  HEIGHT = 8
  SLIME_TIME = 2000

  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/SlugSlime.png", WIDTH, HEIGHT, true)

    super(x, y, WIDTH, HEIGHT, @images)

    @creation_milliseconds = Gosu.milliseconds
  end

  def update level
    if Gosu.milliseconds - @creation_milliseconds >= SLIME_TIME * 2
      level.enemies.delete(self)
    elsif Gosu.milliseconds - @creation_milliseconds >= SLIME_TIME
      @harmless = true
    end
  end

  def draw size
    image = @images[0]
    image = @images[1] if @harmless

    px = @x * size
    py = @y * size

    image.draw(px, py, 0, size, size)
  end
end
