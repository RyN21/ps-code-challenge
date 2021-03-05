class Cafe < ApplicationRecord
  validates_presence_of :name,
                        :street_address,
                        :post_code,
                        :num_of_chairs
end
