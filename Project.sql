

-- #### **Q.1 Coffee Consumers Count**
-- *-- Question:** How many people in each city are estimated to consume coffee, given that 25% of the population does?

-- ```sql
-- SELECT
--     CITY_NAME,
--     ROUND(POPULATION * 0.25 / 1000000, 2) AS COFFEE_CONSUMERS_IN_MILLIONS,
--     CITY_RANK
-- FROM CITY
-- ORDER BY 2 DESC;
-- ```

-- ---

-- #### **Q.2 Total Revenue from Coffee Sales**
-- **Question:** What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

-- ```sql
-- SELECT
--     SUM(TOTAL) AS TOTAL_REVENUE
-- FROM SALES
-- WHERE
--     EXTRACT(YEAR FROM SALE_DATE) = 2023
--     AND EXTRACT(QUARTER FROM SALE_DATE) = 4;
-- ```

-- **Breakdown by City:**
-- ```sql
-- SELECT
--     CI.CITY_NAME,
--     SUM(S.TOTAL) AS TOTAL_REVENUE
-- FROM SALES AS S
-- JOIN CUSTOMERS AS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
-- JOIN CITY AS CI ON C.CITY_ID = CI.CITY_ID
-- WHERE
--     EXTRACT(YEAR FROM S.SALE_DATE) = 2023
--     AND EXTRACT(QUARTER FROM S.SALE_DATE) = 4
-- GROUP BY 1
-- ORDER BY 2 DESC;
-- ```

-- ---

-- #### **Q.3 Sales Count for Each Product**
-- **Question:** How many units of each coffee product have been sold?

-- ```sql
-- SELECT
--     P.PRODUCT_NAME,
--     COUNT(S.SALE_ID) AS TOTAL_ORDERS
-- FROM PRODUCTS AS P
-- LEFT JOIN SALES AS S ON S.PRODUCT_ID = P.PRODUCT_ID
-- GROUP BY 1
-- ORDER BY 2 DESC;
-- ```

-- ---

-- #### **Q.4 Average Sales Amount per City**
-- **Question:** What is the average sales amount per customer in each city?

-- ```sql
-- SELECT
--     AVG(S.TOTAL) AS SALES_AMOUNT,
--     CI.CITY_NAME
-- FROM SALES AS S
-- JOIN CUSTOMERS AS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
-- JOIN CITY AS CI ON CI.CITY_ID = C.CITY_ID
-- GROUP BY CI.CITY_NAME
-- ORDER BY SALES_AMOUNT DESC;
-- ```

-- ---

-- #### **Q.5 City Population and Coffee Consumers (25%)**
-- **Question:** Provide a list of cities along with their populations and estimated coffee consumers.

-- ```sql
-- WITH CITY_TABLE AS (
--     SELECT
--         CITY_NAME,
--         ROUND((POPULATION * 0.25 / 1000000), 2) AS COFFEE_CONSUMERS
--     FROM CITY
-- ),
-- CUSTOMERS_TABLE AS (
--     SELECT
--         CI.CITY_NAME, COUNT(DISTINCT C.CUSTOMER_ID) AS UNIQUE_CX
--     FROM SALES AS S
--     JOIN CUSTOMERS AS C ON C.CUSTOMER_ID = S.CUSTOMER_ID
--     JOIN CITY AS CI ON CI.CITY_ID = C.CITY_ID
--     GROUP BY 1
-- )
-- SELECT
--     CUSTOMERS_TABLE.CITY_NAME,
--     CITY_TABLE.COFFEE_CONSUMERS AS COFFEE_CONSUMERS_IN_MILLIONS,
--     CUSTOMERS_TABLE.UNIQUE_CX
-- FROM CITY_TABLE
-- JOIN CUSTOMERS_TABLE ON CITY_TABLE.CITY_NAME = CUSTOMERS_TABLE.CITY_NAME;
-- ```

-- ---

-- #### **Q.6 Top Selling Products by City**
-- **Question:** What are the top 3 selling products in each city based on sales volume?

-- ```sql
-- SELECT *
-- FROM (
--     SELECT
--         CI.CITY_NAME, P.PRODUCT_NAME, COUNT(S.SALE_ID) AS TOTAL_ORDERS,
--         RANK() OVER (PARTITION BY CI.CITY_NAME ORDER BY COUNT(S.SALE_ID) DESC) AS RANK
--     FROM SALES AS S
--     JOIN PRODUCTS AS P ON S.PRODUCT_ID = P.PRODUCT_ID
--     JOIN CUSTOMERS AS C ON C.CUSTOMER_ID = S.CUSTOMER_ID
--     JOIN CITY AS CI ON CI.CITY_ID = C.CITY_ID
--     GROUP BY 1, 2
-- ) AS RANKED_PRODUCTS
-- WHERE RANK <= 3;
-- ```

-- ---

-- #### **Q.7 Customer Segmentation by City**
-- **Question:** How many unique customers are there in each city who have purchased coffee products?

-- ```sql
-- SELECT
--     CI.CITY_NAME,
--     COUNT(DISTINCT C.CUSTOMER_ID) AS UNIQUE_CX
-- FROM CITY AS CI
-- LEFT JOIN CUSTOMERS AS C ON C.CITY_ID = CI.CITY_ID
-- JOIN SALES AS S ON S.CUSTOMER_ID = C.CUSTOMER_ID
-- WHERE
--     S.PRODUCT_ID IN (SELECT PRODUCT_ID FROM PRODUCTS)
-- GROUP BY 1;
-- ```

-- ---

-- #### **Q.8 Average Sale vs Rent**
-- **Question:** Find each city and their average sale per customer and average rent per customer.

-- ```sql
-- WITH CITY_TABLE AS (
--     SELECT
--         CI.CITY_NAME,
--         SUM(S.TOTAL) AS TOTAL_REVENUE,
--         COUNT(DISTINCT S.CUSTOMER_ID) AS TOTAL_CX,
--         ROUND(SUM(S.TOTAL)::NUMERIC / COUNT(DISTINCT S.CUSTOMER_ID)::NUMERIC, 2) AS AVG_SALE_PR_CX
--     FROM SALES AS S
--     JOIN CUSTOMERS AS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
--     JOIN CITY AS CI ON CI.CITY_ID = C.CITY_ID
--     GROUP BY 1
-- ),
-- CITY_RENT AS (
--     SELECT
--         CITY_NAME,
--         ESTIMATED_RENT
--     FROM CITY
-- )
-- SELECT
--     CR.CITY_NAME,
--     CR.ESTIMATED_RENT,
--     CT.TOTAL_CX,
--     CT.AVG_SALE_PR_CX,
--     ROUND(CR.ESTIMATED_RENT::NUMERIC / CT.TOTAL_CX::NUMERIC, 2) AS AVG_RENT_PER_CX
-- FROM CITY_RENT AS CR
-- JOIN CITY_TABLE AS CT ON CR.CITY_NAME = CT.CITY_NAME
-- ORDER BY 4 DESC;
-- ```

-- ---

-- #### **Q.9 Monthly Sales Growth**
-- **Question:** Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city.

-- ```sql
-- WITH MONTHLY_SALES AS (
--     SELECT
--         CI.CITY_NAME,
--         EXTRACT(MONTH FROM SALE_DATE) AS MONTH,
--         EXTRACT(YEAR FROM SALE_DATE) AS YEAR,
--         SUM(S.TOTAL) AS TOTAL_SALE
--     FROM SALES AS S
--     JOIN CUSTOMERS AS C ON C.CUSTOMER_ID = S.CUSTOMER_ID
--     JOIN CITY AS CI ON CI.CITY_ID = C.CITY_ID
--     GROUP BY 1, 2, 3
-- ),
-- GROWTH_RATIO AS (
--     SELECT
--         CITY_NAME,
--         MONTH,
--         YEAR,
--         TOTAL_SALE AS CR_MONTH_SALE,
--         LAG(TOTAL_SALE, 1) OVER (PARTITION BY CITY_NAME ORDER BY YEAR, MONTH) AS LAST_MONTH_SALE
--     FROM MONTHLY_SALES
-- )
-- SELECT
--     CITY_NAME,
--     MONTH,
--     YEAR,
--     CR_MONTH_SALE,
--     LAST_MONTH_SALE,
--     ROUND((CR_MONTH_SALE - LAST_MONTH_SALE)::NUMERIC / LAST_MONTH_SALE::NUMERIC * 100, 2) AS GROWTH_RATIO
-- FROM GROWTH_RATIO
-- WHERE LAST_MONTH_SALE IS NOT NULL;
-- ```

-- ---

-- #### **Q.10 Market Potential Analysis**
-- **Question:** Identify the top 3 cities based on the highest sales, and return city name, total sales, total rent, total customers, and estimated coffee consumers.

-- ```sql
-- WITH CITY_TABLE AS (
--     SELECT
--         CI.CITY_NAME,
--         SUM(S.TOTAL) AS TOTAL_REVENUE,
--         COUNT(DISTINCT S.CUSTOMER_ID) AS TOTAL_CX,
--         ROUND(SUM(S.TOTAL)::NUMERIC / COUNT(DISTINCT S.CUSTOMER_ID)::NUMERIC, 2) AS AVG_SALE_PR_CX
--     FROM SALES AS S
--     JOIN CUSTOMERS AS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
--     JOIN CITY AS CI ON CI.CITY_ID = C.CITY_ID
--     GROUP BY 1
-- ),
-- CITY_RENT AS (
--     SELECT
--         CITY_NAME,
--         ESTIMATED_RENT,
--         ROUND((POPULATION * 0.25) / 1000000, 3) AS ESTIMATED_COFFEE_CONSUMER_IN_MILLIONS
--     FROM CITY
-- )
-- SELECT
--     CR.CITY_NAME,
--     CT.TOTAL_REVENUE,
--     CR.ESTIMATED_RENT AS TOTAL_RENT,
--     CT.TOTAL_CX,
--     CR.ESTIMATED_COFFEE_CONSUMER_IN_MILLIONS,
--     CT.AVG_SALE_PR_CX,
--     ROUND(CR.ESTIMATED_RENT::NUMERIC / CT.TOTAL_CX::NUMERIC, 2) AS AVG_RENT_PER_CX
-- FROM CITY_RENT AS CR
-- JOIN CITY_TABLE AS CT ON CR.CITY_NAME = CT.CITY_NAME
-- ORDER BY 2 DESC
-- LIMIT 3;
-- ```

-- ---

-- ### Additional Questions

-- #### **Q.11 Revenue Contribution by Each Product**
-- **Question:** What is the revenue contribution of each coffee product, and what percentage does each contribute to the total revenue?

-- ```sql
-- SELECT
--     P.PRODUCT_NAME,
--     SUM(S.TOTAL) AS TOTAL_REVENUE,
--     ROUND((SUM(S.TOTAL) / (SELECT SUM(TOTAL) FROM SALES)) * 100, 2) AS REVENUE_PERCENTAGE
-- FROM PRODUCTS AS P
-- LEFT JOIN SALES AS S ON P.PRODUCT_ID = S.PRODUCT_ID
-- GROUP BY P.PRODUCT_NAME
-- ORDER BY TOTAL_REVENUE DESC;
-- ```

-- #### **Q.12 Repeat Customer Analysis**
-- **Question:** How many customers have made multiple purchases, and what percentage of the total customer base does this represent?

-- ```sql
-- WITH PURCHASE_COUNT AS (
--     SELECT CUSTOMER_ID, COUNT(SALE_ID) AS TOTAL_PURCHASES
--     FROM SALES
--     GROUP BY CUSTOMER_ID
-- )
-- SELECT
--     COUNT(*) AS REPEAT_CUSTOMERS,
--     ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM CUSTOMERS), 2) AS PERCENTAGE_OF_TOTAL
-- FROM PURCHASE_COUNT
-- WHERE TOTAL_PURCHASES > 1;
-- ```

-- #### **Q.13 Seasonal Sales Analysis**
-- **Question:** What is the total revenue generated in each season (Spring, Summer, Fall, Winter) of 2023?

-- ```sql
-- SELECT
--     CASE
--         WHEN EXTRACT(MONTH FROM SALE_DATE) IN (3, 4, 5) THEN 'Spring'
--         WHEN EXTRACT(MONTH FROM SALE_DATE) IN (6, 7, 8) THEN 'Summer'
--         WHEN EXTRACT(MONTH FROM SALE_DATE) IN (9, 10, 11) THEN 'Fall'
--         ELSE 'Winter'
--     END AS SEASON,
--     SUM(TOTAL) AS TOTAL_REVENUE
-- FROM SALES
-- WHERE EXTRACT(YEAR FROM SALE_DATE) = 2023
-- GROUP BY SEASON
-- ORDER BY TOTAL_REVENUE DESC;
-- ```

-- #### **Q.14 Most Profitable City**
-- **Question:** Which city generated the highest revenue, and what percentage of the total revenue does it represent?

-- ```sql
-- SELECT
--     CI.CITY_NAME,
--     SUM(S.TOTAL) AS TOTAL_REVENUE,
--     ROUND((SUM(S.TOTAL) / (SELECT SUM(TOTAL) FROM SALES)) * 100, 2) AS REVENUE_PERCENTAGE
-- FROM SALES AS S
-- JOIN CUSTOMERS AS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
-- JOIN CITY AS CI ON C.CITY_ID = CI.CITY_ID
-- GROUP BY CI.CITY_NAME
-- ORDER BY TOTAL_REVENUE DESC
-- LIMIT 1;
-- ```

-- #### **Q.15 Customer Retention Analysis**
-- **Question:** What is the retention rate of customers who made purchases in 2023 compared to previous years?

-- ```sql
-- WITH CUSTOMER_YEARS AS (
--     SELECT DISTINCT CUSTOMER_ID, EXTRACT(YEAR FROM SALE_DATE) AS SALE_YEAR
--     FROM SALES
-- )
-- SELECT
--     COUNT(DISTINCT CY1.CUSTOMER_ID) AS CUSTOMERS_2023,
--     COUNT(DISTINCT CY2.CUSTOMER_ID) AS CUSTOMERS_PREV_YEAR,
--     ROUND(
--         (COUNT(DISTINCT CY1.CUSTOMER_ID) * 100.0) / COUNT(DISTINCT CY2.CUSTOMER_ID), 2
--     ) AS RETENTION_RATE
-- FROM CUSTOMER_YEARS AS CY1
-- LEFT JOIN CUSTOMER_YEARS AS CY2 ON CY1.CUSTOMER_ID = CY2.CUSTOMER_ID AND CY2.SALE_YEAR < 2023
-- WHERE CY1.SALE_YEAR = 2023;
-- ```

-- ---

