class Restaurant < ApplicationRecord
  validates_presence_of :name,
                        :street_address,
                        :post_code,
                        :num_of_chairs

  def self.by_post_code
    binding.pry
  end
end