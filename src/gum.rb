require_relative 'candy.rb'

##
# A gum class

class Gum < Candy
  ##
  # Soda width
  WIDTH = 16
  ##
  # Soda height
  HEIGHT = 16

  ##
  # Create a gum
  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/Gum.png", WIDTH, HEIGHT, true)

    super(x, y, WIDTH, HEIGHT, @images, 200)
  end
end
