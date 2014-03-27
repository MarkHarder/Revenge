# Stephen Quenzer
# Mark Harder
# ----------
# A class to store information about shooting

require_relative 'rectangle.rb'

class Blast < Rectangle
  WIDTH = 14
  HEIGHT = 16
  SPEED = 10
  SCALE = 3
  EXPLOSION_TIME = 240
  attr_reader :kill
  
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
    
    @collisionWith = :none
    @kill = false
    
    #Possible states:
    ## :Initial - First couple frames of animation
    ## :Moving - While blast is moving through the air
    ## :Collision - When blast hits something
    ## :Finished - After blast has finished exploding
    @state = :initial
    @start_milliseconds = 0
  end
  
  def collisionWith
    @collisionWith
  end
  
  def update level
    @x = 0 if @x <= 0
    @x = @window.width-30 if @x > @window.width-30
    # Kill can only be true for one frame
    @kill = false if @kill
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
        right_rect = Rectangle.new(@x/SCALE, @y/SCALE, @width, @height)
        #check platforms for collision
        level.platforms.each {|p| can_right = false if right_rect.intersect?(p)}
        #check enemies for collision
        level.enemies.each do |e|
          if right_rect.intersect?(e)
            can_right = false
            #Recognize Enemy Types
            if e.class == Slug
              level.enemies.delete(e)
              @kill = true
            end
          end
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
        left_rect = Rectangle.new(@x/SCALE, @y/SCALE, @width, @height)
        #check platforms for collision
        level.platforms.each {|p| can_left = false if left_rect.intersect?(p)}
        #check enemies for collision
        level.enemies.each do |e|
          if left_rect.intersect?(e)
            can_left = false
            #Recognize Enemy Types
            if e.class == Slug
              level.enemies.delete(e) 
              @kill = true
            end
          end
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
        @image = @sprites[(Gosu::milliseconds / 60 % 4) + 1] if @direction == :right
        @image = @sprites[(Gosu::milliseconds / 60 % 4) + 9] if @direction == :left
    elsif @state == :collision
      @image = @sprites[(Gosu::milliseconds / 120 % 3 + 5)] if @direction == :right
      @image = @sprites[(Gosu::milliseconds / 120 % 3 + 13)] if @direction == :left
    else
      #state == :finished
      @image = @sprites[0] if @direction == :right
      @image = @sprites[8] if @direction == :left
    end
    @image.draw(@x, @y, 4, size, size)
  end
  
  def finished?
    @state == :finished
  end
end
