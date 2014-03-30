require_relative 'enemy.rb'

##
# The spikes class

class Spikes < Enemy
  ##
  # Spike width
  WIDTH = 25
  ##
  # Spike height
  HEIGHT = 25

  ##
  # Create a spike.
  def initialize window, x, y
    images = Gosu::Image::load_tiles(window, "media/Spikes.png", WIDTH, HEIGHT, true)

    super(x, y, WIDTH, HEIGHT, images)
  end
end
