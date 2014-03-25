# Stephen Quenzer
# Mark Harder
# ----------
# A class to store information about the player

require_relative 'blast.rb'
require_relative 'rectangle.rb'

class Player < Rectangle
  WIDTH = 32
  HEIGHT = 32
  JUMP_TIME = 800
  POGO_TIME = 1200
  BOUNCE_TIME = 200
  DEATH_TIME = 2400
  PULLUP_TIME = 400
  HANG_TIME = 1000

  def initialize window
    super(@x, @y, WIDTH - 20, HEIGHT - 4)

    @x = 20
    @y = 20
    @direction = :right
    @hang_direction = :none

    @sprites = Gosu::Image::load_tiles(window, "media/PlayerSprites.png", WIDTH, HEIGHT, true)
    @pullup = Gosu::Image::load_tiles(window, "media/Pullup.png", 25, 80, true)

    @window = window
    @action = :falling
    @action_start_milliseconds = 0
    @bounce_start_milliseconds = 0
    #@shoot_state: 0=nothing, >1=first shoot frame, >10=second shoot frame, >10=nothing
    @shoot_state = 0
    @shoot_toggle = :peaceful
  end

  def update level
    # die if you touch an enemy
    for enemy in level.enemies do
      die if intersect?(enemy) && !enemy.harmless? && @action != :dying
    end

    #check if the player falls off the map
    die if level.below_screen(@y + @height) && @action != :dying

    if @action == :dying
      elapsed_time = Gosu.milliseconds - @action_start_milliseconds
      level.quit if elapsed_time >= DEATH_TIME
      @y -= 1 if elapsed_time < DEATH_TIME / 6
      @y += 1 if elapsed_time >= DEATH_TIME / 6
      return
    elsif @action == :pullup
      if Gosu.milliseconds - @action_start_milliseconds >= PULLUP_TIME * 4
        @action = :none
        if @direction == :left
          @x -= (@width + 5)
          @y -= (@height + 1)
        else
          @x += (@width + 5)
          @y -= (@height + 1)
        end
      end
    end

    # If 's' is pressed, shoot
    if @window.button_down? Gosu::KbS and @shoot_toggle == :peaceful
      puts "IN"
      @shoot_state = 1
      shoot()
      @shoot_toggle = :violent
    end
    if @shoot_toggle == :violent
      @blast.update level
      @shoot_toggle = :peaceful if @blast.finished?
    end
    
    if @window.button_down? Gosu::KbLeftControl
      if @action == :none
        @action = :jumping
        @action_start_milliseconds = Gosu.milliseconds
      end
    elsif @action == :jumping
      @action = :falling
    end

    # check to see if the player hits a ceiling while jumping
    if @action == :jumping
      up_rect = Rectangle.new(@x, @y - 1, @width, @height)
      for p in level.platforms do
        @action = :falling if up_rect.intersect?(p)
      end
      @action = :falling if Gosu.milliseconds - @action_start_milliseconds >= JUMP_TIME
      @y -= 1 if @action == :jumping
    elsif @action == :pogoing
      up_rect = Rectangle.new(@x, @y - 1, @width, @height)
      for p in level.platforms do
        @action = :pogo_falling if up_rect.intersect?(p)
      end
      @action = :pogo_falling if Gosu.milliseconds - @action_start_milliseconds >= POGO_TIME
      @y -= 1 unless @action == :pogo_falling
    elsif @action == :pogo_jumping
      up_rect = Rectangle.new(@x, @y - 1, @width, @height)
      for p in level.platforms do
        @action = :falling if up_rect.intersect?(p)
      end
      @action = :falling if Gosu.milliseconds - @action_start_milliseconds >= POGO_TIME
      @y -= 1 unless @action == :falling
    end

    if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight
      # check if there is room to move right
      # create a rectangle just to the right of the player and check
      #   if it overlaps with any of the platforms
      can_right = true
      right_rect = Rectangle.new(@x + 1, @y, @width, @height)
      for p in level.platforms do
        can_right = false if right_rect.intersect?(p)
      end
      @x += 1 if can_right


      if @action == :falling || @action == :jumping
        # grab onto a ledge if it is there
        pullup = false
        grab_rect = Rectangle.new(@x + @width, @y, 5, 5)
        for p in level.platforms do
          ledge_rect = Rectangle.new(p.x - 2, p.y - 2, 5, 5)
          if ledge_rect.intersect?(grab_rect)
            pullup = true
            @y = p.y
          end
        end
        if pullup
          @hang_direction = :right
          @action = :hang
          @action_start_milliseconds = Gosu.milliseconds
        end
      elsif @action == :hang 
        if @hang_direction == :right && Gosu.milliseconds - @action_start_milliseconds >= HANG_TIME
          @action = :pullup
          @action_start_milliseconds = Gosu.milliseconds
        elsif @hang_direction == :left
          @action = :falling
        end
      end

      @direction = :right
    elsif @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft
      # check if there is room to move left
      # create a rectangle just to the left of the player and check
      #   if it overlaps with any of the platforms
      can_left = true
      left_rect = Rectangle.new(@x - 1, @y, @width, @height)
      for p in level.platforms do
        can_left = false if left_rect.intersect?(p)
      end
      @x -= 1 if can_left

      # grab onto a ledge if it is there
      if @action == :falling || @action == :jumping
        pullup = false
        grab_rect = Rectangle.new(@x - 5, @y, 5, 5)
        for p in level.platforms do
          ledge_rect = Rectangle.new(p.x + p.width - 3, p.y - 2, 5, 5)
          if ledge_rect.intersect?(grab_rect)
            pullup = true
            @y = p.y
          end
        end
        if pullup
          @hang_direction = :left
          @action = :hang
          @action_start_milliseconds = Gosu.milliseconds
        end
      elsif @action == :hang
        if @hang_direction == :left && Gosu.milliseconds - @action_start_milliseconds >= HANG_TIME
          @action = :pullup
          @action_start_milliseconds = Gosu.milliseconds
        elsif @hang_direction == :right
          @action = :falling
        end
      end

      @direction = :left
    end
 
    # check if there is a platform beneath the player
    # if there is no platform below the player, they fall down
    @action = :falling if @action == :none
    fall_rect = Rectangle.new(@x, @y + 1, @width, @height)
    for p in level.platforms do
      if fall_rect.intersect?(p)
        if @action == :falling
          @action = :none 
        elsif @action == :pogo_falling
          @action = :pogoing 
          @bounce_start_milliseconds = Gosu.milliseconds
          @action_start_milliseconds = Gosu.milliseconds
          @action_start_milliseconds += 400 if @window.button_down? Gosu::KbLeftControl
        end
      end
    end
    @y += 1 if @action == :falling || @action == :pogo_falling
  end

  # draw the player on the screen
  def draw size
    # upper left corner of player
    px = @x * size - 8 * size - 8
    py = @y * size - 4 * size

    if @action == :dying
      # draw the image scaled to size
      image = @sprites[(Gosu::milliseconds / 520 % 2) + 32]
      image.draw(px, py, 0, size, size)
      return
    end

    # get the first image
    if @direction == :right
      if @action == :jumping || @action == :falling || @action == :pogo_jumping
        image = @sprites[(Gosu::milliseconds / 520 % 2) + 5]
      elsif @action == :pogoing || @action == :pogo_falling
        if Gosu::milliseconds - @bounce_start_milliseconds >= BOUNCE_TIME
          image = @sprites[18]
        else
          image = @sprites[19]
        end
      elsif (@window.button_down?(Gosu::KbRight) || @window.button_down?(Gosu::GpRight)) && @action == :none
        image = @sprites[(Gosu::milliseconds / 120 % 4) + 1]
      elsif @action == :none
        image = @sprites[0]
      elsif @action == :hang
        px += 20
        py -= 60
        image = @pullup[5]
      elsif @action == :pullup
        px += 30
        py -= 80
        if Gosu.milliseconds - @action_start_milliseconds >= PULLUP_TIME * 3
          image = @pullup[9]
        elsif Gosu.milliseconds - @action_start_milliseconds >= PULLUP_TIME * 2
          image = @pullup[8]
        elsif Gosu.milliseconds - @action_start_milliseconds >= PULLUP_TIME * 1
          image = @pullup[7]
        else
          image = @pullup[6]
        end
      end
    else
      if @action == :jumping || @action == :falling || @action == :pogo_jumping
        image = @sprites[(Gosu::milliseconds / 520 % 2) + 14]
      elsif @action == :pogoing || @action == :pogo_falling
        if Gosu::milliseconds - @bounce_start_milliseconds >= BOUNCE_TIME
          image = @sprites[26]
        else
          image = @sprites[27]
        end
      elsif (@window.button_down?(Gosu::KbLeft) || @window.button_down?(Gosu::GpLeft)) && @action == :none
        image = @sprites[(Gosu::milliseconds / 120 % 4) + 9]
      elsif @action == :none
        image = @sprites[8]
      elsif @action == :hang
        px += 10
        py -= 60
        image = @pullup[0]
      elsif @action == :pullup
        px -= 20
        py -= 80
        if Gosu.milliseconds - @action_start_milliseconds >= PULLUP_TIME * 3
          image = @pullup[4]
        elsif Gosu.milliseconds - @action_start_milliseconds >= PULLUP_TIME * 2
          image = @pullup[3]
        elsif Gosu.milliseconds - @action_start_milliseconds >= PULLUP_TIME * 1
          image = @pullup[2]
        else
          image = @pullup[1]
        end
      end
    end
    
    #If player is shooting
    if (@shoot_toggle == :violent and @direction == :right)
      if @shoot_state == 0
        image = @sprites[16]
        @shoot_state += 1
      elsif (@shoot_state > 0 and @shoot_state < 10)
        image = @sprites[16]
        @shoot_state += 1
      elsif (@shoot_state >= 10 and @shoot_state < 20)
        image = @sprites[17]
        @shoot_state += 1
      elsif @shoot_state >= 20
      end
      @blast.draw(size)
    elsif @shoot_toggle == :peaceful
      @shoot_state = 0
    end
    if (@shoot_toggle == :violent and @direction == :left)
      if @shoot_state == 0
        image = @sprites[24]
        @shoot_state += 1
      elsif (@shoot_state > 0 and @shoot_state < 10)
        image = @sprites[24]
        @shoot_state += 1
      elsif (@shoot_state >= 10 and @shoot_state < 20)
        image = @sprites[25]
        @shoot_state += 1
      elsif @shoot_state >= 20
      end
      @blast.draw(size)
    elsif @shoot_toggle == :peaceful
      @shoot_state = 0
    end

    # draw the image scaled to size
    image.draw(px, py, 0, size, size)
  end
  
  def shoot
    #Replace 3 with SCALE value
    @blast = Blast.new(@window, @direction, @x*3, @y*3, WIDTH)
  end

  def toggle_pogo
    if @action == :pogo_falling
      @action = :falling
    elsif @action == :pogoing
      @action = :pogo_jumping
    elsif @action == :pogo_jumping
      @action = :pogoing
    elsif @action == :none || @action == :falling || @action == :jumping
      if @action == :none
        @bounce_start_milliseconds = Gosu.milliseconds
        @action_start_milliseconds = Gosu.milliseconds
        @action_start_milliseconds += 400 if @window.button_down? Gosu::KbLeftControl
      else
        @action_start_milliseconds = -POGO_TIME
      end
      @action = :pogoing
    end
  end

  def die
    @action = :dying
    @action_start_milliseconds = Gosu.milliseconds
  end
end
