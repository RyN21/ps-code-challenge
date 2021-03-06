![](https://assets-global.website-files.com/5b69e8315733f2850ec22669/5b749a4663ff82be270ff1f5_GSC%20Lockup%20(Orange%20%3A%20Black).svg)

### Welcome to the take home portion of your interview! We're excited to jam through some technical stuff with you, but first it'll help to get a sense of how you work through data and coding problems. Work through what you can independently, but do feel free to reach out if you have blocking questions or problems.

1) This requires Postgres (9.4+) & Rails(4.2+), so if you don't already have both installed, please install them.

2) Download the data file from: https://github.com/gospotcheck/ps-code-challenge/blob/master/Street%20Cafes%202020-21.csv

3) Add a varchar column to the table called `category`. 

4) Create a view with the following columns[provide the view SQL]
    - post_code: The Post Code
    - total_places: The number of places in that Post Code
    - total_chairs: The total number of chairs in that Post Code
    - chairs_pct: Out of all the chairs at all the Post Codes, what percentage does this Post Code represent (should sum to 100% in the whole view)
    - place_with_max_chairs: The name of the place with the most chairs in that Post Code
    - max_chairs: The number of chairs at the place_with_max_chairs
	
    *Please also include a brief description of how you verified #4*
    
    After creating a Restaurants table and a Restaurant model (class), I creating some sample instances of a Restaurant in the 
    restaurant_spec.rb file. I then called the self method on the Restaurant class that sorts the restaurants by post code (by_post_code)
    and stored them in `data`.
    I then wrote tests based on what the outcome should equal to. 
    I created a smaller version of the original CSV file and I am considering to implement that data into the spec instead of creating my own instances. 
    As of now, I am unsure what is meant by (view SQL) but will look deeper into this.
    
    Was able to look into`CREATE VIEW` and I must say, I really like what it can do. 
    I was able to use it to solve the last part I was struggling with for this query. 
    
    To verify the answers, I used a smaller version of the csv file to compare and made some tests for it.
    Here are the Views: 
    
    ```
    CREATE VIEW v_names_pc AS
    SELECT name, post_code, num_of_chairs FROM restaurants ORDER BY post_code;
    
    CREATE VIEW v_by_post_code AS
    SELECT post_code,
    COUNT(id) AS total_places,
    SUM(num_of_chairs) AS total_chairs,
    ROUND((SUM(num_of_chairs)*100.00)/(SELECT SUM(num_of_chairs) FROM restaurants), 2) AS chairs_pct,
    (SELECT name FROM v_names_pc WHERE v_names_pc.post_code = restaurants.post_code ORDER BY num_of_chairs DESC LIMIT 1) AS place_with_max_chairs,
    MAX(num_of_chairs) AS max_chairs
    FROM restaurants
    GROUP BY post_code
    ORDER BY post_code;
    ```
    ![Screen Shot 2021-03-07 at 10 10 25 PM](https://user-images.githubusercontent.com/33795357/110277268-22290b00-7f92-11eb-8674-4682a89c1ef6.png)



5) Write a Rails script to categorize the cafes and write the result to the category according to the rules:[provide the script]
    - If the Post Code is of the LS1 prefix type:
        - `# of chairs less than 10: category = 'ls1 small'`
        - `# of chairs greater than or equal to 10, less than 100: category = 'ls1 medium'`
        - `# of chairs greater than or equal to 100: category = 'ls1 large' `
    - If the Post Code is of the LS2 prefix type: 
        - `# of chairs below the 50th percentile for ls2: category = 'ls2 small'`
        - `# of chairs above the 50th percentile for ls2: category = 'ls2 large'`
    - For Post Code is something else:
        - `category = 'other'`

    *Please share any tests you wrote for #5*
    
    I couldn't decide between creating class methods in the Restaurant model or creating a seperate class that takes in an array of restaurants and then categorizes each restaurant. So I did both for now. The methods are essentially the same in both. 
    So the approach I took was taking the list or Restaurants and iterating over each. I then had if else statemtents that divided the restaurant by post_code. 
    - If restaurant post_code.include?("LS1") then call the catergorize_ls1 method. 
    	- this method would then update the category column based on the amount of chairs with "ls1_small", "ls1_medium", and "ls1_large"
    - If restaurant post_code.include?("LS2") then call the catergorize_ls2 method. 
    	- this method start with finding the percentile with a helper method.
    	- this helper method would take take all the restaurants with "LS2" in the post_code and create an array of num_of_chairs, and then sort them in order.
    	- I then created an if statement for whether the array was odd or even.
    	- if odd, then took the middle index and called that the percentile
    	- if even, I avereged the 2 middle elements and called that the percentile
    	- After finding the percentile, I simply created another if statement that compared whether the num_of_chairs is less then or equal/greater than the percentile. if larger than category = "ls2 large" if smaller then category = "ls2 small"
    - If it has neither of those post codes, the category is updated to = "other"

    For the test, I took the smaller sample csv file and iterated over each to create Restaurants. Here is what I tested...
    ```
    it '.categorize_cafes' do
      data = Restaurant.categorize
      expect(data[0].category).to eq("ls1 medium")
      expect(data[1].category).to eq("ls2 large")
      expect(data[4].category).to eq("ls1 small")
      expect(data[17].category).to eq("ls2 small")
    end
    ```
    ![Screen Shot 2021-03-07 at 3 13 27 PM](https://user-images.githubusercontent.com/33795357/110276894-5fd96400-7f91-11eb-9d34-e9678bab7ce9.png)


6) Write a custom view to aggregate the categories [provide view SQL AND the results of this view]
    - category: The category column
    - total_places: The number of places in that category
    - total_chairs: The total chairs in that category

    View: 
    ```
    CREATE VIEW v_aggregate_categories AS
    SELECT category,
    COUNT(id) AS total_places,
    SUM(num_of_chairs) AS total_chairs
    FROM restaurants
    GROUP BY category
    ORDER BY category;
    ```

7) Write a script in rails to:
    - For street_cafes categorized as small, write a script that exports their data to a csv and deletes the records
    - For street cafes categorized as medium or large, write a script that concatenates the category name to the beginning of the name and writes it back to the name column
	
    *Please share any tests you wrote for #7*
    
    Test that it can export data to csv:
    ```
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
    ```
    
    Test that it can delete records:
    ```
    it '.delete_records' do
      Restaurant.categorize
      small = Restaurant.where("category LIKE ?", "%small")
      expect(small.count).to eq(4)

      Restaurant.delete_small
      new_small = Restaurant.where("category LIKE ?", "%small")
      expect(new_small.count).to eq(0)
    end
    ```
    
    Test that it can edit names:
    ```
    it '.edit_names' do
      Restaurant.categorize
      Restaurant.edit_names
      data = Restaurant.all.order(:num_of_chairs)
      expect(data[2].name).to eq("Barburrito")
      expect(data[3].name).to eq("ls1 medium Bagel Nash")
      expect(data[20].name).to eq("ls2 large All Bar One")
    end
    ```

8) Show your work and check your email for submission instructions.

9) Celebrate, you did great! 

PHEWW!!
