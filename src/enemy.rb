# Stephen Quenzer
# Mark Harder
# ----------
# Enemy

require_relative 'rectangle.rb'

class Enemy < Rectangle
  def initialize x, y, width, height, images
    super x, y, width, height
    @images = images
    @harmless = false
  end

  def update level
  end

  def draw size
    px = @x * size
    py = @y * size
    @images[0].draw(px, py, 0, size, size)
  end

  def harmless?
    @harmless
  end
end
