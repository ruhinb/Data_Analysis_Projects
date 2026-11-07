/*
12_q3_concentration.sql
Q3. How concentrated are the deep-discount losses?
"Deep-discount loss" = the profit of order lines with a discount above 20% that lost money.
One output row = one summary (result 1), one sub-category (result 2), one entity type (result 3),
one product (result 4).
Steps: find the loss-making deep-discount lines, then see how many products, customers
and orders they are spread across.
*/

-- Result 1: how widely are discounts above 20% used?
SELECT
    COUNT(DISTINCT CASE WHEN DISCOUNT > 0.20 THEN CUSTOMER_ID END) AS CUSTOMERS_WITH_DEEP_DISCOUNT,
    COUNT(DISTINCT CUSTOMER_ID) AS ALL_CUSTOMERS,
    COUNT(DISTINCT CASE WHEN DISCOUNT > 0.20 THEN ORDER_ID END) AS ORDERS_WITH_DEEP_DISCOUNT,
    COUNT(DISTINCT ORDER_ID) AS ALL_ORDERS,
    COUNT(DISTINCT CASE WHEN DISCOUNT > 0.20 THEN PRODUCT_ID END) AS PRODUCTS_WITH_DEEP_DISCOUNT,
    COUNT(DISTINCT PRODUCT_ID) AS ALL_PRODUCTS,
    SUM(CASE WHEN DISCOUNT > 0.20 THEN 1 ELSE 0 END) AS DEEP_DISCOUNT_LINES,
    SUM(CASE WHEN DISCOUNT > 0.20 AND PROFIT < 0 THEN 1 ELSE 0 END) AS DEEP_DISCOUNT_LOSS_LINES
FROM
    dbo.fct_order_line;

-- Result 2: deep-discount losses by sub-category
WITH subcategory_loss AS (
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        COUNT(*) AS LOSS_LINES,
        -1 * SUM(PROFIT) AS LOSS                      -- shown as a positive amount
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT > 0.20
        AND PROFIT < 0
    GROUP BY
        CATEGORY,
        SUB_CATEGORY
)
SELECT
    CATEGORY,
    SUB_CATEGORY,
    LOSS_LINES,
    ROUND(LOSS, 2) AS DEEP_DISCOUNT_LOSS,
    ROUND(100.0 * LOSS / SUM(LOSS) OVER (), 1) AS SHARE_OF_DEEP_DISCOUNT_LOSS_PCT,
    RANK() OVER (ORDER BY LOSS DESC) AS LOSS_RANK
FROM
    subcategory_loss
ORDER BY
    LOSS_RANK;

-- Result 3: how many products, customers and orders make up half / 80% of the loss?
WITH entity_loss AS (
    SELECT
        'Product' AS ENTITY_TYPE,
        PRODUCT_ID AS ENTITY_ID,
        -1 * SUM(PROFIT) AS LOSS
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT > 0.20
        AND PROFIT < 0
    GROUP BY
        PRODUCT_ID

    UNION ALL

    SELECT
        'Customer',
        CUSTOMER_ID,
        -1 * SUM(PROFIT)
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT > 0.20
        AND PROFIT < 0
    GROUP BY
        CUSTOMER_ID

    UNION ALL

    SELECT
        'Order',
        ORDER_ID,
        -1 * SUM(PROFIT)
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT > 0.20
        AND PROFIT < 0
    GROUP BY
        ORDER_ID
),
running AS (
    SELECT
        ENTITY_TYPE,
        ENTITY_ID,
        LOSS,
        -- running total: start with the biggest loss and add one row at a time
        SUM(LOSS) OVER (
            PARTITION BY ENTITY_TYPE
            ORDER BY LOSS DESC, ENTITY_ID
            ROWS UNBOUNDED PRECEDING
        ) AS RUNNING_LOSS,
        SUM(LOSS) OVER (PARTITION BY ENTITY_TYPE) AS TOTAL_LOSS
    FROM
        entity_loss
)
SELECT
    ENTITY_TYPE,
    COUNT(*) AS ENTITIES_WITH_LOSS,
    -- an entity is "needed" if the running total BEFORE it had not yet reached the target
    SUM(CASE WHEN RUNNING_LOSS - LOSS < 0.5 * TOTAL_LOSS THEN 1 ELSE 0 END) AS ENTITIES_FOR_HALF_OF_LOSS,
    SUM(CASE WHEN RUNNING_LOSS - LOSS < 0.8 * TOTAL_LOSS THEN 1 ELSE 0 END) AS ENTITIES_FOR_80PCT_OF_LOSS,
    ROUND(MAX(TOTAL_LOSS), 2) AS TOTAL_DEEP_DISCOUNT_LOSS
FROM
    running
GROUP BY
    ENTITY_TYPE
ORDER BY
    ENTITY_TYPE;

-- Result 4: product-level list with the running share (for the concentration chart)
WITH product_loss AS (
    SELECT
        PRODUCT_ID,
        PRODUCT_NAME,
        SUB_CATEGORY,
        COUNT(*) AS LOSS_LINES,
        -1 * SUM(PROFIT) AS LOSS
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT > 0.20
        AND PROFIT < 0
    GROUP BY
        PRODUCT_ID,
        PRODUCT_NAME,
        SUB_CATEGORY
),
running AS (
    SELECT
        PRODUCT_ID,
        PRODUCT_NAME,
        SUB_CATEGORY,
        LOSS_LINES,
        LOSS,
        ROW_NUMBER() OVER (ORDER BY LOSS DESC, PRODUCT_ID) AS LOSS_RANK,
        SUM(LOSS) OVER (ORDER BY LOSS DESC, PRODUCT_ID ROWS UNBOUNDED PRECEDING) AS RUNNING_LOSS,
        SUM(LOSS) OVER () AS TOTAL_LOSS,
        COUNT(*) OVER () AS PRODUCT_COUNT
    FROM
        product_loss
)
SELECT
    LOSS_RANK,
    PRODUCT_ID,
    PRODUCT_NAME,
    SUB_CATEGORY,
    LOSS_LINES,
    ROUND(LOSS, 2) AS DEEP_DISCOUNT_LOSS,
    ROUND(100.0 * RUNNING_LOSS / TOTAL_LOSS, 1) AS CUMULATIVE_SHARE_OF_LOSS_PCT,
    ROUND(100.0 * LOSS_RANK / PRODUCT_COUNT, 1) AS CUMULATIVE_SHARE_OF_PRODUCTS_PCT
FROM
    running
ORDER BY
    LOSS_RANK;
