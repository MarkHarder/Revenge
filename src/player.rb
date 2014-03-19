# Stephen Quenzer
# Mark Harder
# ----------
# A class to store information about the player

require_relative 'rectangle.rb'

class Player < Rectangle
  WIDTH = 32
  HEIGHT = 32

  def initialize window
    super(@x, @y, WIDTH, HEIGHT)

    @x = 20
    @y = 20
    @direction = :right

    @sprites = Gosu::Image::load_tiles(window, "media/PlayerSprites.png", WIDTH, HEIGHT, true)

    @window = window
  end

  def update level
    if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight
      @direction = :right

      # check if there is room to move right
      # create a rectangle just to the right of the player and check
      #   if it overlaps with any of the platforms
      can_right = true
      right_rect = Rectangle.new(@x + 1, @y, @width, @height)
      for p in level.platforms do
        can_right = false if right_rect.intersect?(p)
      end
      @x += 1 if can_right
    elsif @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft
      @direction = :left

      # check if there is room to move left
      # create a rectangle just to the left of the player and check
      #   if it overlaps with any of the platforms
      can_left = true
      left_rect = Rectangle.new(@x - 1, @y, @width, @height)
      for p in level.platforms do
        can_left = false if left_rect.intersect?(p)
      end
      @x -= 1 if can_left
    end
 
    # check if there is a platform beneath the player
    # if there is no platform below the player, they fall down
    can_fall = true
    fall_rect = Rectangle.new(@x, @y + 1, @width, @height)
    for p in level.platforms do
      can_fall = false if fall_rect.intersect?(p)
    end
    @y += 1 if can_fall
  end

  # draw the player on the screen
  def draw size
    # get the first image
    if @direction == :right
      if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight
        image = @sprites[(Gosu::milliseconds / 120 % 4) + 1]
      else
        image = @sprites[0]
      end
    else
      if @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft
        image = @sprites[(Gosu::milliseconds / 120 % 4) + 9]
      else
        image = @sprites[8]
      end
    end

    # upper left corner of player
    px = @x * size - 8 * size
    py = @y * size - 4 * size

    # draw the image scaled to size
    image.draw(px, py, 0, size, size)
  end
end
