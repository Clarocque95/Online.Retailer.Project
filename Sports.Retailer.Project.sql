                                            
                                                -- PROBLEM 1 --
-- PART 1
-- Find the total number of unique products.

-- First, I used the COUNT function to get the total number of values in the product_id column. 
-- I then used the COUNT function combined with the DISTINCT statement to find unique product names from the info table. 
-- We see that many products have more than one product_id.
SELECT COUNT(product_id) as product_id_count, COUNT(DISTINCT product_name) AS unique_products_count 
FROM info


-- PART 2 
-- Are there any null values in the info table? 

-- I used a COUNT function for every column of the info table and subtracted it from the total count of rows.
-- Since the COUNT function does NOT count null values, once we subtract it from count of total rows, we will obtain the number of null values.
-- It's no surprise that the product_id column had no NULL values since this is the PRIMARY KEY. The other columns in the info table have NULL values. 
SELECT COUNT(*) - COUNT(product_id) AS product_id_null_count,
       COUNT(*) - COUNT(product_name) AS product_name_null_count, 
       COUNT(*) - COUNT(description) AS description_null_count
FROM info 



                                                -- PROBLEM 2 --
-- Which product(s) was most recently viewed and which product(s) was least recently viewed?

-- I joined the traffic and brands tables. There are two select statements (2 tables) which I combined using the UNION operator.
-- In the first table, we obtain the least recently viewed products and in the second table we obtain the most recently viewed products.
-- This is done by adding a subquery in the WHERE clause. In this subquery we get the MIN and MAX of last_visited date.  
SELECT brand, t.product_id, last_visited
FROM traffic t
JOIN brands b
ON t.product_id = b.product_id
WHERE last_visited = (SELECT MIN(last_visited) FROM traffic)

UNION

SELECT brand, t.product_id, last_visited
FROM traffic t
JOIN brands b
ON t.product_id = b.product_id
WHERE last_visited = (SELECT MAX(last_visited) FROM traffic)
ORDER BY last_visited



                                                -- PROBLEM 3 --
-- Find the number of products and the average rating for each brand.

-- We must join the brands and reviews tables and use the COUNT, SUM and ROUND functions.
-- I filtered out NULL values for the brand and used a GROUP BY statement for brand.
-- The table shows that there is approximately five times more Adidas products than Nike products and that Nike products have a higher rating. 
SELECT brand, 
       COUNT(*) AS count_products,
	   ROUND(AVG(rating), 2) AS average_rating
FROM brands b
JOIN info i
ON b.product_id = i.product_id
JOIN reviews r
ON b.product_id = r.product_id
WHERE brand IS NOT NULL
GROUP BY brand



                                                -- PROBLEM 4 --
-- PART 1
-- For each brand, find the following information: number of products sold, sum of total sales and the minimum, maximum and average of the sale price. 

-- We must use MIN, MAX, ROUND, AVG and SUM functions to solve this problem. 
-- I joined the transactions and brands tables and used a GROUP BY statement.
-- The final table shows that Adidas has sold more products than Nike and collected more revenue. Also, we see that Nike has nearly double the average sale price of Adidas. 
SELECT brand, 
       COUNT(*) AS number_of_products_sold,
	   SUM(sale_price) AS sum_revenue,
       MIN(sale_price) AS min_sale_price, 
	   MAX(sale_price) AS max_sale_price,  
       ROUND(AVG(sale_price), 2) AS avg_sale_price
FROM transactions t
JOIN brands b
ON t.product_id = b.product_id
WHERE brand IS NOT NULL
GROUP BY brand


-- PART 2
-- What percentage of revenue does each brand have compared to the total revenue?

-- I first need the revenue of a particular brand. Then, I use this result in a subquery and divide it by the total revenue. 
-- I used the ROUND function to get 2 decimals, I multiplied by 100 to get a percentage and used the CONCAT function to add a percentage sign. 
-- The data shows that Adidas products have made nearly 75% of the total revenue. 
SELECT
	CONCAT(ROUND((SELECT SUM(sale_price) 
	 			  FROM transactions t 
	 		      JOIN brands b
	              ON t.product_id = b.product_id 
	              WHERE brand = 'Adidas')
	/SUM(sale_price)*100, 2), '%') AS adidas_portion_revenue,
	
	CONCAT(ROUND((SELECT SUM(sale_price) 
	 			  FROM transactions t 
	 		      JOIN brands b
	              ON t.product_id = b.product_id 
	              WHERE brand = 'Nike')
	/SUM(sale_price)*100, 2), '%') AS nike_portion_revenue
FROM transactions



                                               -- PROBLEM 5 --
-- PART 1
-- What are the 10 products with the highest revenue?

-- I joined the transactions, info and brands tables together.
-- I used an ORDER BY clause to sort the revenue in descending order and I used a LIMIT clause to only obtain the top 10 rows (top 10 products).
-- We see that 9/10 products with the highest revenue are from Adidas.
SELECT brand, product_name, SUM(sale_price) AS total_sales
FROM transactions t
JOIN info i
ON t.product_id = i.product_id
JOIN brands b
ON t.product_id = b.product_id
WHERE product_name IS NOT NULL
GROUP BY product_name, brand
ORDER BY total_sales DESC
LIMIT 10


-- PART 2
-- There is one Nike product in the top 10 of highest selling products. What portion of the revenue does this specific product have in the total revenue for Nike?

-- The query is like PART 1, but we must filter out all Adidas products. 
-- I used a subquery within the select statement. This subquery represents the total revenue for Nike products. I divided the revenue for each row by this total revenue.  
-- The table shows that the product with the highest revenue represents over 2.25% of the total revenue for Nike products and the next product is at 1.75%. 
SELECT brand, 
       product_name, 
       SUM(sale_price) as revenue, 
	   CONCAT(ROUND(SUM(sale_price)/(SELECT SUM(sale_price) as revenue
								     FROM transactions t                            
                                     JOIN brands b
                                     ON t.product_id = b.product_id
                                     WHERE brand = 'Nike')*100, 2), '%') AS portion_of_revenue														
FROM transactions t
JOIN brands b
ON t.product_id = b.product_id
JOIN info i
ON t.product_id = i.product_id
WHERE brand = 'Nike'
GROUP BY product_name, brand
ORDER BY revenue DESC
LIMIT 10



                                                -- PROBLEM 6 --
--PART 1
-- Calculate the correlation between sale_price and rating.

-- I used the CORR function to get the correlation coefficient and CAST function to convert the number into a numeric data type. 
SELECT ROUND(CAST(CORR(sale_price, rating) AS numeric), 2) AS rating_revenue_correlation
FROM transactions t
JOIN reviews r
ON t.product_id = r.product_id


-- PART 2
-- Calculate the correlation between the rating and the number of times a product is sold.

-- Since we can't use an aggregate function within the CORR function, we need a CTE (common table expression).
WITH CTE AS 
(
	SELECT product_id, COUNT(product_id) as total_sales
    FROM transactions
    GROUP BY product_id
)
SELECT ROUND(CAST(CORR(total_sales, rating) AS numeric), 2) AS rating_revenue_correlation
FROM CTE
JOIN reviews r
ON cte.product_id = r.product_id



                                                -- PROBLEM 7 --
-- Create a table showing the rating within different categories ranging from terrible to excellent for each brand. 
-- Also include the number of products and the total revenue within each category.

-- A CASE statement must be used to achieve the desired result. I also joined the reviews, brands and transactions tables and sorted the results by total revenue in descending order. 
-- The final table shows Nike has no products in the terrible rating category and each brand has more products in the excellent and good rating categories.
SELECT brand,
	CASE 
		WHEN 0 <= rating AND rating < 1 THEN 'Terrible rating'
		WHEN 1 <= rating AND rating < 2 THEN 'Poor rating'
		WHEN 2 <= rating AND rating < 3 THEN 'Mediocre rating'
		WHEN 3 <= rating AND rating < 4 THEN 'Good rating'
		ELSE 'Excellent rating'
	END AS rating_category,
	COUNT(DISTINCT t.product_id) AS number_of_products,
	COUNT(*) AS number_of_products_sold,    
	SUM(sale_price) AS total_revenue
FROM reviews r
JOIN brands b
ON r.product_id = b.product_id
JOIN transactions t
ON r.product_id = t.product_id
WHERE rating IS NOT NULL
GROUP BY brand, rating_category
ORDER BY total_revenue DESC
	


                                                -- PROBLEM 8 --
-- Create different categories for the length of the description column and calculate the number of products and the average rating for each category.

-- This query will return the max character length for the description column. I used the MAX and LENGTH functions. 
SELECT MAX(LENGTH(description)) AS max_description_length FROM info

-- After obtaining the maximum length of the description column, I created different categories using a CASE statement. 
-- I used COUNT and AVG functions and I joined info and reviews tables together. 
-- The results shows that most products have a description length between 200-299 and that the average rating is similar for each category. 
SELECT 
	CASE
	WHEN LENGTH(description) < 100 THEN '0-99' 
	WHEN LENGTH(description) < 200 THEN '100-199' 
	WHEN LENGTH(description) < 300 THEN '200-299' 
	WHEN LENGTH(description) < 400 THEN '300-399' 
	WHEN LENGTH(description) < 500 THEN '400-499' 
	WHEN LENGTH(description) < 600 THEN '500-599' 
	ELSE '600-699'
	END AS description_length,
	
	COUNT(i.product_id) AS number_of_products, 
	ROUND(AVG(rating), 2) AS average_rating

FROM info i
JOIN reviews r
ON i.product_id = r.product_id
WHERE description IS NOT NULL
GROUP BY description_length
ORDER BY description_length



                                                -- PROBLEM 9 --
-- PART 1
-- Find the number of products for men and for women.												
												
-- In the WHERE clause, I used the LIKE operator for the product_name column.
-- I used CROSS JOIN to join the result for 'men' and the result for 'women'.
-- Finally, it's critical to use the LOWER function in the WHERE clause. The LIKE operator is case sensitive, therefore 'Men' is different than 'men'. 
-- The table shows that most products are for men. 
SELECT COUNT(i1.product_id) AS men_products_count, i2.women_products_count
FROM info i1
CROSS JOIN (SELECT COUNT(product_id) AS women_products_count
			FROM info 
			WHERE LOWER(product_name) LIKE '%women%') i2
WHERE LOWER(product_name) LIKE '%men%'
GROUP BY i2.women_products_count


-- PART 2
-- Find the number of products that are either slippers or sandals.

-- To solve this problem, I used the OR operator within the WHERE clause. 
SELECT COUNT(product_id) AS product_count
FROM info
WHERE LOWER(product_name) LIKE '%slipper%' OR LOWER(product_name) LIKE '%sandal%' 


-- PART 3
-- Most of the products sold are shoes, what portion of the total revenue are from shoe sales?

-- We must use the SUM function and join info and transactions tables together.
-- This shows that approximately 68% of the total revenue is from shoe sales. 
SELECT CONCAT(ROUND((SELECT SUM(sale_price) AS revenue_shoes
		FROM info i
        JOIN transactions t
        ON i.product_id = t.product_id
        WHERE LOWER(product_name) LIKE '%shoes%') / SUM(sale_price)*100, 2), '%') AS shoe_products_revenue_portion
FROM transactions
	
			

                                                -- PROBLEM 10 --
-- PART 1
-- Find the number of products for each sale price.

-- Join transactions to brands on product_id and use the COUNT function with a DISTINCT statement on the product_id column from the transactions table.
-- Aggregate results by brand and sale_price and sort the results by sale_price in descending order.
-- We see that Adidas products occupy most of the low sale prices. 
SELECT brand, sale_price AS sale_price, COUNT(DISTINCT t.product_id) AS count
FROM transactions t
JOIN brands b
ON t.product_id = b.product_id
WHERE brand IS NOT NULL
GROUP BY brand, sale_price
ORDER BY sale_price DESC


-- PART 2
-- Find the most popular sale price for each brand. 

-- Most popular means the sale price with the most products sold, not the sale price with the highest number of products. 
-- I can use a query nearly identical to PART 1 within a CTE, but I need to use COUNT(*) instead of COUNT(DISTINCT t.product_id).
-- In there WHERE clause, I added a subquery that returns the max count for a specific brand. 
-- Also, I used the UNION operator to join the result for Adidas with the result for Nike.
WITH CTE AS 
(
	SELECT brand, sale_price AS sale_price, COUNT(*) AS count
	FROM transactions t
	JOIN brands b
	ON t.product_id = b.product_id
	WHERE brand IS NOT NULL
	GROUP BY brand, sale_price
	ORDER BY sale_price DESC
)
SELECT *
FROM CTE
WHERE count = (SELECT MAX(count) FROM CTE WHERE brand = 'Adidas') AND brand = 'Adidas'
GROUP BY brand, sale_price, count
UNION
SELECT *
FROM CTE
WHERE count = (SELECT MAX(count) FROM CTE WHERE brand = 'Nike') AND brand = 'Nike'
GROUP BY brand, sale_price, count



                                                -- PROBLEM 11 --
-- PART 1 
-- Which months have a total revenue over 45,000$?

-- The DATE_PART function is used in this query to get the month and the year from the date column in the transactions table.
-- The function SUM was used to calculate the total revenue for every month.
-- I added a HAVING clause since it's impossible to use aggregate functions in a WHERE CLAUSE. This clause will filter out all the months with less than 45,000$ in total revenue. 
-- I used a GROUP BY statement for month and year columns. I also sorted the table by year and month respectively. 
SELECT DATE_PART('month', date) AS month, 
       DATE_PART('year', date) AS year, 
	   SUM(sale_price) AS total_revenue	
FROM transactions
GROUP BY month, year
HAVING SUM(sale_price) > 45000
ORDER BY 2, 3


-- PART 2 
-- Find the month and year with the highest revenue.

-- I used a CTE which is like the query in part 1, but without the HAVING clause. 
-- I added a subquery in the WHERE clause to select the maximum total revenue.
-- The month of January in 2019 was the month with the highest total revenue. 
WITH CTE AS 
(
	SELECT DATE_PART('month', date) AS month, DATE_PART('year', date) AS year, SUM(sale_price) AS total_revenue
	FROM transactions
    GROUP BY month, year
    ORDER BY 2, 1
)
SELECT *
FROM CTE
WHERE total_revenue = (SELECT MAX(total_revenue) FROM CTE)


-- PART 3
-- Find the monthly average revenue for each year.     

-- The solve this problem, we can't simple use the AVG function. This will lead to an incorrect result.
-- To find the average revenue per month for each year, we must divide the total yearly revenue by the number of months within that year.
-- The get the number of months within each year, I used a COUNT function and added a DISTINCT statement. Without the DISTINCT statement, the result would be incorrect. 
SELECT DATE_PART('year', date) AS year, 
       SUM(sale_price) AS total_revenue, 
	   ROUND(SUM(sale_price)/COUNT(DISTINCT DATE_PART('month', date)), 2) AS monthly_average
FROM transactions
GROUP BY year
ORDER BY year


-- The previous table showed that the average revenue for 2020 is low compared to 2018 and 2019. 
-- This is because we divided the total revenue of 2020 by 4 (number of months), but the fourth month is not complete, therefore the query must be modified.
-- In this query, I filtered out data from the month of April and only kept the data from January to March (3 months in total).
-- We now see that the monthly average revenue for 2020 is higher than 2018 and 2019!
SELECT DATE_PART('year', date) AS year, SUM(sale_price) AS total_revenue, ROUND(SUM(sale_price)/COUNT(DISTINCT DATE_PART('month', date)), 2) AS monthly_average
FROM transactions
WHERE DATE_PART('year', date) = '2020' AND DATE_PART('month', date) <= 3
GROUP BY year
ORDER BY year


-- PART 4
-- Find the total revenue and the average revenue by brand for each year.

-- Very similar to part 3, but we must also join the brands table and GROUP BY brand. 
-- Also, this time I used a UNION operator so that we can see all the data in one table.  
-- We see that Nike's monthly average in 2020 is very high compared to other years (but 2020 is not yet over), whereas Adidas's monthly average is similar for every year.
SELECT brand, 
       DATE_PART('year', date) AS year, 
       SUM(sale_price) AS total_revenue, 
	   ROUND(SUM(sale_price)/COUNT(DISTINCT DATE_PART('month', date)), 2) AS monthly_average
FROM transactions t
JOIN brands b
ON t.product_id = b.product_id
WHERE DATE_PART('year', date) <> '2020'
GROUP BY brand, year

UNION 

SELECT brand, 
       DATE_PART('year', date) AS year, 
       SUM(sale_price) AS total_revenue, 
	   ROUND(SUM(sale_price)/COUNT(DISTINCT DATE_PART('month', date)), 2) AS monthly_average
FROM transactions t
JOIN brands b
ON t.product_id = b.product_id
WHERE DATE_PART('year', date) = '2020' AND DATE_PART('month', date) <= 3
GROUP BY brand, year
ORDER BY brand, year



                                                -- PROBLEM 12 --
-- PART 1
-- List the total sales by month for all years combined. 

-- I used a case statement to replace the months from numbers to the actual name of the month. This makes it easier to read and see quickly which months have the highest sales. 
-- I excluded sales from 2020, since the data stops during the month of April. If I had kept this data, it would have skewed the results for the months of Jan, Feb and March.
-- The data is aggregated by month and the total revenue is sorted in descending order.
-- We see that July has the highest total sales and that February has the lowest total sales. 
SELECT CASE 
       WHEN DATE_PART('month', date) = 1 THEN 'January' 
       WHEN DATE_PART('month', date) = 2 THEN 'February' 
	   WHEN DATE_PART('month', date) = 3 THEN 'March' 
	   WHEN DATE_PART('month', date) = 4 THEN 'April' 
	   WHEN DATE_PART('month', date) = 5 THEN 'May' 
	   WHEN DATE_PART('month', date) = 6 THEN 'June' 
	   WHEN DATE_PART('month', date) = 7 THEN 'July' 
       WHEN DATE_PART('month', date) = 8 THEN 'August' 
	   WHEN DATE_PART('month', date) = 9 THEN 'September' 
	   WHEN DATE_PART('month', date) = 10 THEN 'October' 
	   WHEN DATE_PART('month', date) = 11 THEN 'November' 
	   ELSE 'December' 
	   END AS month,
       
	   SUM(sale_price) AS total_revenue
	   
FROM transactions t
WHERE DATE_PART('year', date) <> '2020' 
GROUP BY month
ORDER BY 2 DESC


-- PART 2
-- List the total sales by season for each brand. 

-- I used a CASE statement to group the months in different categories (seasons).
-- I joined the brands and transactions tables and excluded data from 2020 for the same reason as in part 1.
-- Finally the data is aggregated by season and brand and I sorted total revenue in descending order. 
SELECT CASE 
       WHEN DATE_PART('month', date) IN (1,2,12)  THEN 'Winter'
	   WHEN DATE_PART('month', date) IN (3,4,5)  THEN 'Spring' 
	   WHEN DATE_PART('month', date) IN (6,7,8)  THEN 'Summer' 
	   WHEN DATE_PART('month', date) IN (9,10,11)  THEN 'Fall' 
       END AS season,
	   brand, SUM(sale_price) AS total_revenue
FROM brands b
JOIN transactions t
ON b.product_id = t.product_id
WHERE brand IS NOT NULL AND DATE_PART('year', date) <> '2020' 
GROUP BY season, brand
ORDER by total_revenue DESC



                                                -- PROBLEM 13 --
-- PART 1
-- Create a table showing the difference in total revenue per month for the year 2019. Also include a column with the difference in a percentage format.

-- I used the DATE_PART function to get the months and the years from the date column of the transactions table.
-- We need the window function LAG() to solve this problem.
-- We see that from January to February the company had the biggest decrease in total revenue and from February to March, the company saw the highest increase in total sales.
-- The table also shows that the total revenue varies more within the first 5 months of the year. 
SELECT DATE_PART('year', date) AS year, 
	   DATE_PART('month', date) AS month, 
	   SUM(sale_price) AS total_monthly_revenue,
	   SUM(sale_price) - LAG(SUM(sale_price)) OVER() AS total_monthly_revenue_diff, 
	   CONCAT(ROUND((SUM(sale_price) - LAG(SUM(sale_price)) OVER()) / SUM(sale_price)*100, 2), '%') AS total_monthly_revenue_diff_percentage
FROM transactions 
WHERE DATE_PART('year', date) = 2019
GROUP BY month, year 
ORDER BY 1, 2


-- PART 2
-- Create a table showing the difference in average daily revenue per month for the year 2018 and Nike products only. Also include a column with the difference in a percentage format.

-- The query is like part 1, but it's more complicated since we can't combine AVG and SUM functions together (Can't use AVG(SUM(sale_price))).
-- I used a similar logic to problem 11 part 3, where I used a COUNT function with a distinct statement. So, I divide the monthly revenue by the number of days within that month.
-- Finally, I filtered the data for the year 2018 and for Nike products.  
-- The table shows a considerable decrease in daily average revenue in the month of March.
SELECT DATE_PART('year', date) AS year, 
       DATE_PART('month', date) AS month, 
	   ROUND(SUM(sale_price)/COUNT(DISTINCT date), 2) AS avg_daily_revenue,
	   ROUND((SUM(sale_price)/COUNT(DISTINCT date)) - (LAG(SUM(sale_price)/COUNT(DISTINCT date)) OVER ()), 2) AS avg_daily_revenue_diff,
	   CONCAT(ROUND(((SUM(sale_price)/COUNT(DISTINCT date)) - (LAG(SUM(sale_price)/COUNT(DISTINCT date)) OVER ())) / (SUM(sale_price)/COUNT(DISTINCT date))*100, 2), '%') AS avg_daily_revenue_diff_percentage
FROM transactions t
JOIN brands b
ON t.product_id = b.product_id
WHERE brand = 'Nike' AND DATE_PART('year', date) = '2018'
GROUP BY month, year
ORDER BY month



                                                -- PROBLEM 14 --
-- PART 1
-- Create a table showing the monthly revenue and the running total for the year 2019 and for Addidas products only. 

-- I first wrote a query returning a table showing the monthly revenue for the year 2019.
-- I used a window function that calculates the yearly revenue running total for 2019.
WITH CTE AS 
(
    SELECT DATE_PART('year', date) AS year, DATE_PART('month', date) AS month, SUM(sale_price) as monthly_revenue
    FROM transactions t
    JOIN brands b
    ON t.product_id = b.product_id
    WHERE DATE_PART('year', date) = 2019 AND  brand = 'Adidas'
    GROUP BY month, year
)
SELECT year, month, monthly_revenue, SUM(monthly_revenue) OVER(ORDER BY month) total_revenue
FROM CTE
ORDER BY 1, 2


-- PART 2
-- Create a query that will produce a table showing the daily moving average for the month of May in 2018.

-- I first created a table showing the daily revenue for the month of May in 2018. 
-- I used a window function that calculates the moving average for 31 days (whole month of May).
WITH CTE AS 
(
   SELECT date, SUM(sale_price) as daily_revenue
   FROM transactions t
   JOIN brands b
   ON t.product_id = b.product_id
   WHERE DATE_PART('year', date) = 2018 AND DATE_PART('month', date) = 5
   GROUP BY date
)
SELECT date, daily_revenue, ROUND(AVG(daily_revenue) OVER W, 2) AS moving_daily_average
FROM CTE
WINDOW W AS (ORDER BY DATE_PART('month', date) ROWS BETWEEN 31 PRECEDING AND CURRENT ROW)
ORDER BY date



                                                -- PROBLEM 15 --
-- PART 1
-- Which day has the record for most products sold?

-- We can solve this problem using the window function ROW_NUMBER(), thus we don't need a GROUP BY statement.
-- This shows that the online retailer sold the most products on July 21, 2019.
WITH CTE AS
(
	SELECT date, ROW_NUMBER() OVER(PARTITION BY date) AS number_of_products_sold
	FROM transactions
)
SELECT date, number_of_products_sold
FROM CTE
WHERE number_of_products_sold = (SELECT MAX(number_of_products_sold) FROM CTE)

 
-- PART 2
-- Rank the products having sold the most items. 

-- I used the DENSE_RANK() window function to solve this problem. 
-- We also need a COUNT function, join transactions and info tables together and group by product_name.
-- We see a total of 78 different ranks. 
SELECT product_name, COUNT(*) AS number_of_products, DENSE_RANK() OVER(ORDER BY COUNT(*) DESC)
FROM transactions t
JOIN info i
ON t.product_id = i.product_id
GROUP BY product_name

-- We can also use RANK function instead of DENSE_RANK. 
-- I prefer DENSE_RANK, since RANK leaves gaps between the values. If we have two items with rank of 13, the next rank will be 15.
SELECT product_name, COUNT(*) AS number_of_products, RANK() OVER(ORDER BY COUNT(*) DESC)
FROM transactions t
JOIN info i
ON t.product_id = i.product_id
GROUP BY product_name

