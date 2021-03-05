require 'rails_helper'

describe StreetCafes, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :street_address }
    it { should validate_presence_of :post_code }
    it { should validate_presence_of :num_of_chairs }
  end
end
