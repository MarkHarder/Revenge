# Stephen Quenzer
# Mark Harder
# ----------
# The spikes class

require_relative 'enemy.rb'

class Spikes < Enemy
  attr_reader :images

  WIDTH = 25
  HEIGHT = 25

  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/Spikes.png", 25, 25, true)

    super(x, y, WIDTH, HEIGHT, @images)
  end
end
