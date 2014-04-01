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
  # Create the game, setting up the level and the player
  def initialize
    super WIDTH * SCALE, HEIGHT * SCALE, false
    self.caption = "Commander Keen in Revenge of the Shikadi!"

    @level = Level.new(self)
    @player = Player.new(self)
  end

  ##
  # Update the logic of the game by updating the player
  # and each component of the level
  def update
    @player.update @level
    @level.update
  end

  ##
  # draw the components of the game, the player and each element of the level
  def draw
    @level.draw SCALE, @player.x * SCALE, @player.y * SCALE
    @player.draw SCALE
  end

  ##
  # Callback for a button press
  # If ESC or Q is pressed, quit the game
  # If LEFT_ALT is pressed, toggle the pogo stick
  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::KbQ
      close
    elsif id == Gosu::KbLeftAlt
      @player.toggle_pogo
    elsif id == Gosu::KbSpace  
      @player.shoot
    end
  end

  ##
  # Run the game
  def run
    # show the window
    show
  end
end
