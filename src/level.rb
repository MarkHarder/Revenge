# Stephen Quenzer
# Mark Harder
# ----------
# A basic level template

#enemies
require_relative 'slug.rb'
require_relative 'spikes.rb'
#candies
require_relative 'soda.rb'

require_relative 'rectangle.rb'

class Level
  attr_reader :platforms, :enemies, :candies

  # number of tiles wide and high
  WIDTH = 10
  HEIGHT = 10

  TILE_WIDTH = 32
  TILE_HEIGHT = 25
  Y_OFFSET = 12

  def initialize window
    @terrain = Gosu::Image::load_tiles(window, "media/Terrain.png", TILE_WIDTH, TILE_HEIGHT * 2, true)
    @enemies = []
    @candies = []

    # a grid representing the tiles of the level
    # . = empty background
    # - = platform
    line_no = 0
    File.readlines("levels/first.lvl").each do |line|
      if line_no == 0
        # load the tiles (platforms, background, empty space)
        @tiles = line.split(/\s/)

        @tile_types = {
          "." => :background,
          "-" => :platform,
          "x" => :none,
        }

        # change from small single-character representations of tiles
        # to full name representations
        @tiles.collect! { |t| @tile_types[t] }
      else
        # load the enemies and candies
        x, y, type = line.split(/\s/)
        class_type = Object.const_get(type)
        class_name_plural = class_type.superclass.to_s.downcase
        class_name_plural[-1] = "ies"
        # grab the correct array
        array = instance_eval("@" + class_name_plural)
        # place a new object of type 'type' with the given parameters
        array.push(class_type.new(window, x.to_i, y.to_i))
      end
      line_no += 1
    end
    @platforms = []

    # add all the platform rectangles to check for collision
    0.upto(WIDTH - 1) do |x|
      0.upto(HEIGHT - 1) do |y|
        @platforms.push(Rectangle.new(x * TILE_WIDTH, y * TILE_HEIGHT - Y_OFFSET, TILE_WIDTH, TILE_HEIGHT + Y_OFFSET)) if @tiles[x + y * WIDTH] == :platform
      end
    end

    @window = window
  end

  def update
    for enemy in @enemies do
      enemy.update self
    end
  end

  # draw the level on the screen
  # draw the background and platforms
  def draw size, x_offset=0, y_offset=0
    x_offset -= 470
    y_offset -= 330
    # draw background first
    0.upto(WIDTH - 1) do |x|
      (HEIGHT - 1).downto(0) do |y|
        if @tiles[x + WIDTH * y] == :background
          # choose background terrain
          image = @terrain[1]
          # actual top left coordinates
          px = x * TILE_WIDTH * size
          py = y * TILE_HEIGHT * size - TILE_HEIGHT * size
          # draw to the screen scaled to size
          image.draw(px - x_offset, py - y_offset, 0, size, size)
        end
      end
    end

    # draw platforms on top of the background
    0.upto(WIDTH - 1) do |x|
      (HEIGHT - 1).downto(0) do |y|
        if @tiles[x + WIDTH * y] == :platform
          # choose platform terrain
          image = @terrain[0]
          # actual top left coordinates
          px = x * TILE_WIDTH * size
          py = y * TILE_HEIGHT * size - TILE_HEIGHT * size
          # draw to the screen scaled to size
          image.draw(px - x_offset, py - y_offset, 0, size, size)
        end
      end
    end

    for enemy in @enemies
      enemy.draw size, x_offset, y_offset
    end

    for candy in @candies
      candy.draw size, x_offset, y_offset
    end
  end

  def quit
    exit
  end

  # is the player below the screen?
  def below_screen? y
    y >= HEIGHT * TILE_HEIGHT
  end
end
