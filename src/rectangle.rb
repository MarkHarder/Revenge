# Stephen Quenzer
# Mark Harder
# ----------
# A simple rectangle class
# contains x and y coordinates, width, and height

class Rectangle
  attr_reader :x, :y, :width, :height

  def initialize x, y, width, height
    @x = x
    @y = y
    @width = width
    @height = height
  end

  # check if two rectangles are intersecting based on their postions
  # and sizes
  def intersect? rect
    rect.is_a?(Rectangle) && !(@x + @width < rect.x || rect.x + rect.width < @x || @y + @height < rect.y || rect.y + rect.height < @y)
  end
end
