class ChangeNumOfChairsToBeIntegerInRestaurants < ActiveRecord::Migration[6.0]
  def up
    change_column :restaurants, :num_of_chairs, 'integer USING CAST(num_of_chairs AS integer)'
  end

  def down
    change_column :restaurants, :num_of_chairs, :string
  end
end
