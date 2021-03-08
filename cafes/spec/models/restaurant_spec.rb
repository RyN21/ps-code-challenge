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
      ActiveRecord::Base.connection.reset_pk_sequence!('restaurants')
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
      expect(data[0]["place_with_max_chairs"]).to eq("Bagel Nash")
      expect(data[0]["max_chairs"]).to eq(14)
      expect(data[0]["category"]).to eq(nil)

      expect(data[13]["post_code"]).to eq("LS1 6JS")
      expect(data[13]["total_places"]).to eq(3)
      expect(data[13]["total_chairs"]).to eq(58)
      expect(data[13]["chairs_pct"]).to eq("9.56")
      expect(data[13]["place_with_max_chairs"]).to eq("Caffe Nero (Bond Street side)")
      expect(data[13]["max_chairs"]).to eq(22)
      expect(data[13]["category"]).to eq(nil)

      expect(data[14]["post_code"]).to eq("LS1 8EQ")
      expect(data[14]["total_places"]).to eq(2)
      expect(data[14]["total_chairs"]).to eq(28)
      expect(data[14]["chairs_pct"]).to eq("4.61")
      expect(data[14]["place_with_max_chairs"]).to eq("Browns")
      expect(data[14]["max_chairs"]).to eq(20)
      expect(data[14]["category"]).to eq(nil)
    end

    it '.categorize_restaurants' do
      data = Restaurant.categorize
      expect(data[0].category).to eq("ls1 medium")
      expect(data[1].category).to eq("ls2 large")
      expect(data[4].category).to eq("ls1 small")
      expect(data[17].category).to eq("ls2 small")
    end

    it '.aggregate_categories' do
      Restaurant.categorize
      data = Restaurant.aggregate_categories
      expect(data[0]["category"]).to eq("ls1 medium")
      expect(data[0]["total_places"]).to eq(15)
      expect(data[0]["total_chairs"]).to eq(376)
      expect(data[1]["category"]).to eq("ls1 small")
      expect(data[1]["total_places"]).to eq(3)
      expect(data[1]["total_chairs"]).to eq(20)
      expect(data[2]["category"]).to eq("ls2 large")
      expect(data[2]["total_places"]).to eq(2)
      expect(data[2]["total_chairs"]).to eq(191)
      expect(data[3]["category"]).to eq("ls2 small")
      expect(data[3]["total_places"]).to eq(1)
      expect(data[3]["total_chairs"]).to eq(20)
    end

    it 'export_data_to_csv' do
      Restaurant.categorize
      small = Restaurant.where("category LIKE ?", "%small").order(:num_of_chairs)
      csv_small = Restaurant.export_data_to_csv(small)
      csv = CSV.parse(csv_small)

      expect(csv[0][0]).to eq("Café/Restaurant Name")
      expect(csv[0][1]).to eq("Street Address")
      expect(csv[0][2]).to eq("Post Code")
      expect(csv[0][3]).to eq("Number Of Chairs")
      expect(csv[0][4]).to eq("Category")

      expect(csv[3][0]).to eq("Barburrito")
      expect(csv[3][1]).to eq("62 The Headrow")
      expect(csv[3][2]).to eq("LS1 8EQ")
      expect(csv[3][3]).to eq("8")
      expect(csv[3][4]).to eq("ls1 small")

      expect(csv.count).to eq(5)
    end

    it '.delete_records' do
      Restaurant.categorize
      small = Restaurant.where("category LIKE ?", "%small")
      expect(small.count).to eq(4)

      Restaurant.delete_small
      new_small = Restaurant.where("category LIKE ?", "%small")
      expect(new_small.count).to eq(0)
    end

    it '.edit_names' do
      Restaurant.categorize
      Restaurant.edit_names
      data = Restaurant.all.order(:num_of_chairs)
      expect(data[2].name).to eq("Barburrito")
      expect(data[3].name).to eq("ls1 medium Bagel Nash")
      expect(data[20].name).to eq("ls2 large All Bar One")
    end
  end
end
