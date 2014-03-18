# Stephen Quenzer
# Mark Harder
# ----------
# The main game engine

require 'gosu'

class Game < Gosu::Window
  WIDTH = 32 * 10
  HEIGHT = 25 * 10

  def initialize
    super WIDTH, HEIGHT, false
    self.caption = "Commander Keen in Revenge of the Shikadi!"
  end

  # update the logic of the game
  def update
  end

  # draw the components of the game
  def draw
  end

  # method called when a button is pressed
  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::KbQ
      close
    end
  end

  def run
    # show the window
    show
  end
end
