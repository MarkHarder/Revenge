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

  WIDTH = 10
  HEIGHT = 10

  def initialize window
    @terrain = Gosu::Image::load_tiles(window, "media/Terrain.png", 32, 50, true)
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
        @platforms.push(Rectangle.new(x * 32, y * 25 - 12, 32, 37)) if @tiles[x + y * WIDTH] == '-'
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
  def draw size
    # draw background first
    0.upto(WIDTH - 1) do |x|
      (HEIGHT - 1).downto(0) do |y|
        if @tiles[x + WIDTH * y] == '.'
          # choose background terrain
          image = @terrain[1]
          # actual top left coordinates
          px = x * 32 * size
          py = y * 25 * size - 25 * size
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

    for enemy in @enemies
      enemy.draw size
    end

    for candy in @candies
      candy.draw size
    end
  end

  def quit
    exit
  end

  def below_screen y
    y >= @window.height / 3
  end
end
