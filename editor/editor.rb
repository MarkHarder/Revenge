# Stephen Quenzer
# Mark Harder
# ----------
# A level editor

require 'gosu'

require_relative '../src/soda.rb'
require_relative '../src/gum.rb'
require_relative '../src/chocolate.rb'
require_relative '../src/slug.rb'
require_relative '../src/mushroom.rb'
require_relative '../src/spikes.rb'

class Editor < Gosu::Window
  SCALE = 3
  WIDTH = 32 * 10 * SCALE
  HEIGHT = 25 * 10 * SCALE
  LEVEL_HEIGHT = 20
  LEVEL_WIDTH = 20

  def initialize
    super WIDTH, HEIGHT, false
    self.caption = "Level Editor"
    @enemies = []
    @candies = []

    line_no = 0
    if File.exists?("levels/test.lvl")
      File.readlines("levels/test.lvl").each do |line|
        if line_no == 0
          @tiles = line.split(/\s/)
        else
          x, y, type = line.split(/\s/)
          class_type = Object.const_get(type)
          class_name_plural = class_type.superclass.to_s.downcase
          class_name_plural[-1] = "ies"
          array = instance_eval("@" + class_name_plural)
          array.push(class_type.new(self, x.to_i, y.to_i))
        end
        line_no += 1
      end
    else
      @tiles = []
      (LEVEL_WIDTH * LEVEL_HEIGHT).times { @tiles.push("x") }
    end

    @swap = {
      "x" => :none,
      "." => :background,
      "-" => :platform,
    }

    @tiles.collect! { |t| @swap[t] }

    @terrain = Gosu::Image::load_tiles(self, "media/Terrain.png", 32, 50, true)

    @images = {
      :platform => @terrain[0],
      :background => @terrain[1],
      :none => @terrain[2],

      :slug => Slug.new(self, 0, 0).images[0],
      :spikes => Spikes.new(self, 0, 0).images[0],
    }

    @current_type = :terrain
    @current_selection = :background
    @x_offset = 0
    @y_offset = 0
  end

  def needs_cursor?
    true
  end

  # update the logic of the game
  def update
    if button_down? Gosu::MsLeft
      if @current_selection == :platform || @current_selection == :background
        x = mouse_x / (32 * SCALE)
        x += @x_offset
        y = mouse_y / (25 * SCALE)
        y += @y_offset
        @tiles[x.to_i + y.to_i * LEVEL_WIDTH] = @current_selection
      end
    end
  end

  # draw the components of the game
  def draw
    # draw background first
    0.upto(LEVEL_WIDTH - 1) do |x|
      (LEVEL_HEIGHT - 1).downto(0) do |y|
        if @tiles[x + @x_offset + LEVEL_WIDTH * (y + @y_offset)] == :background
          # choose background terrain
          image = @terrain[1]
          # actual top left coordinates
          px = x * 32 * SCALE
          py = y * 25 * SCALE - 25 * SCALE
          # draw to the screen scaled to size
          image.draw(px, py, 0, SCALE, SCALE)
        elsif @tiles[x + @x_offset + LEVEL_WIDTH * (y + @y_offset)] == :none
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
        if @tiles[x + @x_offset + LEVEL_WIDTH * (y + @y_offset)] == :platform
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
      enemy.draw SCALE, @x_offset * 32 * SCALE, @y_offset * 25 * SCALE
    end

    for candy in @candies do
      candy.draw SCALE, @x_offset * 32 * SCALE, @y_offset * 25 * SCALE
    end

    Gosu::Image.from_text(self, @current_selection.to_s, "Times New Roman", 24).draw(5, 5, 0, 1, 1, 0xffffffff)
  end

  # method called when a button is pressed
  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::KbQ
      save
      close
    elsif id == Gosu::KbA
      @current_type = :terrain
    elsif id == Gosu::KbS
      @current_type = :enemies
    elsif id == Gosu::KbD
      @current_type = :candies
    elsif id == Gosu::KbLeft || id == Gosu::GpLeft
      @x_offset -= 1 if @x_offset > 0
    elsif id == Gosu::KbUp || id == Gosu::GpUp
      @y_offset -= 1 if @y_offset > 0
    elsif id == Gosu::KbRight || id == Gosu::GpRight
      @x_offset += 1 if @x_offset < LEVEL_WIDTH - 10
    elsif id == Gosu::KbDown || id == Gosu::GpDown
      @y_offset += 1 if @y_offset < LEVEL_HEIGHT - 10
    elsif id == Gosu::Kb1
      if @current_type == :terrain
        @current_selection = :background
      elsif @current_type == :enemies
        @current_selection = :slug
      elsif @current_type == :candies
        @current_selection = :soda
      end
    elsif id == Gosu::Kb2
      if @current_type == :terrain
        @current_selection = :platform
      elsif @current_type == :enemies
        @current_selection = :spikes
      elsif @current_type == :candies
        @current_selection = :gum
      end
    elsif id == Gosu::Kb3
      if @current_type == :enemies
        @current_selection = :mushroom
      elsif @current_type == :candies
        @current_selection = :chocolate
      end
    elsif id == Gosu::MsLeft
      if @current_selection == :slug
        x = (mouse_x / SCALE).to_i
        x -= x % 32
        x += 32 * @x_offset
        y = (mouse_y / SCALE).to_i
        y -= y % 25
        y -= 12
        y += 25 * @y_offset
        @enemies.push(Slug.new(self, x, y))
      elsif @current_selection == :spikes
        x = (mouse_x / SCALE).to_i
        x -= x % 32
        x += 3
        y = (mouse_y / SCALE).to_i
        y -= y % 25
        y -= 12
        x += 32 * @x_offset
        y += 25 * @y_offset
        @enemies.push(Spikes.new(self, x, y))
      elsif @current_selection == :mushroom
        x = (mouse_x / SCALE).to_i
        x -= x % 32
        y = (mouse_y / SCALE).to_i
        y -= y % 25
        y += 6
        x += 32 * @x_offset
        y += 25 * @y_offset
        @enemies.push(Mushroom.new(self, x, y))
      elsif @current_type == :candies
        x = (mouse_x / SCALE).to_i
        y = (mouse_y / SCALE).to_i
        x += 32 * @x_offset
        y += 25 * @y_offset
        @candies.push(Object.const_get(@current_selection.to_s.capitalize).new(self, x, y))
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

      for candy in @candies do
        str += "\n#{candy.x} #{candy.y} #{candy.class}"
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
