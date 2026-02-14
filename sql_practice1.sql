--Task 1 | Enforce Missing Business Rules with ALTER TABLE
--Apply the following constraints using ALTER TABLE

--Employees emails must be unique 
'1'
ALTER TABLE employees
ADD CONSTRAINT uq_employees_email UNIQUE (email);

'2'
--Emoployee phone numbers must be mandatory
ALTER TABLE employees
ALTER COLUMN first_name SET NOT NULL;

'3'
--Product prices must be non-negative

-- Удаляем, если существует (не вызовет ошибку, если имени нет)
ALTER TABLE products 
DROP CONSTRAINT IF EXISTS chk_products_price;
-- Исправляем данные (на случай, если там есть отрицательные цены)
UPDATE products SET price = 0 WHERE price < 0;
-- Добавляем заново
ALTER TABLE products 
ADD CONSTRAINT chk_products_price CHECK (price >= 0);

'4'
--Sales totals must be non-negative
ALTER TABLE sales
ADD CONSTRAINT chk_sales_total CHECK (total_sales >= 0);






--Task 2 | Add a New Analytical Attribute


--Adding a new column in sales table, 
--name - sales_channel
--type - TEXT
ALTER TABLE sales
ADD COLUMN sales_channel TEXT;

-- You can text in 'sales_channel' or online or store
ALTER TABLE sales
ADD CONSTRAINT chk_sales_channel
CHECK (sales_channel IN ('online', 'store'));

--If the transaction % 2 = 0, than show the sales channel ONLINE 
UPDATE sales
SET sales_channel = 'online'
WHERE transaction_id % 2 = 0;






--Task 3 | Add Indexes for Query Performance

--We index the sales from product id
CREATE INDEX idx_sales_product_id
ON sales (product_id);

--We index the sales from customer id
CREATE INDEX idx_sales_customer_id
ON sales (customer_id);

--We index the products from the category
CREATE INDEX idx_products_category
ON products (category);

--"1 AND 2 IS A PRIMARY TABLES BUT 3 IS A FOREIGN TABLE"





--Task 4 | Validate Index Usage with EXPLAIN

--**
EXPLAIN
SELECT
    product_id
    SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id;

--1. Is a sequential scan used? (Yes, Becouse we scanning the full data)

--2. Does PostgreSQL leverage the index? (NO - PostgreSQL ignore the index for this code)

--3. Why might the planner choose this plan?
-- Query Planner choose the Seq Scan becouse answer was not have a filtering funcion tag 'WHERE'. SQL need to reed 100% data and thats be more faster than whith the indexing.  





--Task 5 | Reduce Query Cost by Refining SELECT

--Original query
SELECT *
FROM sales;

--Refined query
SELECT
  transaction_id,
  product_id,
  total_sales
FROM sales;


--Why this reduces cost?
--Specifying specific columns instead of * minimizes operations and reduces network load, as the database does not waste resources on reading and transmitting unnecessary data.

--when SELECT * might still be acceptable? 
--This is only acceptable when you are initially studying a table and need to quickly view the data structure.




--Task 6 | ORDER BY and LIMIT for Business Questions

SELECT
    product_id,
    SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 5;

--Sorting cost
--Sorting by a computed field (total_revenue) is an expensive operation, LIMIT 5 reduces costs slightly by allowing the scheduler to store only the 5 largest values in memory.

--Whether indexes help in this case?
--In this case, indexes do not help to speed up ORDER BY directly, as 
  --sorting is done by the aggregate (SUM) and not by the physical column. However, 
  --an index on product_id can speed up the GROUP BY phase, and an index on total_sales can 
  --speed up the summation phase (Aggregation).



--Task 7 | DISTINCT vs GROUP BY (Efficiency Comparison)
--Retrieve unique combinations of category and price using both approaches.

--Using DISTINCT:
EXPLAIN
SELECT DISTINCT
    category,
    price
FROM products;

--Using GROUP BY:
EXPLAIN
SELECT
    category,
    price
FROM products
GROUP BY category, price;

--DISTINCT is about the result form (remove duplicates).
--GROUP BY is about the data structure (preparation for calculations).







--Task 8 | Constraint Enforcement Test
--Attempt to violate at least two constraints you added earlier and observe the errors.

'Examples:'
UPDATE products
SET price = -5
WHERE product_id = 101;

INSERT INTO customers (customer_id, email, phone_number)
VALUES (999, 'anna@example.com', '091000999');

--which constraint was triggered
--the CHECK constraint was triggered with a price of (-5)

--why this protects data quality
--Restrictions prevent the appearance of "broken" or logically incorrect data (Data Corruption) at the lowest level.
 





--Task 9 | Reflection (Short Answer)
'Answer briefly (3–5 sentences total):

Which constraints provide the highest business value?
(FOREIGN KEY) and (CHECK constraints)

Which index would you prioritize in a production environment?
First of all, you should index the columns that are most often used in JOIN and WHERE conditions.

What signals tell you a query needs optimization?
When high estimated value or slow operations'

--Submission Rules
--No table creation
--No schema documentation
--Only ALTER, CREATE INDEX, UPDATE, EXPLAIN, SELECT, WHERE, GROUP BY, HAVING, ORDER BY, LIMI
--Include SQL and short written interpretations
--Remember you need to put the code as .sql file
--Add to staging by git add .
--Commit the changes by git comit -m "meaningfull message"
--Push to GitHub! git push