require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe 'Validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :street_address}
    it {should validate_presence_of :post_code}
    it {should validate_presence_of :num_of_chairs}
  end
  describe 'class methods' do
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
    end

    it '.by_post_code' do
      data = Restaurant.by_post_code
      expect(data[0]["post_code"]).to eq("LS1 2AT")
      expect(data[0]["total_places"]).to eq(1)
      expect(data[0]["total_chairs"]).to eq(14)
      expect(data[0]["chairs_pct"]).to eq("2.31")
      # expect(data[0].place_with_max_chairs).to eq("Bagel Nash")
      expect(data[0]["max_chairs"]).to eq(14)
      expect(data[0]["category"]).to eq(nil)

      expect(data[13]["post_code"]).to eq("LS1 6JS")
      expect(data[13]["total_places"]).to eq(3)
      expect(data[13]["total_chairs"]).to eq(58)
      expect(data[13]["chairs_pct"]).to eq("9.56")
      # expect(data[3].place_with_max_chairs).to eq("Caffe Nero (Bond Street side)")
      expect(data[13]["max_chairs"]).to eq(22)
      expect(data[13]["category"]).to eq(nil)

      expect(data[14]["post_code"]).to eq("LS1 8EQ")
      expect(data[14]["total_places"]).to eq(2)
      expect(data[14]["total_chairs"]).to eq(28)
      expect(data[14]["chairs_pct"]).to eq("4.61")
      # expect(data[3].place_with_max_chairs).to eq("Caffe Nero (Bond Street side)")
      expect(data[14]["max_chairs"]).to eq(20)
      expect(data[14]["category"]).to eq(nil)
    end

    it '.categorize_cafes' do
      data = Restaurant.categorize
      expect(data[0].category).to eq("ls1 medium")
      expect(data[1].category).to eq("ls2 large")
      expect(data[4].category).to eq("ls1 small")
      expect(data[17].category).to eq("ls2 small")
    end

    # it '.categorize_cafes' do
    #   data = Restaurant.categorize_cafes
    #   binding.pry
    #   # ls1 = [@restaurant_1, @restaurant_3, @restaurant_4, @restaurant_5, @restaurant_6, @restaurant_7]
    #   # ls2 = [@restaurant_2, @restaurant_8]
    #   expect(@restaurant_1.category).to eq('ls1 medium')
    #   expect(@restaurant_3.category).to eq('ls1 small')
    #   expect(@restaurant_2.category).to eq('ls1 large')
    #   expect(@restaurant_8.category).to eq('ls1 small')
    # end
  end
end
