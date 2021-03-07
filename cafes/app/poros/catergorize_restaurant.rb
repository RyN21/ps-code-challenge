class CatergorizeRestaurant
  attr_reader :restaurants

  def initialize(restaurants)
    @restaurants = restaurants
  end

  def categorize
    @restaurants.each do |r|
      if r.post_code.include?('LS1')
        catergorize_ls1(r)
      elsif r.post_code.include?('LS2')
        categorize_ls2(r)
      else
        r.category = 'other'
      end
    end
  end

  def catergorize_ls1(r)
    chairs = r.num_of_chairs
    if chairs < 10
      r.update(category: 'ls1 small')
      # r.category = 'ls1 small'
    elsif chairs > 10 && chairs < 100
      r.update(category: 'ls1 medium')
      # r.category = 'ls1 medium'
    else
      r.update(category: 'ls1 large')
      # r.category = 'ls1 large'
    end
  end

  def categorize_ls2(r)
    percentile = find_percentile
    r.num_of_chairs >= percentile ? r.category = 'ls2 large' : r.category = 'ls2 samll'
  end

  def find_percentile
    ls2_chairs  = Restaurant.where("post_code LIKE 'LS2%'").pluck(:num_of_chairs).sort
    chair_count = ls2_chairs.count
    if chair_count.odd?
      index = chair_count / 2
      ls2_chairs[index]
    else
      index_1 = (chair_count / 2) - 1
      index_2 = index_1 + 1
      averave = index_1 + index_2 / 2
      average
    end
  end
end
