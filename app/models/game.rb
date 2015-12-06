class Game < ActiveRecord::Base
  require 'chess'

  serialize :state
end
