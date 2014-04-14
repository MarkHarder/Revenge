require_relative 'rectangle.rb'

##
# Enemy base class
#
# contains the position, dimensions, and images
# along with base methods for drawing and updating

class Enemy < Rectangle
  attr_reader :images, :invincible

  ##
  # Creates a new enemy
  #
  # Positioned at (x, y) and with the given width and height 
  def initialize(window, x, y, width, height, images)
    super x, y, width, height
    @images = images
    @window = window

    @harmless = false
    @invincible = true
    
    #@healthbar = Gosu::Image.new(window, "media/healthbar.png", 20px, 5px, true)
    @healthbar = Gosu::Image.new(window, 'media/healthbar.png', false)
  end

  # basic update loop, override in specific enemy classes
  def update
  end

  ##
  # draw the image or if an array, the first image of the array
  def draw size, x_offset, y_offset
    px = @x * size
    py = @y * size

    image = @images.is_a?(Array) ? @images[0] : @images
    image.draw(px - x_offset, py - y_offset, 0, size, size)


  end

  ##
  # check if the enemy will kill the player
  # default is not harmless - if the player intersects the enemy they will die
  def harmless?
    @harmless
  end
  def drawHealth health, size, px, py
    unless health <= 0
      px = px + 15
      py = py - 20
      @healthbar.draw_as_quad(px, py, 0xffffffff, px+health*10, py, 0xffffffff, px+health*10, py+10, 0xffffffff, px, py+10, 0xffffffff, 10)
    end
  end
end
