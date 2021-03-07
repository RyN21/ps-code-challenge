require 'rails_helper'
require 'csv'

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

  it 'can create csv for small restaurants' do
    restaurants = EditByCategory.new(Restaurant.all)
    csv_small = restaurants.export_data_to_csv(restaurants.find_small)
    csv = CSV.parse(csv_small)

    # Check Headers
    expect(csv[0][0]).to eq("Café/Restaurant Name")
    expect(csv[0][1]).to eq("Street Address")
    expect(csv[0][2]).to eq("Post Code")
    expect(csv[0][3]).to eq("Number Of Chairs")
    expect(csv[0][4]).to eq("Category")

    # Check first row of csv file
    expect(csv[1][0]).to eq("Barburrito")
    expect(csv[1][1]).to eq("62 The Headrow")
    expect(csv[1][2]).to eq("LS1 8EQ")
    expect(csv[1][3]).to eq("8")
    expect(csv[1][4]).to eq("ls1 small")

    # Check the correct count (This include header row)
    expect(csv.count).to eq(4)
  end

  it 'can delete record of small restaurants' do
    restaurants = EditByCategory.new(Restaurant.all)
    small = restaurants.find_small
    expect(small.count).to eq(3)

    restaurants.delete_records(small)
    new_small = restaurants.find_small
    expect(new_small.count).to eq(0)
  end

  # it 'can edit names from csv and return edited csv' do
  #   restaurants = EditByCategory.new(Restaurant.all)
  #   binding.pry
  #   # expect(restaurants[0].category).to eq("ls1 medium")
  #   # expect(restaurants[1].category).to eq("ls2 large")
  #   # expect(restaurants[4].category).to eq("ls1 small")
  #   # expect(restaurants[17].category).to eq("ls2 small")
  # end
end