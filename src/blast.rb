# Stephen Quenzer
# Mark Harder
# ----------
# A class to store information about shooting

require_relative 'rectangle.rb'

class Blast < Rectangle
  WIDTH = 14
  HEIGHT = 16
  SPEED = 10
  EXPLOSION_TIME = 240
  
  def initialize(window, direction, x, y, offset)
    super(x, y, WIDTH, HEIGHT)
    @window = window
    @direction = direction
    
    @sprites = Gosu::Image::load_tiles(@window, 'media/blast.png', WIDTH, HEIGHT, true)
    
    if direction == :left
      @x = x-offset
    else
      @x = x+offset
    end
    @y = y
    
    #Possible states:
    ## :Initial - First couple frames of animation
    ## :Moving - While blast is moving through the air
    ## :Collision - When blast hits something
    ## :Finished - After blast has finished exploding
    @state = :initial
    @start_milliseconds = 0
  end
  
  def update level
    @x = 0 if @x <= 0
    @x = @window.width-30 if @x > @window.width-30
    # Check the state of the blast
    if @state == :initial
    elsif @state == :moving
      if @direction == :left
        @x -= SPEED
      else
        #@direction == :right
        @x += SPEED
      end
      # check if blast has collided with anything
      # create a rectangle just to the right of blast
      # if it intersects with any of the platforms, collision
      # Collisions with platforms still not working
      if @direction == :right
        can_right = true
        right_rect = Rectangle.new(@x + WIDTH, @y, WIDTH, HEIGHT)
        for p in level.platforms do
          can_right = false if right_rect.intersect?(p)
        end
        can_right = false if @x > @window.width-(WIDTH+SPEED)
        if !can_right
          @state = :collision
          @start_milliseconds = Gosu.milliseconds
        end
      end
      
      # check if blast has collided with anything
      # create a rectangle just to the left of blast
      # if it intersects with any of the platforms, collision
      if @direction == :left
        can_left = true
        left_rect = Rectangle.new(@x - WIDTH, @y, WIDTH, HEIGHT)
        for p in level.platforms do
          can_left = false if left_rect.intersect?(p)
        end
        can_left = false if @x <= 0
        if !can_left
          @state = :collision
          @start_milliseconds = Gosu.milliseconds
        end
      end
    elsif @state == :collision
      if Gosu.milliseconds - @start_milliseconds > EXPLOSION_TIME
        @state = :finished
      end
    else
      #@state == :finished
    end
  end

  def draw size
    if @state == :initial
      @image = @sprites[0]
      @state = :moving
    elsif @state == :moving
      # Does animating this way cycle through the sprites from a random starting place?
      @image = @sprites[(Gosu::milliseconds / 60 % 4) + 1]
    elsif @state == :collision
      @image = @sprites[(Gosu::milliseconds / 120 % 3 + 5)]
    else
      #state == :finished
      @image = @sprites[0]
    end
    @image.draw(@x, @y, 4, size, size)
  end
  
  def finished?
    true if @state == :finished
  end
end
