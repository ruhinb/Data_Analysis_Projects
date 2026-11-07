/*
30_monitoring_procedure.sql
Quarterly monitoring for the discount policy (my version of exercise Q7, without dynamic SQL).
One output row = one sub-category (or state) + one quarter.
Steps: total each group per quarter, number the quarters newest first with DENSE_RANK,
keep the latest @Quarters. Because the quarters are found from the data, new quarters are
picked up automatically. Turning quarters into columns is done in Excel or Power BI.
Parameters:
    @Quarters     how many of the latest quarters to return (default 6)
    @GroupBy      'SUB_CATEGORY' (default) or 'STATE'
    @MaxDiscount  the policy ceiling to monitor against (default 0.20)
*/

CREATE OR ALTER PROCEDURE dbo.usp_LastQuartersSummary
    @Quarters INT = 6,
    @GroupBy VARCHAR(20) = 'SUB_CATEGORY',
    @MaxDiscount DECIMAL(5,2) = 0.20
AS
BEGIN
    WITH quarter_totals AS (
        SELECT
            CASE WHEN @GroupBy = 'STATE' THEN STATE ELSE SUB_CATEGORY END AS GROUP_NAME,
            ORDER_YEAR,
            ORDER_QUARTER,
            QUARTER_YEAR,
            SUM(SALES) AS SALES,
            SUM(PROFIT) AS PROFIT,
            SUM(CASE WHEN DISCOUNT > @MaxDiscount THEN SALES ELSE 0 END) AS SALES_ABOVE_MAX_DISCOUNT
        FROM
            dbo.fct_order_line
        GROUP BY
            CASE WHEN @GroupBy = 'STATE' THEN STATE ELSE SUB_CATEGORY END,
            ORDER_YEAR,
            ORDER_QUARTER,
            QUARTER_YEAR
    ),
    ranked AS (
        SELECT
            GROUP_NAME,
            QUARTER_YEAR,
            SALES,
            PROFIT,
            SALES_ABOVE_MAX_DISCOUNT,
            -- DENSE_RANK gives every row in the same quarter the same number,
            -- newest quarter = 1, with no gaps, so "<= 6" means the latest 6 quarters
            DENSE_RANK() OVER (ORDER BY ORDER_YEAR DESC, ORDER_QUARTER DESC) AS QUARTER_RANK
        FROM
            quarter_totals
    )
    SELECT
        GROUP_NAME,
        QUARTER_YEAR,
        QUARTER_RANK,
        ROUND(SALES, 2) AS TOTAL_SALES,
        ROUND(PROFIT, 2) AS TOTAL_PROFIT,
        ROUND(100.0 * PROFIT / SALES, 1) AS MARGIN_PCT,
        ROUND(100.0 * SALES_ABOVE_MAX_DISCOUNT / SALES, 1) AS PCT_SALES_ABOVE_MAX_DISCOUNT
    FROM
        ranked
    WHERE
        QUARTER_RANK <= @Quarters
    ORDER BY
        GROUP_NAME,
        QUARTER_RANK;
END;
GO

-- test 1: latest 6 quarters by sub-category
EXEC dbo.usp_LastQuartersSummary
    @Quarters = 6,
    @GroupBy = 'SUB_CATEGORY';
GO

-- test 2: latest 4 quarters by state
EXEC dbo.usp_LastQuartersSummary
    @Quarters = 4,
    @GroupBy = 'STATE';
