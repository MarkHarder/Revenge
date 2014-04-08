require_relative 'enemy.rb'
require_relative 'slime.rb'

##
# An +enemy+, template for all slug enemies

class Slug < Enemy
  ##
  # Slug width
  WIDTH = 16
  ##
  # Slug height
  HEIGHT = 16
  ##
  # Time it takes to put down a slime
  SLIME_TIME = 200
  ##
  # The movement speed of the slug
  SPEED = 0.3

  ##
  # Create a slug.
  #
  # Randomly choose to face left or right.
  def initialize window, x, y
    images = Gosu::Image::load_tiles(window, "media/SlugSprites.png", 23, 24, true)

    super(window, x, y, WIDTH, HEIGHT, images)

    # direction the slug is facing
    @direction = rand(2) == 0 ? :left : :right

    # the current action of the slug
    # :moving if it is moving left or right
    # :sliming if it is dropping slime
    @action = :moving
    @action_start_milliseconds = 0
  end

  ##
  # Update the slug. Either move it or start place slime
  def update
    if @action == :moving
      # random chance it will start droping slime
      if rand(20 * 60) == 0
        @action = :sliming
        @action_start_milliseconds = Gosu.milliseconds
        # add the slime
        @window.level.enemies.push(Slime.new(@window, @x, @y + @height))
      end
    end

    if @action == :sliming
      # wait before resuming moving
      if Gosu.milliseconds - @action_start_milliseconds >= SLIME_TIME
        @action = :moving
        @direction = rand(2) == 0 ? :left : :right
      end
    end

    # turn if a rectangle slightly lower and to the left of the slug
    # doesn't intersect any platforms
    # also check if there is a platform right in front of it
    # same but on the right for turning back when it is facing right
    if @direction == :left
      left_turn = Rectangle.new(@x - 1, @y + HEIGHT + 5, 5, 5)
      platform_turn = Rectangle.new(@x - 2, @y, 5, 5)
      can_turn = true
      for p in @window.level.platforms do
        if left_turn.intersect?(p)
          can_turn = false
        end
        if platform_turn.intersect?(p)
          can_turn = true
          break
        end
      end
      if can_turn
        @direction = :right
      else
        @x -= SPEED
      end
    else
      right_turn = Rectangle.new(@x + WIDTH + 1, @y + HEIGHT + 5, 5, 5)
      platform_turn = Rectangle.new(@x + WIDTH + 2, @y, 5, 5)
      can_turn = true
      for p in @window.level.platforms do
        if right_turn.intersect?(p)
          can_turn = false
        end
        if platform_turn.intersect?(p)
          can_turn = true
          break
        end
      end
      if can_turn
        @direction = :left
      else
        @x += SPEED
      end
    end
  end

  # choose the right image based on the slug's action and direction
  def draw size, x_offset, y_offset
    image = @images[0]

    px = @x * size
    py = @y * size

    if @direction == :left
      if @action == :sliming
        image = @images[5]
      else
        image = @images[(Gosu::milliseconds / 360 % 2) + 3]
      end
    # @direction == :right
    else
      if @action == :sliming
        image = @images[2]
      else
        image = @images[(Gosu::milliseconds / 360 % 2)]
      end
    end

    image.draw(px - x_offset, py - y_offset, 0, size, size)
  end
end
