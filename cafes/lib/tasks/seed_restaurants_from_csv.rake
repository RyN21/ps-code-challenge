require 'csv'

namespace :db do
  desc "Seed restaurants from csv file"
  task seed_restaurants: :environment do
    Restaurant.destroy_all
    CSV.foreach("./Street Cafes 2020-21.csv", headers: true) do |row|
      Restaurant.create({
        name: row[0],
        street_address: row[1],
        post_code: row[2],
        num_of_chairs: row[3],
        })
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("Restaurant")
  end

  task seed_small_restaurants: :environment do
    Restaurant.destroy_all
    CSV.foreach("./Small Street Cafes 2020-21.csv", headers: true) do |row|
      Restaurant.create({
        name: row[0],
        street_address: row[1],
        post_code: row[2],
        num_of_chairs: row[3],
        })
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("Restaurant")
  end
end
