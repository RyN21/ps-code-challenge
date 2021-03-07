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
    # still need to get name of of place with max chairs
  end

  def self.aggregate_categories
    ActiveRecord::Base.connection.select_all('SELECT category,
    COUNT(id) AS total_places,
    SUM(num_of_chairs) AS total_chairs
    FROM restaurants
    GROUP BY category
    ORDER BY category;').to_a
  end

  # ============================================================================
  # CATEGORIZE RESTAURANTS
  # ============================================================================

  def self.categorize_restaurants
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

  # ============================================================================
  # EDIT NAME BASED ON CATEGORY
  # ============================================================================


end
