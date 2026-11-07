/*
13_q4_ceiling_scenarios.sql
Q4. What would different discount ceilings have meant for 2014-2017?
THIS IS A MODEL, NOT A RESULT. It re-prices past order lines under assumptions.
One output row = one ceiling + volume assumption (result 1), one sub-category + ceiling +
volume assumption (result 2), one sub-category + volume assumption (result 3).

How a line above the ceiling is re-priced:
    list price sales  = SALES / (1 - DISCOUNT)            (undo the discount)
    re-priced sales   = list price sales * (1 - MAX_DISCOUNT)
    re-priced profit  = re-priced sales - IMPLIED_COST     (assumes cost stays the same)
VOLUME_RETAINED = share of those capped lines the customer still buys at the smaller discount.
    1.00 = every customer still buys, 0.00 = every capped line is lost.
Lines at or below the ceiling are left exactly as they were.
MAX_DISCOUNT = 0.80 is the highest discount in the data, so it means "no change".
*/

-- Result 1: company-level scenarios
WITH ceilings AS (
    SELECT 0.20 AS MAX_DISCOUNT
    UNION ALL SELECT 0.30
    UNION ALL SELECT 0.40
    UNION ALL SELECT 0.50
    UNION ALL SELECT 0.80
),
volume AS (
    SELECT 1.00 AS VOLUME_RETAINED
    UNION ALL SELECT 0.75
    UNION ALL SELECT 0.50
    UNION ALL SELECT 0.25
    UNION ALL SELECT 0.00
),
line_scenarios AS (
    SELECT
        ceilings.MAX_DISCOUNT,
        volume.VOLUME_RETAINED,
        order_line.SALES,
        order_line.PROFIT,
        CASE WHEN order_line.DISCOUNT > ceilings.MAX_DISCOUNT THEN 1 ELSE 0 END AS IS_CAPPED,
        CASE
            WHEN order_line.DISCOUNT > ceilings.MAX_DISCOUNT
                THEN volume.VOLUME_RETAINED * (order_line.SALES / (1 - order_line.DISCOUNT) * (1 - ceilings.MAX_DISCOUNT))
            ELSE order_line.SALES
        END AS MODELLED_SALES,
        CASE
            WHEN order_line.DISCOUNT > ceilings.MAX_DISCOUNT
                THEN volume.VOLUME_RETAINED * (order_line.SALES / (1 - order_line.DISCOUNT) * (1 - ceilings.MAX_DISCOUNT) - order_line.IMPLIED_COST)
            ELSE order_line.PROFIT
        END AS MODELLED_PROFIT
    FROM
        dbo.fct_order_line AS order_line
    CROSS JOIN ceilings          -- every order line is paired with every ceiling ...
    CROSS JOIN volume            -- ... and every volume assumption
)
SELECT
    MAX_DISCOUNT,
    VOLUME_RETAINED,
    SUM(IS_CAPPED) AS CAPPED_LINES,
    ROUND(SUM(SALES), 2) AS OBSERVED_SALES,
    ROUND(SUM(MODELLED_SALES), 2) AS MODELLED_SALES,
    ROUND(SUM(PROFIT), 2) AS OBSERVED_PROFIT,
    ROUND(SUM(MODELLED_PROFIT), 2) AS MODELLED_PROFIT,
    ROUND(SUM(MODELLED_PROFIT) - SUM(PROFIT), 2) AS PROFIT_CHANGE,
    ROUND(SUM(MODELLED_SALES) - SUM(SALES), 2) AS SALES_CHANGE,
    ROUND(100.0 * SUM(MODELLED_PROFIT) / SUM(MODELLED_SALES), 1) AS MODELLED_MARGIN_PCT
FROM
    line_scenarios
GROUP BY
    MAX_DISCOUNT,
    VOLUME_RETAINED
ORDER BY
    MAX_DISCOUNT,
    VOLUME_RETAINED DESC;

-- Result 2: the same scenarios for each sub-category
WITH ceilings AS (
    SELECT 0.20 AS MAX_DISCOUNT
    UNION ALL SELECT 0.30
    UNION ALL SELECT 0.40
    UNION ALL SELECT 0.50
    UNION ALL SELECT 0.80
),
volume AS (
    SELECT 1.00 AS VOLUME_RETAINED
    UNION ALL SELECT 0.75
    UNION ALL SELECT 0.50
    UNION ALL SELECT 0.25
    UNION ALL SELECT 0.00
),
line_scenarios AS (
    SELECT
        ceilings.MAX_DISCOUNT,
        volume.VOLUME_RETAINED,
        order_line.CATEGORY,
        order_line.SUB_CATEGORY,
        order_line.SALES,
        order_line.PROFIT,
        CASE WHEN order_line.DISCOUNT > ceilings.MAX_DISCOUNT THEN 1 ELSE 0 END AS IS_CAPPED,
        CASE
            WHEN order_line.DISCOUNT > ceilings.MAX_DISCOUNT
                THEN volume.VOLUME_RETAINED * (order_line.SALES / (1 - order_line.DISCOUNT) * (1 - ceilings.MAX_DISCOUNT))
            ELSE order_line.SALES
        END AS MODELLED_SALES,
        CASE
            WHEN order_line.DISCOUNT > ceilings.MAX_DISCOUNT
                THEN volume.VOLUME_RETAINED * (order_line.SALES / (1 - order_line.DISCOUNT) * (1 - ceilings.MAX_DISCOUNT) - order_line.IMPLIED_COST)
            ELSE order_line.PROFIT
        END AS MODELLED_PROFIT
    FROM
        dbo.fct_order_line AS order_line
    CROSS JOIN ceilings
    CROSS JOIN volume
)
SELECT
    CATEGORY,
    SUB_CATEGORY,
    MAX_DISCOUNT,
    VOLUME_RETAINED,
    SUM(IS_CAPPED) AS CAPPED_LINES,
    ROUND(SUM(PROFIT), 2) AS OBSERVED_PROFIT,
    ROUND(SUM(MODELLED_PROFIT), 2) AS MODELLED_PROFIT,
    ROUND(SUM(MODELLED_PROFIT) - SUM(PROFIT), 2) AS PROFIT_CHANGE,
    ROUND(SUM(MODELLED_SALES) - SUM(SALES), 2) AS SALES_CHANGE
FROM
    line_scenarios
GROUP BY
    CATEGORY,
    SUB_CATEGORY,
    MAX_DISCOUNT,
    VOLUME_RETAINED
ORDER BY
    CATEGORY,
    SUB_CATEGORY,
    MAX_DISCOUNT,
    VOLUME_RETAINED DESC;

-- Result 3: for each sub-category and volume assumption, which ceiling gives the most modelled profit?
-- If two ceilings tie (nothing was discounted that deeply), the looser one wins, i.e. "no change needed".
WITH ceilings AS (
    SELECT 0.20 AS MAX_DISCOUNT
    UNION ALL SELECT 0.30
    UNION ALL SELECT 0.40
    UNION ALL SELECT 0.50
    UNION ALL SELECT 0.80
),
volume AS (
    SELECT 0.75 AS VOLUME_RETAINED
    UNION ALL SELECT 0.50
    UNION ALL SELECT 0.25
),
line_scenarios AS (
    SELECT
        ceilings.MAX_DISCOUNT,
        volume.VOLUME_RETAINED,
        order_line.CATEGORY,
        order_line.SUB_CATEGORY,
        order_line.PROFIT,
        CASE
            WHEN order_line.DISCOUNT > ceilings.MAX_DISCOUNT
                THEN volume.VOLUME_RETAINED * (order_line.SALES / (1 - order_line.DISCOUNT) * (1 - ceilings.MAX_DISCOUNT) - order_line.IMPLIED_COST)
            ELSE order_line.PROFIT
        END AS MODELLED_PROFIT
    FROM
        dbo.fct_order_line AS order_line
    CROSS JOIN ceilings
    CROSS JOIN volume
),
subcategory_scenarios AS (
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        MAX_DISCOUNT,
        VOLUME_RETAINED,
        SUM(PROFIT) AS OBSERVED_PROFIT,
        SUM(MODELLED_PROFIT) AS MODELLED_PROFIT
    FROM
        line_scenarios
    GROUP BY
        CATEGORY,
        SUB_CATEGORY,
        MAX_DISCOUNT,
        VOLUME_RETAINED
),
ranked AS (
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        MAX_DISCOUNT,
        VOLUME_RETAINED,
        OBSERVED_PROFIT,
        MODELLED_PROFIT,
        ROW_NUMBER() OVER (
            PARTITION BY SUB_CATEGORY, VOLUME_RETAINED
            ORDER BY ROUND(MODELLED_PROFIT, 2) DESC, MAX_DISCOUNT DESC
        ) AS PROFIT_RANK
    FROM
        subcategory_scenarios
)
SELECT
    CATEGORY,
    SUB_CATEGORY,
    VOLUME_RETAINED,
    MAX_DISCOUNT AS BEST_MAX_DISCOUNT,
    ROUND(OBSERVED_PROFIT, 2) AS OBSERVED_PROFIT,
    ROUND(MODELLED_PROFIT, 2) AS MODELLED_PROFIT,
    ROUND(MODELLED_PROFIT - OBSERVED_PROFIT, 2) AS PROFIT_CHANGE
FROM
    ranked
WHERE
    PROFIT_RANK = 1
ORDER BY
    CATEGORY,
    SUB_CATEGORY,
    VOLUME_RETAINED DESC;

-- Result 4: a worse case than the model. What if a customer drops the WHOLE order
-- when one line in it can no longer get more than 20% off?
WITH capped_orders AS (
    SELECT DISTINCT
        ORDER_ID
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT > 0.20
)
SELECT
    COUNT(DISTINCT order_line.ORDER_ID) AS ORDERS_AFFECTED,
    ROUND(SUM(CASE WHEN order_line.DISCOUNT > 0.20 THEN order_line.PROFIT ELSE 0 END), 2) AS PROFIT_ON_CAPPED_LINES,
    SUM(CASE WHEN order_line.DISCOUNT <= 0.20 THEN 1 ELSE 0 END) AS OTHER_LINES_IN_THESE_ORDERS,
    ROUND(SUM(CASE WHEN order_line.DISCOUNT <= 0.20 THEN order_line.SALES ELSE 0 END), 2) AS SALES_ON_OTHER_LINES,
    ROUND(SUM(CASE WHEN order_line.DISCOUNT <= 0.20 THEN order_line.PROFIT ELSE 0 END), 2) AS PROFIT_ON_OTHER_LINES,
    -- profit change if every affected order disappears completely
    ROUND(-1 * SUM(order_line.PROFIT), 2) AS PROFIT_CHANGE_IF_WHOLE_ORDERS_LOST
FROM
    dbo.fct_order_line AS order_line
INNER JOIN capped_orders ON order_line.ORDER_ID = capped_orders.ORDER_ID;

-- Result 5: the extreme case. How much profit do the customers who ever got more than 20% off
-- bring in on their OTHER lines? This is what is at risk if a cap drives those customers away.
WITH deep_discount_customers AS (
    SELECT DISTINCT
        CUSTOMER_ID
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT > 0.20
)
SELECT
    COUNT(DISTINCT order_line.CUSTOMER_ID) AS CUSTOMERS,
    ROUND(SUM(CASE WHEN order_line.DISCOUNT > 0.20 THEN order_line.PROFIT ELSE 0 END), 2) AS PROFIT_ON_DEEP_DISCOUNT_LINES,
    ROUND(SUM(CASE WHEN order_line.DISCOUNT <= 0.20 THEN order_line.PROFIT ELSE 0 END), 2) AS PROFIT_ON_OTHER_LINES,
    -- (SELECT SUM(PROFIT) ...) is a small query inside the main one that returns one number: total company profit
    ROUND(100.0 * SUM(CASE WHEN order_line.DISCOUNT <= 0.20 THEN order_line.PROFIT ELSE 0 END)
          / (SELECT SUM(PROFIT) FROM dbo.fct_order_line), 1) AS OTHER_LINES_SHARE_OF_COMPANY_PROFIT_PCT
FROM
    dbo.fct_order_line AS order_line
INNER JOIN deep_discount_customers ON order_line.CUSTOMER_ID = deep_discount_customers.CUSTOMER_ID;
