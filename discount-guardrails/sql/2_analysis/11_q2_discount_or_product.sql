/*
11_q2_discount_or_product.sql
Q2. Is it the discount, or the products that get discounted?
One output row = one sub-category + band (result 1), one sub-category (result 2),
one sub-category + discount level (result 3), one band (result 4).
Steps: compare each band's margin with the SAME sub-category's no-discount margin,
so that cheap-to-discount and expensive-to-discount products are not mixed up.
*/

-- Result 1: margin in each band compared with the sub-category's own no-discount margin
WITH cell_totals AS (
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        DISCOUNT_BAND,
        COUNT(*) AS LINES,
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        CATEGORY,
        SUB_CATEGORY,
        DISCOUNT_BAND
),
no_discount AS (
    SELECT
        SUB_CATEGORY,
        PROFIT / SALES AS BASE_MARGIN
    FROM
        cell_totals
    WHERE
        DISCOUNT_BAND = '1. No Discount'
)
SELECT
    cells.CATEGORY,
    cells.SUB_CATEGORY,
    cells.DISCOUNT_BAND,
    cells.LINES,
    ROUND(cells.SALES, 2) AS TOTAL_SALES,
    ROUND(cells.PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * cells.PROFIT / cells.SALES, 1) AS MARGIN_PCT,
    ROUND(100.0 * base.BASE_MARGIN, 1) AS NO_DISCOUNT_MARGIN_PCT,
    ROUND(100.0 * (cells.PROFIT / cells.SALES - base.BASE_MARGIN), 1) AS GAP_PP,   -- percentage points
    CASE WHEN cells.LINES < 20 THEN 'Small sample (<20 lines)' ELSE '' END AS SAMPLE_NOTE
FROM
    cell_totals AS cells
INNER JOIN no_discount AS base ON cells.SUB_CATEGORY = base.SUB_CATEGORY
ORDER BY
    cells.CATEGORY,
    cells.SUB_CATEGORY,
    cells.DISCOUNT_BAND;

-- Result 2: for each sub-category, the highest discount level that still made a profit
-- and the lowest level that lost money (only levels with at least 20 lines count)
WITH level_totals AS (
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        DISCOUNT,
        COUNT(*) AS LINES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        CATEGORY,
        SUB_CATEGORY,
        DISCOUNT
)
SELECT
    CATEGORY,
    SUB_CATEGORY,
    MAX(CASE WHEN PROFIT > 0 AND LINES >= 20 THEN DISCOUNT END) AS HIGHEST_PROFITABLE_DISCOUNT,
    MIN(CASE WHEN PROFIT < 0 AND LINES >= 20 THEN DISCOUNT END) AS LOWEST_LOSS_MAKING_DISCOUNT,
    MAX(DISCOUNT) AS MAX_DISCOUNT_GIVEN
FROM
    level_totals
GROUP BY
    CATEGORY,
    SUB_CATEGORY
ORDER BY
    CATEGORY,
    SUB_CATEGORY;

-- Result 3: full detail, sub-category by actual discount level (appendix table)
SELECT
    CATEGORY,
    SUB_CATEGORY,
    DISCOUNT,
    COUNT(*) AS LINES,
    ROUND(SUM(SALES), 2) AS TOTAL_SALES,
    ROUND(SUM(PROFIT), 2) AS TOTAL_PROFIT,
    ROUND(100.0 * SUM(PROFIT) / SUM(SALES), 1) AS MARGIN_PCT
FROM
    dbo.fct_order_line
GROUP BY
    CATEGORY,
    SUB_CATEGORY,
    DISCOUNT
ORDER BY
    CATEGORY,
    SUB_CATEGORY,
    DISCOUNT;

-- Result 4: how much of each band's margin gap is product mix, and how much is the discount
--   COMPANY_NO_DISCOUNT_MARGIN  = margin of all 0% lines, whatever they are
--   SAME_MIX_NO_DISCOUNT_MARGIN = margin the band WOULD have if each sub-category earned its own 0% margin
--   MIX_EFFECT_PP      = SAME_MIX - COMPANY      (the products in this band are naturally better/worse)
--   DISCOUNT_EFFECT_PP = ACTUAL   - SAME_MIX     (the gap that remains after allowing for the products)
WITH cell_totals AS (
    SELECT
        SUB_CATEGORY,
        DISCOUNT_BAND,
        SUM(SALES) AS SALES,
        SUM(PROFIT) AS PROFIT
    FROM
        dbo.fct_order_line
    GROUP BY
        SUB_CATEGORY,
        DISCOUNT_BAND
),
no_discount AS (
    SELECT
        SUB_CATEGORY,
        PROFIT / SALES AS BASE_MARGIN
    FROM
        cell_totals
    WHERE
        DISCOUNT_BAND = '1. No Discount'
),
company_no_discount AS (
    SELECT
        SUM(PROFIT) / SUM(SALES) AS COMPANY_BASE_MARGIN
    FROM
        dbo.fct_order_line
    WHERE
        DISCOUNT = 0
),
band_view AS (
    SELECT
        cells.DISCOUNT_BAND,
        SUM(cells.SALES) AS SALES,
        SUM(cells.PROFIT) AS PROFIT,
        SUM(cells.SALES * base.BASE_MARGIN) AS PROFIT_AT_OWN_BASE_MARGIN,
        company.COMPANY_BASE_MARGIN
    FROM
        cell_totals AS cells
    INNER JOIN no_discount AS base ON cells.SUB_CATEGORY = base.SUB_CATEGORY
    CROSS JOIN company_no_discount AS company     -- company_no_discount has one row, so every row gets it
    GROUP BY
        cells.DISCOUNT_BAND,
        company.COMPANY_BASE_MARGIN
)
SELECT
    DISCOUNT_BAND,
    ROUND(SALES, 2) AS TOTAL_SALES,
    ROUND(PROFIT, 2) AS TOTAL_PROFIT,
    ROUND(100.0 * PROFIT / SALES, 1) AS ACTUAL_MARGIN_PCT,
    ROUND(100.0 * PROFIT_AT_OWN_BASE_MARGIN / SALES, 1) AS SAME_MIX_NO_DISCOUNT_MARGIN_PCT,
    ROUND(100.0 * COMPANY_BASE_MARGIN, 1) AS COMPANY_NO_DISCOUNT_MARGIN_PCT,
    ROUND(100.0 * (PROFIT_AT_OWN_BASE_MARGIN / SALES - COMPANY_BASE_MARGIN), 1) AS MIX_EFFECT_PP,
    ROUND(100.0 * (PROFIT - PROFIT_AT_OWN_BASE_MARGIN) / SALES, 1) AS DISCOUNT_EFFECT_PP
FROM
    band_view
ORDER BY
    DISCOUNT_BAND;
