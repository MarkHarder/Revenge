# Stephen Quenzer
# Mark Harder
# ----------
# The slug class, template for all slug enemies

require_relative 'enemy.rb'

class Slug < Enemy
  attr_reader :images

  WIDTH = 16
  HEIGHT = 16

  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/SlugSprites.png", 23, 24, true)

    super(x, y, WIDTH, HEIGHT, @images)

    @direction = rand(2) == 0 ? :left : :right
  end

  def update level
    # turn if a rectangle slightly lower and to the left of the slug
    # doesn't intersect any platforms
    # same but on the right for turning back when it is facing right
    if @direction == :left
      left_turn = Rectangle.new(@x - 1, @y + HEIGHT + 5, 5, 5)
      can_turn = true
      for p in level.platforms do
        if left_turn.intersect?(p)
          can_turn = false
        end
      end
      if can_turn
        @direction = :right
      else
        @x -= 0.3
      end
    else
      right_turn = Rectangle.new(@x + WIDTH + 1, @y + HEIGHT + 5, 5, 5)
      can_turn = true
      for p in level.platforms do
        if right_turn.intersect?(p)
          can_turn = false
        end
      end
      if can_turn
        @direction = :left
      else
        @x += 0.3
      end
    end
  end

  def draw size
    image = @images[0]

    px = @x * size
    py = @y * size

    if @direction == :left
      image = @images[(Gosu::milliseconds / 360 % 2) + 3]
    else
      image = @images[(Gosu::milliseconds / 360 % 2)]
    end

    image.draw(px, py, 0, size, size)
  end
end
