class Restaurant < ApplicationRecord

  validates_presence_of :name,
  :street_address,
  :post_code,
  :num_of_chairs

  # CREATE VIEW v_by_post_code AS
  def self.by_post_code
    ActiveRecord::Base.connection.select_all('CREATE VIEW v_names_pc AS
    SELECT name, post_code, num_of_chairs FROM restaurants ORDER BY post_code;')

    ActiveRecord::Base.connection.select_all('SELECT post_code,
    COUNT(id) AS total_places,
    SUM(num_of_chairs) AS total_chairs,
    ROUND((SUM(num_of_chairs)*100.00)/(SELECT SUM(num_of_chairs) FROM restaurants), 2) AS chairs_pct,
    (SELECT name FROM v_names_pc WHERE v_names_pc.post_code = restaurants.post_code ORDER BY num_of_chairs DESC LIMIT 1) AS place_with_max_chairs,
    MAX(num_of_chairs) AS max_chairs
    FROM restaurants
    GROUP BY post_code
    ORDER BY post_code;').to_a
  end

  def self.aggregate_categories
    ActiveRecord::Base.connection.select_all('
    CREATE VIEW v_aggregate_categories AS
    SELECT category,
    COUNT(id) AS total_places,
    SUM(num_of_chairs) AS total_chairs
    FROM restaurants
    GROUP BY category
    ORDER BY category;').to_a
    # SELECT category, COUNT(id) AS total_places, SUM(num_of_chairs) AS total_chairs FROM restaurants GROUP BY category ORDER BY category;
  end

  # ============================================================================
  # CATEGORIZE RESTAURANTS
  # ============================================================================

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
    r.num_of_chairs >= percentile ? r.update(category: 'ls2 large') : r.update(category: 'ls2 small')
  end

  def self.percentile
    ls2_chairs  = Restaurant.where("post_code LIKE 'LS2%'").pluck(:num_of_chairs).sort
    chair_count = ls2_chairs.count
    if chair_count.odd?
      index = chair_count / 2
      ls2_chairs[index]
    else
      index_1 = (chair_count / 2) - 1
      index_2 = index_1 + 1
      index_1 + index_2 / 2
    end
  end

  # ============================================================================
  # Export data to CSV  &  Delete records
  # ============================================================================

  def self.export_data_to_csv(data)
    headers = ["Café/Restaurant Name", "Street Address", "Post Code", "Number Of Chairs", "Category"]
    attributes = ["name", "street_address", "post_code", "num_of_chairs", "category"]

    CSV.generate(headers: true) do |csv|
      csv << headers

      data.each do |r|
        csv << attributes.map do |attr|
          r.send(attr)
        end
      end
    end
  end

  def self.delete_small
    where("category LIKE ?", "%small").each do |r|
      r.delete
    end
  end

  # ============================================================================
  # Edit Names
  # ============================================================================

  def self.edit_names
    where("category LIKE ?", "%medium").or(where("category LIKE ?", "%large")).each do |r|
      category_name = r.category
      name = r.name
      r.update(name: "#{category_name} #{name}")
    end
  end
end
