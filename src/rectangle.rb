# Stephen Quenzer
# Mark Harder
# ----------
# A simple rectangle class

class Rectangle
  attr_reader :x, :y, :width, :height

  def initialize x, y, width, height
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def intersect? rect
    !(@x + @width < rect.x || rect.x + rect.width < @x || @y + @height < rect.y || rect.y + rect.height < @y)
  end
end
