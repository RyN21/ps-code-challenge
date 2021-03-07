class EditByCategory
  attr_reader :restaurants

  def initialize(restaurants)
    @restaurants = restaurants
  end

  def export_data_to_csv(data)
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

  def delete_records(data)
    data.each do |r|
      r.delete
    end
  end

  def find_small
    @restaurants.where("category LIKE ?", "%small")
  end

  def edit_names
    @restaurants.where("category LIKE ?", "%medium").or(@restaurants.where("category LIKE ?", "%large")).each do |r|
      category_name = r.category
      name = r.name
      r.update(name: "#{category_name} #{name}")
    end
  end
end
