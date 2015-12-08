class Game < ActiveRecord::Base
  require 'chess'

  serialize :state
  serialize :stats

  def to_param
    Hashids.new("checkmate", 8).encode(id)
  end

end
