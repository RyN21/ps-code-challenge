require 'rails_helper'

RSpec.describe CatergorizeRestaurant, type: :model do
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

    @rest = Restaurant.all
  end
  it 'can categorize restaurants' do
    restaurants = CatergorizeRestaurant.new(@rest)
    restaurants.categorize

    expect(restaurants[0].category).to eq("ls1 medium")

    # expect(restaurants[0].category)to. eq()
  end
end
