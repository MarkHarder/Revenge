require 'gosu'
require_relative 'level.rb'
require_relative 'player.rb'

##
# The main game engine

class Game < Gosu::Window
  ##
  # How much to scale the window by
  SCALE = 3
  ##
  # Width of the window in pixels before scaling
  WIDTH = 32 * 10
  ##
  # Width of the window in pixels before scaling
  HEIGHT = 25 * 10
  ##
  # Light green color
  LIGHT_GREEN = 0xff00ff22
  ##
  # Dark green color
  DARK_GREEN = 0xff00660E
  ##
  # Create the game, setting up the level and the player
  def initialize
    super WIDTH * SCALE, HEIGHT * SCALE, false
    self.caption = "Commander Keen in Revenge of the Shikadi!"

    @level = Level.new(self)
    @player = Player.new(self)

    @menu_options = [
      :Play,
      :Instructions,
      :"Save/Load",
      :Quit
    ]

    @menu_selection = 0

    @in_menu = true
    @paused = false
  end

  ##
  # Update the logic of the game by updating the player
  # and each component of the level
  def update
    unless @in_menu
      @player.update @level
      @level.update
    end
  end

  ##
  # draw the components of the game, the player and each element of the level
  def draw
   if @in_menu
     i = 0
     for option in @menu_options
       color = option == @menu_options[@menu_selection] ? LIGHT_GREEN : DARK_GREEN
       Gosu::Image.from_text(self, option.to_s, "Times New Roman", 24 * SCALE).draw(100 * SCALE, 50 * i * SCALE + 30 * SCALE, 0, 1, 1, color)
       i += 1
     end
   else
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
      @in_menu = true
      @paused = true
    elsif id == Gosu::KbLeftAlt
      @player.toggle_pogo
    elsif id == Gosu::KbSpace  
      @player.shoot
    elsif id == Gosu::KbDown || id == Gosu::GpDown
      @menu_selection += 1
      @menu_selection %= @menu_options.size
    elsif id == Gosu::KbUp || id == Gosu::GpUp
      @menu_selection += @menu_options.size - 1
      @menu_selection %= @menu_options.size
    elsif id == Gosu::KbReturn
      if @in_menu
        if @menu_options[@menu_selection] == :Play
          @in_menu = false
          @paused = true
        elsif @menu_options[@menu_selection] == :Quit
          close
        end
      end
    end
  end

  ##
  # Run the game
  def run
    # show the window
    show
  end
end
