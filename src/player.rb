require_relative 'blast.rb'
require_relative 'rectangle.rb'

##
# A class to store information about the player

class Player < Rectangle
  attr_reader :x, :y, :score, :bullets, :kills

  ##
  # The width of the player in pixels
  WIDTH = 32
  ##
  # The height of the player in pixels
  HEIGHT = 32
  ##
  # The player speed
  SPEED = 2
  ##
  # The amount of velocity the player moves upwards during a jump
  JUMP_VELOCITY = -5
  ##
  # The amount of velocity the player moves upwards during a pogo bounce
  POGO_VELOCITY = -4
  ##
  # Higher pogo bounce velocity
  SUPER_POGO_VELOCITY = -8
  ##
  # The amount of time the bounce animation when the player hits the ground
  # on a pogo stick
  BOUNCE_TIME = 200
  ##
  # The force of gravity
  ACCELERATION = 0.2

  ##
  # The amount of velocity the player moves upwards when dying
  DEATH_VELOCITY = -6
  ##
  # The amount of time it takes to do a pullup
  PULLUP_TIME = 400
  ##
  # The amount of time you hang on a cliff before you can move
  HANG_TIME = 800
  ##
  # cooldown of the sprint feature
  SPRINT_COOLDOWN = 1600
  SHOOT_TIME = 300

  ##
  # Create a player
  def initialize window, x, y
    super(@x, @y, WIDTH - 20, HEIGHT - 4)

    @x = x
    @y = y
    @start_x = @x
    @start_y = @y
    @direction = :right
    @hang_direction = :none
    @score = 0
    @kills = 0
    @bullets = 100
    @lives = 3
    @next_new_life = 1000
    @velocity = 1

    @sprites = Gosu::Image::load_tiles(window, "media/PlayerSprites.png", WIDTH, HEIGHT, true)
    @pullup = Gosu::Image::load_tiles(window, "media/Pullup.png", 25, 80, true)
    @heart = Gosu::Image::load_tiles(window, "media/Life.png", 16, 16, true)

    @window = window
    @action = :falling
    @action_start_milliseconds = 0
    @bounce_start_milliseconds = 0
    @shoot_start_milliseconds = 0
    @sprint_time = 0
    #@shoot_anim: 0-9 == standing, 11-20 == jumping/falling/pogoing, other == peaceful
    #@shoot_anim only takes effect when in true mode
    @shoot_anim = 0
    @isViolent = false
  end

  ##
  # Update the player based on direction and action
  def update
    # die if you touch an enemy
    for enemy in @window.level.enemies do
      die if intersect?(enemy) && !enemy.harmless?
    end

    # collect a candy if you touch it
    # add the candy's score to the player's score
    for candy in @window.level.candies do
      if intersect?(candy)
        @score += candy.value
        @window.level.candies.delete(candy)
        if @score >= @next_new_life
          @lives += 1
          @next_new_life *= 2
        end
      end
    end

    #check if the player falls off the map
    die if @window.level.below_screen?(@y + @height)

    # dying animation
    # time == DEATHTIME :: player resets or quits
    # time <  DEATH_TIME / 6 :: player moves up
    # time >= DEATH_TIME / 6 :: player moves down
    if @action == :dying
      if @velocity > 10
        if @lives >= 0
          restart
        else
          @window.level.quit
        end
      end
      @y += @velocity
      @velocity += ACCELERATION

      # return to prevent other actions while dying
      return
    # player pulling themselves up from a cliff
    # TIME >= PULLUP_TIME * 4 :: move them to top of platform
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

    # ~shooting
    #if a blast kills an enemy, increase kill count
    if @isViolent == true
      @blast.each do |b|
        if b.kill
          @kills += 1
          #Change to recognize different values for different enemies
          @score += 25
        end
      end
    end
    
    if defined? @blast
      @blast.each do |b|
        b.update
        #Check if all blasts have finished
        if b.finished?
          @blast.delete(b)
        end
      end
      @blast.each do |b|
        @isViolent = false if b.state == :finished
      end
        
      if @blast.empty?
        @isViolent = false
      end
    end

    # jump when control is pressed
    # fall when control is released
    if @window.button_down? Gosu::KbLeftControl
      if @action == :none
        @action = :jumping
        @velocity = JUMP_VELOCITY
      end
    elsif @action == :jumping
      @action = :falling
    end

    # check to see if the player hits a ceiling while jumping
    # either while jumping or pogoing
    if @action == :jumping
      up_rect = Rectangle.new(@x, @y + @velocity, @width, @height)
      for p in @window.level.platforms do
        @action = :falling if up_rect.intersect?(p)
      end
      @velocity = 0 if @action == :falling
    elsif @action == :pogoing
      up_rect = Rectangle.new(@x, @y + @velocity, @width, @height)
      for p in @window.level.platforms do
        if up_rect.intersect?(p)
          @action = :pogo_falling 
        end
      end
      @velocity = ACCELERATION if @action == :pogo_falling
    elsif @action == :falling && @velocity < 0
      up_rect = Rectangle.new(@x, @y + @velocity, @width, @height)
      for p in @window.level.platforms do
        if up_rect.intersect?(p)
          @velocity = ACCELERATION
        end
      end
    end

    # move the player right and left when arrow keys are pressed
    if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight
      return if @action == :pullup # can't move if you are doing a pullup

      # check if there is room to move right
      # create a rectangle just to the right of the player and check
      #   if it overlaps with any of the platforms
      can_right = true
      can_right = false if @action == :pullup
      right_rect = Rectangle.new(@x + SPEED, @y, @width, @height)
      for p in @window.level.platforms do
        can_right = false if right_rect.intersect?(p)
      end
      @x += SPEED if can_right


      # check if you can grab onto a ledge
      if @action == :falling || @action == :jumping
        # check if you are near the edge of a lefge
        hang = false
        grab_rect = Rectangle.new(@x + @width, @y, 5, 5)
        for p in @window.level.platforms do
          ledge_rect = Rectangle.new(p.x - 2, p.y - 2, 5, 5)
          if ledge_rect.intersect?(grab_rect) && @velocity >= 0
            hang = true
            @y = p.y
          end
        end
        # start hanging if you can
        if hang
          @hang_direction = :right
          @action = :hang
          @action_start_milliseconds = Gosu.milliseconds
        end
      # if you are hanging from a ledge you can either
      # drop by moving away from the ledge
      # pull yourself up by moving towards the ledge
      elsif @action == :hang 
        if @hang_direction == :right && Gosu.milliseconds - @action_start_milliseconds >= HANG_TIME
          @action = :pullup
          @action_start_milliseconds = Gosu.milliseconds
        elsif @hang_direction == :left
          @action = :falling
        end
      end

      @direction = :right
    # same for the left direction
    elsif @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft
      return if @action == :pullup # can't move if you are doing a pullup

      # check if there is room to move left
      # create a rectangle just to the left of the player and check
      #   if it overlaps with any of the platforms
      can_left = true
      left_rect = Rectangle.new(@x - SPEED, @y, @width, @height)
      for p in @window.level.platforms do
        can_left = false if left_rect.intersect?(p)
      end
      @x -= SPEED if can_left

      # grab onto a ledge if it is there
      if @action == :falling || @action == :jumping
        hang = false
        grab_rect = Rectangle.new(@x - 5, @y, 5, 5)
        for p in @window.level.platforms do
          ledge_rect = Rectangle.new(p.x + p.width - 3, p.y - 2, 5, 5)
          if ledge_rect.intersect?(grab_rect) && @velocity >= 0
            hang = true
            @y = p.y
          end
        end
        if hang
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
    # if there is a platform and the player is pogoing, they bounce back up
    # if there is a platform and they are falling, stop them
    @action = :falling if @action == :none
    fall_rect = Rectangle.new(@x, @y + @velocity, @width, @height)
    for p in @window.level.platforms do
      if fall_rect.intersect?(p)
        if @action == :pogo_falling || @action == :pogoing
          if @window.button_down? Gosu::KbLeftControl
            @velocity = SUPER_POGO_VELOCITY
          else
            @velocity = POGO_VELOCITY
          end
          @action = :pogoing
          @bounce_start_milliseconds = Gosu.milliseconds
        elsif @velocity >= 0
          @action = :none 
          @y = p.y - HEIGHT
        end
      end
    end
    @y += @velocity unless @action == :none || @action == :hang || @action == :pullup
    @velocity += ACCELERATION
    @velocity = 4 if @velocity > 4
  end

  ##
  # Draw the player on the screen
  def draw size
    # upper left coordinates of player
    px = @window.width / (2 * size) - WIDTH / 2
    py = @window.height / (2 * size) - HEIGHT / 2
    px *= size
    py *= size

    # draw the text statistics in the upper left of the screen
    # score
    # ammo
    # kills
    Gosu::Image.from_text(@window, "Score: #{@score.to_s}", Gosu.default_font_name, 12 * size, 1, 200, :left).draw(5, 5, 0)
    Gosu::Image.from_text(@window, "Ammo: #{@bullets.to_s}", Gosu.default_font_name, 12 * size, 1, 200, :left).draw(5, 40, 0)
    Gosu::Image.from_text(@window, "Kills: #{@kills.to_s}", Gosu.default_font_name, 12 * size, 1, 200, :left).draw(5, 80, 0)

    # draw a heart for each life in the upper right of the screen
    @lives.times do |i|
      @heart[0].draw((@window.width / size - 20 * i - 20) * size, 2 * size, 0, size, size)
    end

    # dying animation
    if @action == :dying
      # draw the image scaled to size
      image = @sprites[(Gosu::milliseconds / 520 % 2) + 32]
      image.draw(px, py, 0, size, size)
      return
    end

    # split based on the direction the player is facing
    # from there choose the image based on the current action
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
        px += 25
        py -= 90
        image = @pullup[5]
      elsif @action == :pullup
        px += 45
        py -= 90
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
        py -= 90
        image = @pullup[0]
      elsif @action == :pullup
        px -= 0
        py -= 90
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

    # ~shooting
    # if player is shooting
    if (@isViolent == true and @direction == :right)
      case @shoot_anim
      when 0..9
        #On the ground
        image = @sprites[16]
        @shoot_anim += 1
      when 11..20
        #In the air
        image = @sprites[17]
        @shoot_anim += 1
      else
        @isViolent = false
      end
    elsif @isViolent == false
      @shoot_anim = 0
    end
    if (@isViolent == true and @direction == :left)
      case @shoot_anim
      when 0..9
        #On the ground
        image = @sprites[24]
        @shoot_anim += 1
      when 11..20
        #In the air
        image = @sprites[25]
        @shoot_anim += 1
      else
        @isViolent = false
      end
    elsif @isViolent == false
      @shoot_anim = 0
    end
    
    #if any bullets exist, draw them
    if defined?(@blast)
      @blast.each {|b| b.draw(size, @x*size, @y*size)}
    end

    # draw the image scaled to size
    image.draw(px, py, 0, size, size)
  end

  def shoot
    @shoot_anim = 11 if (@action == :falling or
                            @action == :jumping or
                            @action == :pogo_falling or
                            @action == :pogoing or
                            @action == :pogo_jumping)
      @action = :falling
    #Replace 3 with SCALE value
    @blast ||= []
    @blast.push(Blast.new(@window, @direction, @x*3, @y*3, WIDTH))
    @bullets -= 1
    @isViolent = true
    @shoot_start_milliseconds = Gosu.milliseconds
  end

  ##
  # Toggle the pogo stick
  # Change the player's action based on its current state
  def toggle_pogo
    # down with stick :: down without stick
    # up with stick :: up without stick
    if @action == :pogoing || @action == :pogo_falling
      @action = :falling
    elsif @action == :falling
      @action = :pogo_falling
    # (none, down, up) without stick :: down with stick
    elsif @action == :none
      @action = :pogoing
      @velocity = POGO_VELOCITY
      @bounce_start_milliseconds = Gosu.milliseconds
      @velocity -= 1 if @window.button_down? Gosu::KbLeftControl
    elsif @action != :dying
      @action = :pogoing
    end
  end

  ##
  # reset the game
  # place the player back in starting position
  # reset default values for variables
  def restart
    @x = @start_x
    @y = @start_y
    @direction = :right
    @hang_direction = :none
    @action = :falling
  end

  ##
  # if the player is not dying
  # set them to dying and remove a life
  def die
    if @action != :dying
      @lives -= 1
      @action = :dying
      @velocity = DEATH_VELOCITY
    end
  end

  ##
  # sprinting moves the player through enemies without dying
  def sprint
    return if @action == :hang || @action == :pullup
    return if Gosu.milliseconds - @sprint_time <= SPRINT_COOLDOWN

    @sprint_time = Gosu.milliseconds

    if @direction == :right
      i = 0
      while i < 80
        can_right = true
        right_rect = Rectangle.new(@x + 1, @y, @width, @height)
        for p in @window.level.platforms do
          can_right = false if right_rect.intersect?(p)
        end
        if can_right
          @x += 1
        else
          i = 80
        end
        i += 1
      end
    elsif @direction == :left
      i = 0
      while i < 80
        can_left = true
        left_rect = Rectangle.new(@x - 1, @y, @width, @height)
        for p in @window.level.platforms do
          can_left = false if left_rect.intersect?(p)
        end
        if can_left
          @x -= 1
        else
          i = 80
        end
        i += 1
      end
    end
  end
end

