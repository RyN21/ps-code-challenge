require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe "Validations" do
    it {should validate_presence_of :name}
    it {should validate_presence_of :street_address}
    it {should validate_presence_of :post_code}
    it {should validate_presence_of :num_of_chairs}
  end
  describe "class methods" do
    before(:each) do
      @restaurant_1 = Restaurant.create(name: "All Bar One",
                                        street_address: "27 East Parade",
                                        post_code: "LS1 5BN",
                                        num_of_chairs: 20)
      @restaurant_2 = Restaurant.create(name: "All Bar One",
                                        street_address: "Unit D Electric Press, 4 Mi",
                                        post_code: "LS2 3AD",
                                        num_of_chairs: 140)
      @restaurant_3 = Restaurant.create(name: "Bagel Nash",
                                        street_address: "34 St. Pauls Street",
                                        post_code: "LS1 2AT",
                                        num_of_chairs: 14)
      @restaurant_4 = Restaurant.create(name: "Caffé Nero (APS)",
                                        street_address: "19 Albion Place",
                                        post_code: "LS1 6JS",
                                        num_of_chairs: 20)
      @restaurant_5 = Restaurant.create(name: "Caffe Nero (Albion Street s",
                                        street_address: "19 Albion Place",
                                        post_code: "LS1 6JS",
                                        num_of_chairs: 16)
      @restaurant_6 = Restaurant.create(name: "Caffe Nero (Bond Street side)",
                                        street_address: "19 Albion Place",
                                        post_code: "LS1 6JS",
                                        num_of_chairs: 22)
      @restaurant_7 = Restaurant.create(name: "Carluccios",
                                        street_address: "5 Greek Street",
                                        post_code: "LS1 5SX",
                                        num_of_chairs: 18)
      @restaurant_8 = Restaurant.create(name: "Cattle Grid",
                                        street_address: "Waterloo House, Assembly St",
                                        post_code: "LS2 7DB",
                                        num_of_chairs: 20)
    end

    it '.can sort restaurants by post code' do
      data = Restaurant.by_post_code
      binding.pry
      expect(data[0]["post_code"]).to eq("LS1 2AT")
      expect(data[0]["total_places"]).to eq(1)
      expect(data[0]["total_chairs"]).to eq(14)
      expect(data[0]["chairs_pct"]).to eq("5.19")
      # expect(data[0].place_with_max_chairs).to eq("Bagel Nash")
      expect(data[0]["max_chairs"]).to eq(14)

      expect(data[3]["post_code"]).to eq("LS1 6JS")
      expect(data[3]["total_places"]).to eq(3)
      expect(data[3]["total_chairs"]).to eq(58)
      expect(data[3]["chairs_pct"]).to eq("21.48")
      # expect(data[3].place_with_max_chairs).to eq("Caffe Nero (Bond Street side)")
      expect(data[3]["max_chairs"]).to eq(22)
    end
  end
end
