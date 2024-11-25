CREATE DATABASE IF NOT EXISTS salesDataWalmart;
USE salesDataWalmart;
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
	branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- -- - - - - - -------------------------------------------------------------------------------
-- --------------------------FEATURE ENGINEERING ---------------------------------------
-- time of the day 
SELECT 
	time,
    (CASE
		WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
    ) AS time_of_date
FROM sales;




ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
		CASE
		WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);



-- --------DAY Name
SELECT
	date,
    DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name = DAYNAME(date)

-- --------MONTH NAME
SELECT
	date,
	MONTHNAME(date)
    FROM sales;
    
ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date)

ALTER TABLE sales DROP COLUMN month_name;


-- -------------------------------------------------------------------------------------------
-- ----------------------------------GENERIC -------------------------------------------------
-- How many unique cities does the data have?
SELECT DISTINCT
	city
    FROM sales;

-- In which city is each branch?
SELECT DISTINCT
	city,
    branch
FROM sales;

-- ----------------------------------------------------------------------------------------
-- ---------------------------------------PRODUCT------------------------------------
-- ----------------------------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

-- Most Common Payment Method?
SELECT 
	payment,
	 COUNT( payment) AS 'count'
FROM sales
GROUP BY payment
ORDER BY count DESC;

-- What is the most selling product line
SELECT 
	product_line,
	COUNT(product_line) AS 'MostSelling'
FROM sales
GROUP BY product_line
ORDER BY MostSelling DESC;

-- What is the total revenue by month
SELECT 
	month_name,
    COUNT(total) AS 'Total_Revenue'
FROM sales
GROUP BY month_name,
ORDER BY Total_Revenue Desc;

-- What month had the largest COGS?
SELECT
	month_name AS Month,
    SUM(cogs) AS TotalCOGS
FROM sales
GROUP BY month_name
ORDER BY TotalCOGS ;

-- What product line had the largest revenue?
SELECT 
	product_line,
    SUM(gross_income) AS Total_Revenue
FROM sales
GROUP BY product_line
ORDER BY Total_Revenue DESC;


-- What is the city with the largest revenue?
SELECT
	branch,
	city,
    SUM(total) AS Total_Income
FROM sales
GROUP BY branch, city
ORDER BY Total_Income DESC;

-- What product line had the largest VAT?
SELECT 
	product_line,
    AVG(tax_pct) AS Largest_VAT
FROM sales
GROUP BY product_line
ORDER BY Largest_VAT DESC;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales






-- Which branch sold more products than average product sold?
(/*SELECT
	branch,
    SUM(quantity) AS Sold
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) 
FROM sales); */)
SELECT 
	branch,
    SUM(quantity) AS TOTAL
    FROM sales
    GROUP BY branch
    HAVING TOTAL > (SELECT AVG(quantity)
    FROm sales);
	
-- What is the most common product line by gender
SELECT
	gender,
    product_line,
    COUNT(gender) AS Most_Ordered
FROM sales
GROUP BY gender, product_line
ORDER BY Most_Ordered;

-- What is the average rating of each product line
SELECT 
	gender,
	product_line,
    ROUND(AVG (rating), 2) AS AVG_Rating
    FROM sales
    GROUP BY gender ,product_line
    ORDER By AVG_Rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------



-- How many unique customer types does the data have?

SELECT 
	DISTINCT customer_type 
FROm sales;


-- How many unique payment methods does the data have?
SELECT DISTINCT 
	payment
FROM sales;


-- What is the most common customer type?
SELECT distinct
	customer_type,
    count(*) AS COUNT
FROM sales
GROUP BY customer_type
ORDER BY COUNT DESC;

-- Which customer type buys the most?
(/*SELECT distinct
	customer_type,
    COUNT(quantity) AS No_of_Orders
FROM sales
GROUP BY customer_type
ORDER BY No_of_Orders DESC; 
*/)
SELECT 
	customer_type,
    Count(*)
    FROM sales
    GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT 
	gender,
    Count(*) AS Most_Customer
FROM sales 
GROUP BY gender
ORDER BY Most_Customer DESC;

-- What is the gender distribution per branch?
(/*SELECT
	gender,
    Count(*) as gender_cnt
FROM sales
WHERE branch =  'c'
GROUP By gender
ORDER By gender_cnt DESC;
*/)
SELECT 
	gender,
    branch,
    COUNT(*) as 'gender_cnt'
FROm sales
GROUP BY gender, branch
ORDER BY gender_cnt DESC;


-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
    AVG(rating) AS cnt
FROM sales
GROUP BY time_of_day
ORDER BY cnt DESC;



-- Which time of the day do customers give most ratings per branch?
SELECT 
	time_of_day,
    branch,
    AVG(rating) AS CNT
FROM sales
GROUP BY time_of_day, branch
ORDER BY CNT DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- Which day of the week has the best avg ratings?
SELECT 
	day_name,
    AVG(rating) AS CNT
FROM sales 
GROUP BY day_name
ORDER BY CNT DESC;

-- Which day of the week has the best average ratings per branch?
(/*
SELECT
	day_name,
    COUNT(day_name) total_sales
FROM sales 
WHERE branch = 'c'
GROUP BY day_name
ORDER BY total_sales;
*/)
SELECT 
	day_name,
    branch,
    AVG(rating) AS rating
FROM sales
GROUP BY day_name, branch
ORDER BY rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------


-- Number of sales made in each time of the day per weekday 
(/*
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
*/)

SELECT 
	day_name,
	time_of_day,
	COUNT(quantity) as TotalSales
FROM sales
GROUP BY time_of_day, day_name
ORDER BY TotalSales DESC;
	
    

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
    SUM(total) AS total
FROm sales 
GROUP BY customer_type
ORDER BY total DESC;

-- Which city has the largest tax/VAT percent?

SELECT 
	city,
    ROUND(AVG(tax_pct), 2) as tax
FROM sales 
GROUP BY city
ORDER BY tax DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
    ROUND(AVG(tax_pct), 2) as tax
FROM sales
GROUP BY customer_type
ORDER BY tax DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

