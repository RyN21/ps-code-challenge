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

end
