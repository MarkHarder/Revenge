require_relative 'candy.rb'

##
# A chocolate class

class Chocolate < Candy
  ##
  # Soda width
  WIDTH = 13
  ##
  # Soda height
  HEIGHT = 16

  ##
  # Create a gum
  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/Chocolate.png", WIDTH, HEIGHT, true)

    super(x, y, WIDTH, HEIGHT, @images, 400)
  end
end
