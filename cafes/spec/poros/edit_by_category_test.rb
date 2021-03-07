require 'rails_helper'

RSpec.describe EditByCategory, type: :model do
  before(:each) do
    Restaurant.destroy_all
    CSV.foreach("./Small Street Cafes 2020-21.csv", headers: true) do |row|
      Restaurant.create({
        name: row[0],
        street_address: row[1],
        post_code: row[2],
        num_of_chairs: row[3],
        })
    end
    Restaurant.categorize_restaurants
  end

  it 'can delete restaurants categorized as small' do
    small_restaurants = EditByCategory.new(Restaurant.where("category LIKE ?", "%small"))
    small_restaurants.export_data_to_csv

    csv = restaurants.to_csv
    new__small_restaurants = CSV.foreach(small_restaurants.export_data_to_csv, headers: true) do |row|
      Restaurant.create({
        name: row[0],
        street_address: row[1],
        post_code: row[2],
        num_of_chairs: row[3],
        category: row[4]
        })
    end
    expect(new__small_restaurants[0].category).to eq("ls1 medium")

    expect(Restaurant.where("category LIKE ?", "%small").count).to eq(3)

    delete_records(small_restaurants)
    expect(Restaurant.where("category LIKE ?", "%small").count).to eq(0)
  end

end




# it 'can edit names from csv and return edited csv' do
#   restaurants = EditByCategory.new(Restaurant.all)
#   binding.pry
#   # expect(restaurants[0].category).to eq("ls1 medium")
#   # expect(restaurants[1].category).to eq("ls2 large")
#   # expect(restaurants[4].category).to eq("ls1 small")
#   # expect(restaurants[17].category).to eq("ls2 small")
# end
