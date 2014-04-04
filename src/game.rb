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

    @state = :menu
    @paused = false
  end

  ##
  # Update the logic of the game by updating the player
  # and each component of the level
  def update
    if @state == :game
      @player.update @level
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
       Gosu::Image.from_text(self, option.to_s, "Times New Roman", 24 * SCALE).draw(100 * SCALE, 50 * i * SCALE + 30 * SCALE, 0, 1, 1, color)
       i += 1
     end
   elsif @state == :instructions
       Gosu::Image.from_text(self, "Use the arrow keys to move the player left and right.\nPress control to jump.\nAlt to toggle the pogo stick.\nSpace to shoot.\n\nCollect candy.\nAvoid enemies.\nGame over if you run out of lives.", "Times New Roman", 12 * SCALE, 10 * SCALE, 250 * SCALE, :left).draw(50 * SCALE, 25 * SCALE, 0, 1, 1, 0xffffffff)
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
        @player.sprint @level
      end
    elsif id == Gosu::KbSpace  
      if @state == :game
        @player.shoot
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
  # Run the game
  def run
    # show the window
    show
  end
end
