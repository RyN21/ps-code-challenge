class RennameMyTable < ActiveRecord::Migration[6.0]
  def self.up
    rename_table :cafes, :restaurants
  end

  def self.down
    rename_table :restaurants, :cafes
  end
end
