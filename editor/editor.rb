# Stephen Quenzer
# Mark Harder
# ----------
# A level editor

require 'gosu'

require_relative '../src/slug.rb'
require_relative '../src/spikes.rb'

class Editor < Gosu::Window
  SCALE = 3
  WIDTH = 32 * 10 * SCALE
  HEIGHT = 25 * 10 * SCALE
  LEVEL_HEIGHT = 10
  LEVEL_WIDTH = 10

  def initialize
    super WIDTH, HEIGHT, false
    self.caption = "Level Editor"
    @enemies = []
    @tiles = []

    0.upto(99) { @tiles.push(:none) }

    @terrain = Gosu::Image::load_tiles(self, "media/Terrain.png", 32, 50, true)

    @images = {
      :platform => @terrain[0],
      :background => @terrain[1],
      :none => @terrain[2],

      :slug => Slug.new(self, 0, 0).images[0],
      :spikes => Spikes.new(self, 0, 0).images[0],
    }

    @current_selection = :background
  end

  def needs_cursor?
    true
  end

  # update the logic of the game
  def update
    if button_down? Gosu::MsLeft
      if @current_selection == :platform || @current_selection == :background
        @tiles[(mouse_x / (32 * SCALE)).to_i + (mouse_y / (25 * SCALE)).to_i * LEVEL_WIDTH] = @current_selection
      end
    end
  end

  # draw the components of the game
  def draw
    # draw background first
    0.upto(LEVEL_WIDTH - 1) do |x|
      (LEVEL_HEIGHT - 1).downto(0) do |y|
        if @tiles[x + LEVEL_WIDTH * y] == :background
          # choose background terrain
          image = @terrain[1]
          # actual top left coordinates
          px = x * 32 * SCALE
          py = y * 25 * SCALE - 25 * SCALE
          # draw to the screen scaled to size
          image.draw(px, py, 0, SCALE, SCALE)
        elsif @tiles[x + LEVEL_WIDTH * y] == :none
          image = @terrain[2]
          # actual top left coordinates
          px = x * 32 * SCALE
          py = y * 25 * SCALE - 25 * SCALE
          # draw to the screen scaled to size
          image.draw(px, py, 0, SCALE, SCALE)
        end
      end
    end

    # draw platforms on top of the background
    0.upto(LEVEL_WIDTH - 1) do |x|
      (LEVEL_HEIGHT - 1).downto(0) do |y|
        if @tiles[x + LEVEL_WIDTH * y] == :platform
          # choose platform terrain
          image = @terrain[0]
          # actual top left coordinates
          px = x * 32 * SCALE
          py = y * 25 * SCALE - 25 * SCALE
          # draw to the screen scaled to size
          image.draw(px, py, 0, SCALE, SCALE)
        end
      end
    end

    for enemy in @enemies do
      enemy.draw SCALE
    end
  end

  # method called when a button is pressed
  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::KbQ
      save
      close
    elsif id == Gosu::Kb1
      @current_selection = :background
    elsif id == Gosu::Kb2
      @current_selection = :platform
    elsif id == Gosu::Kb3
      @current_selection = :slug
    elsif id == Gosu::Kb4
      @current_selection = :spikes
    elsif id == Gosu::MsLeft
      if @current_selection == :slug
        x = (mouse_x / SCALE).to_i
        x -= x % 32
        y = (mouse_y / SCALE).to_i
        y -= y % 25
        y -= 12
        @enemies.push(Slug.new(self, x, y))
      elsif @current_selection == :spikes
        x = (mouse_x / SCALE).to_i
        x -= x % 32
        x += 3
        y = (mouse_y / SCALE).to_i
        y -= y % 25
        y -= 12
        @enemies.push(Spikes.new(self, x, y))
      end
    end
  end

  def save
    File.open("levels/test.lvl", "w") do |file|
      x = 0
      y = 0
      str = ""
      until y == LEVEL_HEIGHT do
        case @tiles[x + LEVEL_WIDTH * y]
        when :none
          str += "x "
        when :background
          str += ". "
        when :platform
          str += "- "
        end

        x += 1
        if x % WIDTH == 0
          x = 0
          y += 1
        end
      end
      for enemy in @enemies do
        str += "\n#{enemy.x} #{enemy.y} #{enemy.class}"
      end
      file.write(str);
    end
  end

  def run
    # show the window
    show
  end
end

Editor.new.run
