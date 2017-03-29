require_relative 'rectangle.rb'

class Blast < Rectangle
  attr_reader :kill, :state
  ##
  # The width of the blast in pixels
  WIDTH = 14
  ##
  # The height of the player in pixels
  HEIGHT = 16
  ##
  #The blast speed
  SPEED = 10
  ##
  #The scale of the window for correct positioning of blast
  SCALE = 3
  ##
  # Layer of blast in comparison to environment
  Z_LEVEL = 4
  ##
  # The animation time for an explosion
  EXPLOSION_TIME = 240
  
  ##
  # Create a new blast 
  def initialize(window, direction, x, y, offset)
    super(x, y, WIDTH, HEIGHT)
    @window = window
    @direction = direction
    @sprites = Gosu::Image::load_tiles(@window, 'media/blast.png', WIDTH, HEIGHT, true)
    
    if direction == :left
      @x = x-offset
    elsif direction == :right
      @x = x+offset
    elsif direction == :down
      @y = y-offset
    end
    @y = y+10
    
    ##Possible states:
    # :Initial - First couple frames of animation
    # :Moving - While blast is moving through the air
    # :Collision - When blast hits something
    # :Finished - After blast has finished exploding
    @state = :initial
    
    # Holds the class name of the element that was collided against
    @kill = false
    @start_milliseconds = 0
  end
  
  ##
  # Update the blast animation based on direction
  # whether it has collided with anything
  def update
    # Kill can only be true for one frame
    @kill = false if @kill

    # Check the state of the blast
    if @state == :initial
    elsif @state == :moving
      if @direction == :left
        @x -= SPEED
      elsif @direction == :right
        @x += SPEED
      elsif @direction == :down
        @y += SPEED
      end
      
      # check if blast has collided with anything
      # create a rectangle next to the blast
      # if it intersects with any of the platforms, collision
      can_move = true
      bx = @x
      by = @y
      bx += 10 if @direction == :left        
      offset_rect = Rectangle.new(bx/SCALE, by/SCALE, @width, @height)
      #check platforms for collision
      @window.level.platforms.each do |p|
        if offset_rect.intersect?(p)
          can_move = false 
          break
        end
      end
      #check enemies for collision
      @window.level.enemies.each do |e|
        if offset_rect.intersect?(e) && !e.dead?
          can_move = false
          #Recognize Enemy Types
          if !e.invincible?
            e.health -= 1
            @kill = true
          end
          break
        end
      end
      if !can_move
        @state = :collision
        @start_milliseconds = Gosu.milliseconds
      end
    elsif @state == :collision
      if Gosu.milliseconds - @start_milliseconds > EXPLOSION_TIME
        @state = :finished
      end
    end
  end

  def draw size, x_offset, y_offset
    # Offset blast to account for environment moving around player
    x_offset -= 470
    y_offset -= 330
    if @state == :initial
      @image = @sprites[0]
      @state = :moving
    elsif @state == :moving
        @image = @sprites[(Gosu::milliseconds / 60 % 4) + 1] if @direction == :right
        @image = @sprites[(Gosu::milliseconds / 60 % 4) + 9] if @direction == :left
        @image = @sprites[(Gosu::milliseconds / 60 % 4) + 17] if @direction == :down
    elsif @state == :collision
      @image = @sprites[(Gosu::milliseconds / 120 % 3) + 5] if @direction == :right
      @image = @sprites[(Gosu::milliseconds / 120 % 3) + 13] if @direction == :left
      @image = @sprites[(Gosu::milliseconds / 120 % 3) + 21] if @direction == :down
    else
      #state == :finished
      @image = @sprites[0] if @direction == :right
      @image = @sprites[8] if @direction == :left
    end
    @image.draw(@x-x_offset, @y-y_offset, Z_LEVEL, size, size)
  end
  
  def finished?
    @state == :finished
  end
end
