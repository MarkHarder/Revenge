# Stephen Quenzer
# Mark Harder
# ----------
# The slug class, template for all slug enemies

require_relative 'enemy.rb'

class Slug < Enemy
  attr_reader :images

  WIDTH = 16
  HEIGHT = 16

  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/SlugSprites.png", 23, 24, true)

    super(x, y, WIDTH, HEIGHT, @images)
  end
end
