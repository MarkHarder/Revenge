require 'gosu'
require_relative 'level.rb'
require_relative 'player.rb'

##
# The main game engine
class Game < Gosu::Window
  attr_reader :player, :level

  ##
  # How much to scale the window by
  SCALE = 3
  ##
  # Width of the window in pixels before scaling
  WIDTH = 32 * 10
  ##
  # Height of the window in pixels before scaling
  HEIGHT = 25 * 10
  ##
  # Light green color
  LIGHT_GREEN = 0xff00ff22
  ##
  # Dark green color
  DARK_GREEN = 0xff00660E
  ##
  # The number of the level in the game
  MAX_LEVEL = 2


  ##
  # Create the game, setting up the level and the player
  def initialize
    super(WIDTH * SCALE, HEIGHT * SCALE, false)
    self.caption = "Commander Keen in Revenge of the Shikadi!"

    @level = Level.new(self)

    File.readlines("levels/level0.lvl").each do |line|
      x, y = line.split(/\s/)
      @player = Player.new(self, x.to_i, y.to_i)
      break
    end

    @menu_options = [
      :Play,
      :Instructions,
      :"Save/Load",
      :Quit
    ]

    @menu_selection = 0

    @state = :menu
    @paused = false
  end

  ##
  # Update the logic of the game by updating the player
  # and each component of the level
  def update
    if @state == :game
      @player.update
      @level.update
    end
  end

  ##
  # draw the components of the game, the player and each element of the level
  def draw
   if @state == :menu
     i = 0
     for option in @menu_options
       color = option == @menu_options[@menu_selection] ? LIGHT_GREEN : DARK_GREEN
       Gosu::Image.from_text(self, option.to_s, "Courier New", 24 * SCALE).draw(100 * SCALE, 50 * i * SCALE + 30 * SCALE, 0, 1, 1, color)
       i += 1
     end
   elsif @state == :instructions
       Gosu::Image.from_text(self, "Use the arrow keys to move the player left and right.\nPress control to jump.\nAlt to toggle the pogo stick.\nSpace to shoot.\nUp in a doorway for next level.\n\nCollect candy.\nAvoid enemies.\nGame over if you run out of lives.", "Times New Roman", 12 * SCALE, 10 * SCALE, 250 * SCALE, :left).draw(50 * SCALE, 25 * SCALE, 0, 1, 1, 0xffffffff)
   elsif @state == :game
      @level.draw SCALE, @player.x * SCALE, @player.y * SCALE
      @player.draw SCALE
    end
  end

  ##
  # Callback for a button press
  # If ESC or Q is pressed, quit the game
  # If LEFT_ALT is pressed, toggle the pogo stick
  def button_down(id)
    if id == Gosu::KbQ
      close
    elsif id == Gosu::KbEscape
      if @state == :menu
        close
      elsif @state == :instructions
        @state = :menu
      else
        @state = :menu
        @paused = true
      end
    elsif id == Gosu::KbLeftAlt
      if @state == :game
        @player.toggle_pogo
      end
    elsif id == Gosu::KbLeftShift
      if @state == :game
        @player.sprint
      end
    elsif id == Gosu::KbSpace
      if @state == :game and
        !button_down? Gosu::KbDown
        @player.action != :dying and
        @player.action != :pullup and
        @player.action != :hang
        @player.shoot :sideways unless @player.bullets <= 0
      elsif @state == :game and
            button_down? Gosu::KbDown and
            (@player.action == :jumping or @player.action == :pogoing or @player.action == :falling)
        @player.shoot :down unless @player.bullets <= 0
      end
    elsif id == Gosu::KbDown || id == Gosu::GpDown
      if @state == :menu
        @menu_selection += 1
        @menu_selection %= @menu_options.size
      end
    elsif id == Gosu::KbUp || id == Gosu::GpUp
      if @state == :menu
        @menu_selection += @menu_options.size - 1
        @menu_selection %= @menu_options.size
      elsif @state == :game
        @player.leave
      end
    elsif id == Gosu::KbReturn
      if @state == :menu
        if @menu_options[@menu_selection] == :Play || @menu_options[@menu_selection] == :Resume
          @menu_options[@menu_selection] = :Resume
          @state = :game
          @paused = true
        elsif @menu_options[@menu_selection] == :Instructions
          @state = :instructions
        elsif @menu_options[@menu_selection] == :Quit
          close
        end
      end
    end
  end

  ##
  # load the next level
  def next_level
    if @level.level == MAX_LEVEL
      restart_game
    else
      @level.level += 1
      load_level("levels/level" + @level.level.to_s + ".lvl")
    end
  end

  ##
  # Restart the game from the beginning
  def restart_game
    @level = 0
    @level = Level.new(self)

    File.readlines("levels/level0.lvl").each do |line|
      x, y = line.split(/\s/)
      @player = Player.new(self, x.to_i, y.to_i)
      break
    end

    @menu_options = [
      :Play,
      :Instructions,
      :"Save/Load",
      :Quit
    ]

    @menu_selection = 0

    @state = :menu
    @paused = false
  end

  def load_level file_name
    File.readlines(file_name).each do |line|
      x, y = line.split(/\s/)
      @player.start_level x.to_i, y.to_i
      break
    end
    @level.load_level file_name
  end

  ##
  # Run the game
  def run
    show()
  end
end
