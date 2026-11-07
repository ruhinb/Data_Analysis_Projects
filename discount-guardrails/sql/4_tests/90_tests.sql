/*
90_tests.sql
Validation checks. Each check is one SELECT returning the same four columns, joined with
UNION ALL (like the row-count check at the end of 00_load.sql). The final SELECT adds PASS/FAIL.
One output row = one check.
CHECK_RULE 'equal' = ACTUAL must equal EXPECTED; CHECK_RULE 'max' = ACTUAL must not be above EXPECTED.
Checks V9-V13 are done outside SQL (see docs/validation.md).
*/

WITH checks AS (
    -- V1: row counts after loading
    SELECT 'V1a' AS CHECK_ID, 'ORDERS row count' AS CHECK_NAME, 'equal' AS CHECK_RULE,
           CAST(9994 AS DECIMAL(18,2)) AS EXPECTED, CAST(COUNT(*) AS DECIMAL(18,2)) AS ACTUAL
    FROM dbo.ORDERS
    UNION ALL
    SELECT 'V1b', 'CUSTOMER row count', 'equal', 793, COUNT(*) FROM dbo.CUSTOMER
    UNION ALL
    SELECT 'V1c', 'PRODUCT row count', 'equal', 1862, COUNT(*) FROM dbo.PRODUCT
    UNION ALL
    SELECT 'V1d', 'EMPLOYEES row count', 'equal', 9, COUNT(*) FROM dbo.EMPLOYEES

    -- V2: keys are unique
    UNION ALL
    SELECT 'V2a', 'Duplicate ROW_ID values', 'equal', 0, COUNT(*) - COUNT(DISTINCT ROW_ID) FROM dbo.ORDERS
    UNION ALL
    SELECT 'V2b', 'Duplicate product IDs', 'equal', 0, COUNT(*) - COUNT(DISTINCT ID) FROM dbo.PRODUCT
    UNION ALL
    SELECT 'V2c', 'Duplicate customer IDs', 'equal', 0, COUNT(*) - COUNT(DISTINCT ID) FROM dbo.CUSTOMER

    -- V3: every order line finds its customer and product
    UNION ALL
    SELECT 'V3a', 'Order lines with no matching customer', 'equal', 0, COUNT(*)
    FROM dbo.ORDERS AS orders
    LEFT JOIN dbo.CUSTOMER AS customer ON orders.CUSTOMER_ID = customer.ID
    WHERE customer.ID IS NULL
    UNION ALL
    SELECT 'V3b', 'Order lines with no matching product', 'equal', 0, COUNT(*)
    FROM dbo.ORDERS AS orders
    LEFT JOIN dbo.PRODUCT AS product ON orders.PRODUCT_ID = product.ID
    WHERE product.ID IS NULL

    -- V4: the joins in the fact view did not add or lose rows
    UNION ALL
    SELECT 'V4', 'Fact view row count (no join fan-out)', 'equal', 9994, COUNT(*) FROM dbo.fct_order_line

    -- V5: totals reconcile between the raw table and the fact view
    UNION ALL
    SELECT 'V5a', 'Total sales in raw ORDERS', 'equal', 2297200.86, ROUND(SUM(SALES), 2) FROM dbo.ORDERS
    UNION ALL
    SELECT 'V5b', 'Total profit in raw ORDERS', 'equal', 286397.02, ROUND(SUM(PROFIT), 2) FROM dbo.ORDERS
    UNION ALL
    SELECT 'V5c', 'Total sales in fact view', 'equal', 2297200.86, ROUND(SUM(SALES), 2) FROM dbo.fct_order_line
    UNION ALL
    SELECT 'V5d', 'Total profit in fact view', 'equal', 286397.02, ROUND(SUM(PROFIT), 2) FROM dbo.fct_order_line

    -- V6: every line has exactly one band, and there are 12 discount levels
    UNION ALL
    SELECT 'V6a', 'Lines with no discount band', 'equal', 0, COUNT(*) FROM dbo.fct_order_line WHERE DISCOUNT_BAND IS NULL
    UNION ALL
    SELECT 'V6b', 'Distinct discount levels', 'equal', 12, COUNT(DISTINCT DISCOUNT) FROM dbo.fct_order_line
    UNION ALL
    SELECT 'V6c', 'Distinct discount bands', 'equal', 4, COUNT(DISTINCT DISCOUNT_BAND) FROM dbo.fct_order_line

    -- V7: dates were read correctly (month/day order) and make sense
    UNION ALL
    SELECT 'V7a', 'First order date (as yyyymmdd)', 'equal', 20140103,
           YEAR(MIN(ORDER_DATE)) * 10000 + MONTH(MIN(ORDER_DATE)) * 100 + DAY(MIN(ORDER_DATE))
    FROM dbo.ORDERS
    UNION ALL
    SELECT 'V7b', 'Last order date (as yyyymmdd)', 'equal', 20171230,
           YEAR(MAX(ORDER_DATE)) * 10000 + MONTH(MAX(ORDER_DATE)) * 100 + DAY(MAX(ORDER_DATE))
    FROM dbo.ORDERS
    UNION ALL
    SELECT 'V7c', 'Lines shipped before they were ordered', 'equal', 0, COUNT(*) FROM dbo.ORDERS WHERE SHIP_DATE < ORDER_DATE

    -- V8: the scenario maths behaves as it should
    -- V8a: a ceiling of 80% caps nothing, so modelled profit must equal observed profit
    UNION ALL
    SELECT 'V8a', 'Scenario at 80% ceiling: modelled minus observed profit', 'equal', 0,
           ROUND(SUM(CASE WHEN DISCOUNT > 0.80
                          THEN 1.00 * (SALES / (1 - DISCOUNT) * (1 - 0.80) - IMPLIED_COST)
                          ELSE PROFIT END) - SUM(PROFIT), 2)
    FROM dbo.fct_order_line
    -- V8b: keeping 0% of capped volume must equal simply removing every line above the ceiling
    UNION ALL
    SELECT 'V8b', 'Scenario at 20% ceiling, 0% volume kept: modelled minus (profit of lines at or below 20%)', 'equal', 0,
           ROUND(SUM(CASE WHEN DISCOUNT > 0.20
                          THEN 0.00 * (SALES / (1 - DISCOUNT) * (1 - 0.20) - IMPLIED_COST)
                          ELSE PROFIT END)
                 - SUM(CASE WHEN DISCOUNT <= 0.20 THEN PROFIT ELSE 0 END), 2)
    FROM dbo.fct_order_line
    -- V8c: re-pricing a line at its OWN discount must give back its original profit
    UNION ALL
    SELECT 'V8c', 'Re-priced at own discount: total difference from observed profit', 'equal', 0,
           ROUND(SUM((SALES / (1 - DISCOUNT) * (1 - DISCOUNT) - IMPLIED_COST) - PROFIT), 2)
    FROM dbo.fct_order_line

    -- V12: one possible duplicate (ROW_ID 3407 repeats 3406 apart from the employee)
    UNION ALL
    SELECT 'V12', 'Profit change if ROW_ID 3407 is removed (% of total profit)', 'max', 0.10,
           ROUND(100.0 * ABS(SUM(CASE WHEN ROW_ID = 3407 THEN PROFIT ELSE 0 END)) / SUM(PROFIT), 2)
    FROM dbo.ORDERS
)
SELECT
    CHECK_ID,
    CHECK_NAME,
    CHECK_RULE,
    EXPECTED,
    ACTUAL,
    CASE
        WHEN CHECK_RULE = 'equal' AND ACTUAL = EXPECTED THEN 'PASS'
        WHEN CHECK_RULE = 'max' AND ACTUAL <= EXPECTED THEN 'PASS'
        ELSE 'FAIL'
    END AS STATUS
FROM
    checks
ORDER BY
    CHECK_ID;
