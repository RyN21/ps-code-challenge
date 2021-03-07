class Restaurant < ApplicationRecord

  validates_presence_of :name,
  :street_address,
  :post_code,
  :num_of_chairs

  def self.by_post_code
    ActiveRecord::Base.connection.select_all('SELECT post_code,
    COUNT(id) AS total_places,
    SUM(num_of_chairs) AS total_chairs,
    ROUND((SUM(num_of_chairs)*100.00)/(SELECT SUM(num_of_chairs) FROM restaurants), 2) AS chairs_pct,
    MAX(num_of_chairs) AS max_chairs
    FROM restaurants
    GROUP BY post_code
    ORDER BY post_code;').to_a
    # SELECT post_code, COUNT(id) AS total_places, SUM(num_of_chairs) AS total_chairs, ROUND((SUM(num_of_chairs)*100.00)/(SELECT SUM(num_of_chairs) FROM restaurants), 2) AS chairs_pct, MAX(num_of_chairs) AS max_chairs FROM restaurants GROUP BY post_code ORDER BY post_code;
  end

  def self.categorize_cafes
    Restaurant.all.each do |restaurant|
      if restaurant.post_code.include?('LS1') && restaurant.num_of_chairs < 10
        restaurant.update(category: 'ls1 small')
        restaurant.save
      elsif restaurant.post_code.include?('LS1') && restaurant.num_of_chairs > 10 && restaurant.num_of_chairs < 100
        restaurant.update(category: 'ls1 medium')
        restaurant.save
      elsif restaurant.post_code.include?('LS1') && restaurant.num_of_chairs > 100
        restaurant.update(category: 'ls1 large')
        restaurant.save
      else
        restaurant.update(category: 'other')
        restaurant.save
      end
    end
  end

  def self.categorize
    Restaurant.all.each do |r|
      if r.post_code.include?('LS1')
        categorize_ls1(r)
      elsif r.post_code.include?('LS2')
        categorize_ls2(r)
      else
        r.category = 'other'
      end
    end
  end

  def self.categorize_ls1(r)
    chairs = r.num_of_chairs
    if chairs < 10
      r.update(category: 'ls1 small')
      # r.category = 'ls1 small'
    elsif chairs > 10 && chairs < 100
      r.update(category: 'ls1 medium')
      # r.category = 'ls1 medium'
    else
      r.update(category: 'ls1 large')
      # r.category = 'ls1 large'
    end
  end

  def self.categorize_ls2(r)
    percentile = find_percentile
    r.num_of_chairs >= percentile ? r.update(category: 'ls2 large') : r.update(category: 'ls2 small')
  end

  def self.find_percentile
    ls2_chairs  = Restaurant.where("post_code LIKE 'LS2%'").pluck(:num_of_chairs).sort
    chair_count = ls2_chairs.count
    if chair_count.odd?
      index = chair_count / 2
      ls2_chairs[index]
    else
      index_1 = (chair_count / 2) - 1
      index_2 = index_1 + 1
      averave = index_1 + index_2 / 2
      average
    end
  end
end



# def self.categorize_cafes
#   ActiveRecord::Base.connection.select_all("SELECT *,
#     CASE
#     WHEN post_code LIKE LS1 AND num_of_chairs < 10 THEN INSERT INTO Restaurants (category) VALUES ('ls1 small')
#     ELSE INSERT INTO restaurants (category) VALUES ('other')
#     END
#     FROM restaurants
#     ")
#
#     # ActiveRecord::Base.connection.select_all("UPDATE restaurants
#     #   SET category = 'small'
#     #   WHERE num_of_chairs < 10;")
#     #   Restaurant.all
#
#     # ActiveRecord::Base.connection.select_all("SELECT * FROM restaurants
#     #   IF (CHARINDEX 'LS1', post_code > 0 AND num_of_chairs < 10)
#     #     INSERT INTO Restaurants (category) VALUES ('ls1 small')
#     #   IF post_code ANY 'LS1' AND num_of_chairs > 10 AND num_of_chairs < 100
#     #     INSERT INTO Restaurants (category) VALUES ('ls1 medium')
#     #   IF post_code ANY 'LS1' AND num_of_chairs > 100
#     #     INSERT INTO Restaurants (category) VALUES ('ls1 large')
#     #   ELSE
#     #     INSERT INTO Restaurants (category) VALUES ('other')
#     #   END
#     #   ")
#   end
# # IF post_code LIKE LS12 AND num_of_chairs < 10
# # INSERT INTO Restaurants (category) VALUES ("ls1 small")
# # IF post_code LIKE LS12 AND num_of_chairs < 10
# # INSERT INTO Restaurants (category) VALUES ("ls1 large")
