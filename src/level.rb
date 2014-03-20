# Stephen Quenzer
# Mark Harder
# ----------
# A basic level template

require_relative 'rectangle.rb'

class Level
  attr_reader :platforms

  WIDTH = 10
  HEIGHT = 10

  def initialize window
    # a grid representing the tiles of the level
    # . = empty background
    # - = platform
    @tiles = %w(
      . . . . . . . . . .
      . . . . . . . . . .
      . . . . . . . . . .
      . . . . . . . . . .
      - . . . . . . . . .
      . . . . . . . . . .
      . . . . . . . . . .
      - - - - - - - - - -
      . . . . . . . . . .
      . . . . . . . . . .
    )

    @terrain = Gosu::Image::load_tiles(window, "media/Terrain.png", 32, 50, true)
    @platforms = []

    # add all the rectangles to check for collision
    0.upto(WIDTH - 1) do |x|
      0.upto(HEIGHT - 1) do |y|
        @platforms.push(Rectangle.new(x * 32, y * 25 - 12, 32, 37)) if @tiles[x + y * WIDTH] == '-'
      end
    end

    @window = window
  end

  # draw the level on the screen
  # draw the background and platforms
  def draw size
    # draw background first
    0.upto(WIDTH - 1) do |x|
      (HEIGHT - 1).downto(0) do |y|
        if @tiles[x + WIDTH * y] == '.'
          # choose background terrain
          image = @terrain[1]
          # actual top left coordinates
          px = x * 32 * size
          py = y * 25 * size
          # draw to the screen scaled to size
          image.draw(px, py, 0, size, size)
        end
      end
    end

    # draw platforms on top of the background
    0.upto(WIDTH - 1) do |x|
      (HEIGHT - 1).downto(0) do |y|
        if @tiles[x + WIDTH * y] == '-'
          # choose platform terrain
          image = @terrain[0]
          # actual top left coordinates
          px = x * 32 * size
          py = y * 25 * size - 25 * size
          # draw to the screen scaled to size
          image.draw(px, py, 0, size, size)
        end
      end
    end
  end
end
