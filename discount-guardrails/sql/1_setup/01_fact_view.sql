/*
01_fact_view.sql
Question: none directly. This view is the single starting point for every analysis script.
One output row = one order line
Steps: join each order line to its product and customer, give the mislabelled PRODUCT
columns proper names, and add the quarter label, discount band and implied cost.
*/

-- A view saves this SELECT under a name, so the other scripts can query it like a table.
-- CREATE OR ALTER means I can re-run the script after changing it.
CREATE OR ALTER VIEW dbo.fct_order_line AS
SELECT
    orders.ROW_ID,
    orders.ORDER_ID,
    orders.ORDER_DATE,
    YEAR(orders.ORDER_DATE) AS ORDER_YEAR,
    DATEPART(QUARTER, orders.ORDER_DATE) AS ORDER_QUARTER,
    CONCAT('Q', DATEPART(QUARTER, orders.ORDER_DATE), '-', YEAR(orders.ORDER_DATE)) AS QUARTER_YEAR,
    orders.SHIP_MODE,
    orders.CUSTOMER_ID,
    customer.SEGMENT,
    customer.REGION,
    customer.STATE,                         -- the customer's listed state, not the delivery address
    orders.PRODUCT_ID,
    product.NAME AS CATEGORY,               -- source column NAME holds the category
    product.CATEGORY AS SUB_CATEGORY,       -- source column CATEGORY holds the sub-category
    product.SUBCATEGORY AS PRODUCT_NAME,    -- source column SUBCATEGORY holds the product name
    orders.QUANTITY,
    orders.DISCOUNT,
    CASE
        WHEN orders.DISCOUNT = 0 THEN '1. No Discount'
        WHEN orders.DISCOUNT <= 0.20 THEN '2. Standard (up to 20%)'
        WHEN orders.DISCOUNT <= 0.50 THEN '3. Deep (over 20% to 50%)'
        ELSE '4. Clearance (over 50%)'
    END AS DISCOUNT_BAND,                   -- number prefix makes ORDER BY sort the bands correctly
    orders.SALES,                           -- sales are already after the discount
    orders.PROFIT,
    orders.SALES - orders.PROFIT AS IMPLIED_COST
FROM
    dbo.ORDERS AS orders
INNER JOIN dbo.PRODUCT AS product ON orders.PRODUCT_ID = product.ID
INNER JOIN dbo.CUSTOMER AS customer ON orders.CUSTOMER_ID = customer.ID;
