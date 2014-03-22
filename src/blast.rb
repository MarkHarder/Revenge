# Stephen Quenzer
# Mark Harder
# ----------
# A class to store information about shooting

require_relative 'rectangle.rb'

class Blast < Rectangle
  WIDTH = 14
  HEIGHT = 16
  SPEED = 10
  
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
    ##Initial - First couple frames of animation
    ##Moving - While blast is moving through the air
    ##Collision - When blast hits something
    @state = :initial
    @start_milliseconds = 0
  end
  
  def update level
    if @state == :initial
    elsif @state == :moving
      if @direction == :left
        @x -= SPEED
      else
        #@direction == :right
        @x += SPEED
      end
    else
      #state == :collision
    end
  end
  
  def draw size
    if @state == :initial
      @image = @sprites[0]
      @state = :moving
    elsif @state == :moving
      @image = @sprites[(Gosu::milliseconds / 60 % 5) + 1]
    else
    end
    @image.draw(@x, @y, 4, size, size)
  end
end
