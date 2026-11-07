/*
14_q5_stability.sql
Q5. Is the pattern stable over time and across customer segments and regions?
One output row = one year + band (result 1), one segment + band (result 2), one region + band (result 3).
Steps: same band totals as Q1, split by year, segment and region. Region and state are the
customer's listed location, not where the order was delivered.
*/

-- Result 1: by year
WITH year_band AS (
    SELECT
        ORDER_YEAR,
        DISCOUNT_BAND,
        COUNT(*) AS LINES,
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        ORDER_YEAR,
        DISCOUNT_BAND
)
SELECT
    ORDER_YEAR,
    DISCOUNT_BAND,
    LINES,
    ROUND(SALES, 2) AS TOTAL_SALES,
    ROUND(PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * PROFIT / SALES, 1) AS MARGIN_PCT,
    ROUND(100.0 * SALES / SUM(SALES) OVER (PARTITION BY ORDER_YEAR), 1) AS SHARE_OF_YEAR_SALES_PCT
FROM
    year_band
ORDER BY
    ORDER_YEAR,
    DISCOUNT_BAND;

-- Result 2: by customer segment
WITH segment_band AS (
    SELECT
        SEGMENT,
        DISCOUNT_BAND,
        COUNT(*) AS LINES,
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        SEGMENT,
        DISCOUNT_BAND
)
SELECT
    SEGMENT,
    DISCOUNT_BAND,
    LINES,
    ROUND(SALES, 2) AS TOTAL_SALES,
    ROUND(PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * PROFIT / SALES, 1) AS MARGIN_PCT,
    ROUND(100.0 * SALES / SUM(SALES) OVER (PARTITION BY SEGMENT), 1) AS SHARE_OF_SEGMENT_SALES_PCT
FROM
    segment_band
ORDER BY
    SEGMENT,
    DISCOUNT_BAND;

-- Result 3: by customer region
WITH region_band AS (
    SELECT
        REGION,
        DISCOUNT_BAND,
        COUNT(*) AS LINES,
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        REGION,
        DISCOUNT_BAND
)
SELECT
    REGION,
    DISCOUNT_BAND,
    LINES,
    ROUND(SALES, 2) AS TOTAL_SALES,
    ROUND(PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * PROFIT / SALES, 1) AS MARGIN_PCT,
    ROUND(100.0 * SALES / SUM(SALES) OVER (PARTITION BY REGION), 1) AS SHARE_OF_REGION_SALES_PCT
FROM
    region_band
ORDER BY
    REGION,
    DISCOUNT_BAND;
