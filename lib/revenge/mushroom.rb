##
# An +enemy+, template for all mushroom enemies

class Mushroom < Enemy
  attr_writer :dead
  attr_reader :invincible
  attr_accessor :health
  ##
  # Musroom width
  WIDTH = 32
  ##
  # Mushroom height
  HEIGHT = 32
  ##
  # Gravitational acceleration
  ACCELERATION = 0.2
  ##
  # The force of the bounce
  BOUNCE_FORCE = -6
  ##
  # The force of the short bounce
  SHORT_BOUNCE_FORCE = -4
  ##
  # Time it takes to die
  DEATH_TIME = 400

  ##
  # Create a mushroom.
  def initialize window, x, y
    images = Gosu::Image::load_tiles(window, "media/Mushroom.png", 32, 32, true)

    super(window, x, y, WIDTH, HEIGHT, images)

    # direction the mushroom is facing
    @direction = :left
    @velocity = 0
    @dying = false
    @dead = false
    @health = 5
    
    @death_start_milliseconds = 0
    @bounce_cycle = 0
    
    @invincible = false
    @death_time = 0
    @score = 25
  end

  ##
  # Update the mushroom
  def update
    super()
    @direction = @window.player.x < @x ? :left : :right

    fall_rect = Rectangle.new(@x, @y + @velocity, @width, @height)
    for p in @window.level.platforms do
      if fall_rect.intersect?(p)
        if @velocity >= 0
          @bounce_cycle += 1
        end
        @bounce_cycle %= 3

        @y = p.y - HEIGHT
        if @bounce_cycle > 1
          @velocity = BOUNCE_FORCE
        else
          @velocity = SHORT_BOUNCE_FORCE
        end
      end
    end

    @y += @velocity
    @velocity += ACCELERATION
  end

  # choose the right image based on the mushroom's direction
  def draw size, x_offset, y_offset
    image = @images[0]

    px = @x * size
    py = @y * size

    if @direction == :left
      image = @images[0]
    # @direction == :right
    else
      image = @images[2]
    end

    image.draw(px - x_offset, py - y_offset, 0, size, size)
    drawHealth @health, size, px - x_offset, py - y_offset

  end
end
