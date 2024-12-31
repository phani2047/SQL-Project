SELECT * FROM CITY;
SELECT * FROM PRODUCTS;
SELECT * FROM CUSTOMERS;
SELECT * FROM SALES;

--  Q.1 Coffee Consumers Count
-- -- How many people in each city are estimated to consume coffee, given that 25% of the population does?
-- SELECT 
-- CITY_NAME,
-- round(POPULATION * 0.25/1000000,2) as coffee_consumers_in_millions,
-- CITY_RANK
-- FROM CITY
-- ORDER BY 2 DESC

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

-- SELECT 
-- SUM(TOTAL) AS TOTAL_REVENUE
-- FROM SALES
-- WHERE 
-- EXTRACT(YEAR FROM SALE_DATE)=2023
-- AND
-- EXTRACT(QUARTER FROM SALE_DATE)=4

-- SELECT 
-- CI.CITY_NAME,
-- SUM(S.TOTAL) AS TOTAL_REVENUE
-- FROM SALES AS S
-- JOIN CUSTOMERS AS C
-- ON S.CUSTOMER_ID = C.CUSTOMER_ID
-- JOIN CITY AS CI
-- ON C.CITY_ID = CI.CITY_ID
-- WHERE
-- EXTRACT(YEAR FROM S.SALE_DATE)=2023
-- AND
-- EXTRACT(QUARTER FROM S.SALE_DATE)=4
-- GROUP BY 1
-- ORDER BY 2 DESC

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

-- SELECT 
-- P.PRODUCT_NAME,
-- COUNT(S.SALE_ID) AS TOTAL_ORDERS
-- FROM PRODUCTS AS P
-- LEFT JOIN 
-- SALES AS S
-- ON S.PRODUCT_ID=P.PRODUCT_ID
-- GROUP BY 1
-- ORDER BY 2 DESC


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?


-- SELECT 
--     AVG(S.TOTAL) AS SALES_AMOUNT,
--     CI.CITY_NAME
-- FROM SALES AS S
-- JOIN CUSTOMERS AS C
-- ON S.CUSTOMER_ID = C.CUSTOMER_ID
-- JOIN CITY AS CI
-- ON CI.CITY_ID = C.CITY_ID
-- GROUP BY CI.CITY_NAME
-- ORDER BY SALES_AMOUNT DESC;

-- SELECT 
-- 	ci.city_name,
-- 	SUM(s.total) as total_revenue,
-- 	COUNT(DISTINCT s.customer_id) as total_cx,
-- 	ROUND(
-- 			SUM(s.total)::numeric/
-- 				COUNT(DISTINCT s.customer_id)::numeric
-- 			,2) as avg_sale_pr_cx
	
-- FROM sales as s
-- JOIN customers as c
-- ON s.customer_id = c.customer_id
-- JOIN city as ci
-- ON ci.city_id = c.city_id
-- GROUP BY 1
-- ORDER BY 2 DESC

-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)
-- WITH CITY_TABLE AS(
-- SELECT CITY_NAME,
-- ROUND((POPULATION*0.25/1000000),2)AS COFFEE_CONSUMERS
-- FROM CITY
-- ),
-- CUSTOMERS_TABLE AS(
-- SELECT
-- CI.CITY_NAME, COUNT(DISTINCT C.CUSTOMER_ID)AS UNIQUE_CX
-- FROM SALES AS S
-- JOIN CUSTOMERS AS C
-- ON C.CUSTOMER_ID=S.CUSTOMER_ID
-- JOIN CITY AS CI
-- ON CI.CITY_ID=C.CITY_ID
-- GROUP BY 1
-- )
-- SELECT
-- CUSTOMERS_TABLE.CITY_NAME,
-- CITY_TABLE.COFFEE_CONSUMERS AS COFFEE_CONSUMERS_IN_MILLIONS,
-- CUSTOMERS_TABLE.UNIQUE_CX
-- FROM CITY_TABLE
-- JOIN 
-- CUSTOMERS_TABLE
-- ON 
-- CITY_TABLE.CITY_NAME = CUSTOMERS_TABLE.CITY_NAME

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
-- SELECT * 
-- FROM 
-- (
-- SELECT
-- CI.CITY_NAME, P.PRODUCT_NAME, COUNT(S.SALE_ID) AS TOTAL ORDERS,
-- FROM SALES AS S
-- JOIN PRODUCTS AS P
-- ON S.PRODUCT_ID=P.PRODUCT_ID
-- JOIN CUSTOMERS AS C
-- ON C.CUSTOMER_ID=S.CUSTOMER_ID
-- JOIN CITY AS CI
-- ON CI.CITY_ID=C.CITY_ID
-- GROUP BY 1,2

-- ) AS T1
-- WHERE RANK <=3

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

-- SELECT * FROM PRODUCTS;

-- SELECT 
-- CI.CITY_NAME,
-- 	COUNT(DISTINCT C.CUSTOMER_ID) as UNIQUE_CX
-- FROM CITY AS CI
-- LEFT JOIN 
-- CUSTOMERS AS C
-- ON C.CITY_ID=CI.CITY_ID
-- JOIN SALES AS S
-- ON S.CUSTOMER_ID=C.CUSTOMER_ID
-- WHERE 
-- 	S.PRODUCT_ID IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
-- GROUP BY 1

-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

-- Conclusions

-- WITH city_table
-- AS
-- (
-- 	SELECT 
-- 		ci.city_name,
-- 		SUM(s.total) as total_revenue,
-- 		COUNT(DISTINCT s.customer_id) as total_cx,
-- 		ROUND(
-- 				SUM(s.total)::numeric/
-- 					COUNT(DISTINCT s.customer_id)::numeric
-- 				,2) as avg_sale_pr_cx
		
-- 	FROM sales as s
-- 	JOIN customers as c
-- 	ON s.customer_id = c.customer_id
-- 	JOIN city as ci
-- 	ON ci.city_id = c.city_id
-- 	GROUP BY 1
-- 	ORDER BY 2 DESC
-- ),
-- city_rent
-- AS
-- (SELECT 
-- 	city_name, 
-- 	estimated_rent
-- FROM city
-- )
-- SELECT 
-- 	cr.city_name,
-- 	cr.estimated_rent,
-- 	ct.total_cx,
-- 	ct.avg_sale_pr_cx,
-- 	ROUND(
-- 		cr.estimated_rent::numeric/
-- 									ct.total_cx::numeric
-- 		, 2) as avg_rent_per_cx
-- FROM city_rent as cr
-- JOIN city_table as ct
-- ON cr.city_name = ct.city_name
-- ORDER BY 4 DESC


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
WITH
monthly_sales
AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(YEAR FROM sale_date) as YEAR,
		SUM(s.total) as total_sale
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
),
growth_ratio
AS
(
		SELECT
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
		FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		(cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
		, 2
		) as growth_ratio

FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL	


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer



WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	total_revenue,
	cr.estimated_rent as total_rent,
	ct.total_cx,
	estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC



