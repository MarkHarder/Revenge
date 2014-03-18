# Stephen Quenzer
# Mark Harder
# ----------
# A class to store information about the player

class Player
  def initialize window
    @x = 20
    @y = 20

    @sprites = Gosu::Image::load_tiles(window, "media/PlayerSprites.png", 32, 32, true)

    @window = window
  end

  def update
    if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight
      @x += 1
    elsif @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft
      @x -= 1
    end
 

    @y += 1
  end

  # draw the player on the screen
  def draw size
    # get the first image
    image = @sprites[0]

    # upper left corner of player
    px = @x * size - 8 * size
    py = @y * size - 4 * size

    # draw the image scaled to size
    image.draw(px, py, 0, size, size)
  end
end
