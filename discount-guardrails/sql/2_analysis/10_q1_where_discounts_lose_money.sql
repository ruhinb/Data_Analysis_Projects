/*
10_q1_where_discounts_lose_money.sql
Q1. Where is discounting coinciding with losses?
One output row = one discount band (result 1), one discount level (result 2),
one category + band (result 3).
Steps: total each group in a CTE, then work out margin, loss-line rate and share of sales.
*/

-- Result 1: profitability by discount band
WITH band_totals AS (
    SELECT
        DISCOUNT_BAND,
        COUNT(*) AS LINES,
        SUM(CASE WHEN PROFIT < 0 THEN 1 ELSE 0 END) AS LOSS_LINES,   -- counts only loss-making lines
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        DISCOUNT_BAND
)
SELECT
    DISCOUNT_BAND,
    LINES,
    ROUND(SALES, 2) AS TOTAL_SALES,
    ROUND(PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * PROFIT / SALES, 1) AS MARGIN_PCT,
    ROUND(100.0 * LOSS_LINES / LINES, 1) AS LOSS_LINE_PCT,
    ROUND(100.0 * SALES / SUM(SALES) OVER (), 1) AS SHARE_OF_SALES_PCT   -- OVER () = across all rows
FROM
    band_totals
ORDER BY
    DISCOUNT_BAND;

-- Result 2: the same, for each of the 12 actual discount levels
WITH level_totals AS (
    SELECT
        DISCOUNT,
        COUNT(*) AS LINES,
        SUM(CASE WHEN PROFIT < 0 THEN 1 ELSE 0 END) AS LOSS_LINES,
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        DISCOUNT
)
SELECT
    DISCOUNT,
    LINES,
    ROUND(SALES, 2) AS TOTAL_SALES,
    ROUND(PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * PROFIT / SALES, 1) AS MARGIN_PCT,
    ROUND(100.0 * LOSS_LINES / LINES, 1) AS LOSS_LINE_PCT
FROM
    level_totals
ORDER BY
    DISCOUNT;

-- Result 3: category by discount band
WITH category_band_totals AS (
    SELECT
        CATEGORY,
        DISCOUNT_BAND,
        COUNT(*) AS LINES,
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        CATEGORY,
        DISCOUNT_BAND
)
SELECT
    CATEGORY,
    DISCOUNT_BAND,
    LINES,
    ROUND(SALES, 2) AS TOTAL_SALES,
    ROUND(PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * PROFIT / SALES, 1) AS MARGIN_PCT,
    ROUND(100.0 * SALES / SUM(SALES) OVER (PARTITION BY CATEGORY), 1) AS SHARE_OF_CATEGORY_SALES_PCT
FROM
    category_band_totals
ORDER BY
    CATEGORY,
    DISCOUNT_BAND;
