# Stephen Quenzer
# Mark Harder
# ----------
# The spikes class

require_relative 'enemy.rb'

class Spikes < Enemy
  WIDTH = 25
  HEIGHT = 25

  def initialize window, x, y
    images = Gosu::Image::load_tiles(window, "media/Spikes.png", WIDTH, HEIGHT, true)

    super(x, y, WIDTH, HEIGHT, images)
  end
end
