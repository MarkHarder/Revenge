# Stephen Quenzer
# Mark Harder
# ----------
# The main game engine

require 'gosu'
require_relative 'level.rb'
require_relative 'player.rb'

class Game < Gosu::Window
  SCALE = 3
  WIDTH = 32 * 10 * SCALE
  HEIGHT = 25 * 10 * SCALE

  def initialize
    super WIDTH, HEIGHT, false
    self.caption = "Commander Keen in Revenge of the Shikadi!"

    @level = Level.new(self)
    @player = Player.new(self)
  end

  # update the logic of the game
  def update
    @player.update @level
  end

  # draw the components of the game
  def draw
    @level.draw SCALE
    @player.draw SCALE
  end

  # method called when a button is pressed
  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::KbQ
      close
    elsif id == Gosu::KbLeftAlt
      @player.toggle_pogo
    end
  end

  def run
    # show the window
    show
  end
end
