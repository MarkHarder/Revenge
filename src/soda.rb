require_relative 'candy.rb'

##
# A soda class

class Soda < Candy
  ##
  # Soda width
  WIDTH = 10
  ##
  # Soda height
  HEIGHT = 16

  ##
  # Create a soda
  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/Soda.png", WIDTH, HEIGHT, true)

    super(x, y, WIDTH, HEIGHT, @images, 100)
  end
end
