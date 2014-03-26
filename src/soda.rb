# Stephen Quenzer
# Mark Harder
# ----------
# A soda class

require_relative 'candy.rb'

class Soda < Candy
  WIDTH = 10
  HEIGHT = 16

  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/Soda.png", WIDTH, HEIGHT, true)

    super(x, y, WIDTH, HEIGHT, @images, 100)
  end
end
