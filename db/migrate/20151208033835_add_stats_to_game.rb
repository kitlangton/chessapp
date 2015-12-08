class AddStatsToGame < ActiveRecord::Migration
  def change
    add_column :games, :stats, :text
  end
end
