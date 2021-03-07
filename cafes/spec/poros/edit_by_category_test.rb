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
    Restaurant.categorize
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
    expect(csv.count).to eq(5)
  end

  it 'can delete record of small restaurants' do
    restaurants = EditByCategory.new(Restaurant.all)
    small = restaurants.find_small
    expect(small.count).to eq(4)

    restaurants.delete_records(small)
    new_small = restaurants.find_small
    expect(new_small.count).to eq(0)
  end

  it 'can edit names based on category' do
    data = EditByCategory.new(Restaurant.all)
    new_names = data.edit_names
    # Changes name for restaurants with category as medium or large
    expect(new_names[0].name).to eq("ls1 medium Bagel Nash")
    expect(new_names[1].name).to eq("ls1 medium Bagel Nash")
    expect(new_names[16].name).to eq("ls2 large All Bar One")

    # Does NOT change name for restaurants that are not medium or large
    expect(new_names[2].name).to eq("Barburrito")
  end
end
