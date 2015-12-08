class Stats

  attr_accessor :new_red_dead, :new_blue_dead, :red_active, :blue_active

  def initialize(input = {})
    @new_red_dead = input.fetch(:new_red_dead, [])
    @new_blue_dead = input.fetch(:new_blue_dead, [])
    @red_active = input.fetch(:red_active, Time.now)
    @blue_active = input.fetch(:blue_active, Time.now)
  end


  def blue_active?
    @blue_active > 10.seconds.ago
  end

  def red_active?
    @red_active > 10.seconds.ago
  end

  def touch_blue
    @blue_active = Time.now
  end

  def touch_red
    @red_active = Time.now
  end
end
