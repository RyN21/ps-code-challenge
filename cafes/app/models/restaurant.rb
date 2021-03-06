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
end
