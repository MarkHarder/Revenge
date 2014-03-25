# Stephen Quenzer
# Mark Harder
# ----------
# The slug class, template for all slug enemies

require_relative 'enemy.rb'
require_relative 'slime.rb'

class Slug < Enemy
  attr_reader :images

  WIDTH = 16
  HEIGHT = 16
  SLIME_TIME = 200

  def initialize window, x, y
    @images = Gosu::Image::load_tiles(window, "media/SlugSprites.png", 23, 24, true)

    super(x, y, WIDTH, HEIGHT, @images)

    @window = window
    @direction = rand(2) == 0 ? :left : :right

    @action = :moving
    @action_start_milliseconds = 0
  end

  def update level
    if @action == :moving
      if rand(20 * 60) == 0
        @action = :sliming
        @action_start_milliseconds = Gosu.milliseconds
        level.enemies.push(Slime.new(@window, @x, @y + @height))
      end
    end

    if @action == :sliming
      if Gosu.milliseconds - @action_start_milliseconds >= SLIME_TIME
        @action = :moving
        @direction = rand(2) == 0 ? :left : :right
      end
    end

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
      if @action == :sliming
        image = @images[5]
      else
        image = @images[(Gosu::milliseconds / 360 % 2) + 3]
      end
    else
      if @action == :sliming
        image = @images[2]
      else
        image = @images[(Gosu::milliseconds / 360 % 2)]
      end
    end

    image.draw(px, py, 0, size, size)
  end
end
