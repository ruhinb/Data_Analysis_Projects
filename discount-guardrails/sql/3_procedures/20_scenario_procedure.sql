/*
20_scenario_procedure.sql
A reusable version of the Q4 model: pick ONE ceiling and ONE volume assumption,
get the result for every sub-category. Same maths as 13_q4_ceiling_scenarios.sql.
One output row = one sub-category.
Parameters:
    @MaxDiscount     the discount ceiling, e.g. 0.20
    @VolumeRetained  share of capped lines still bought at the smaller discount (0 to 1)
MODEL, NOT A RESULT: the volume a customer keeps is an assumption, not something in the data.
*/

CREATE OR ALTER PROCEDURE dbo.usp_CeilingScenario
    @MaxDiscount DECIMAL(5,2),
    @VolumeRetained DECIMAL(5,2) = 0.50
AS
BEGIN
    WITH line_scenarios AS (
        SELECT
            CATEGORY,
            SUB_CATEGORY,
            SALES,
            PROFIT,
            CASE WHEN DISCOUNT > @MaxDiscount THEN 1 ELSE 0 END AS IS_CAPPED,
            CASE
                WHEN DISCOUNT > @MaxDiscount
                    THEN @VolumeRetained * (SALES / (1 - DISCOUNT) * (1 - @MaxDiscount))
                ELSE SALES
            END AS MODELLED_SALES,
            CASE
                WHEN DISCOUNT > @MaxDiscount
                    THEN @VolumeRetained * (SALES / (1 - DISCOUNT) * (1 - @MaxDiscount) - IMPLIED_COST)
                ELSE PROFIT
            END AS MODELLED_PROFIT
        FROM
            dbo.fct_order_line
    )
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        SUM(IS_CAPPED) AS CAPPED_LINES,
        ROUND(SUM(SALES), 2) AS OBSERVED_SALES,
        ROUND(SUM(MODELLED_SALES), 2) AS MODELLED_SALES,
        ROUND(SUM(PROFIT), 2) AS OBSERVED_PROFIT,
        ROUND(SUM(MODELLED_PROFIT), 2) AS MODELLED_PROFIT,
        ROUND(SUM(MODELLED_PROFIT) - SUM(PROFIT), 2) AS PROFIT_CHANGE
    FROM
        line_scenarios
    GROUP BY
        CATEGORY,
        SUB_CATEGORY
    ORDER BY
        PROFIT_CHANGE DESC;
END;
GO

-- test: cap at 20%, half the capped volume kept
EXEC dbo.usp_CeilingScenario
    @MaxDiscount = 0.20,
    @VolumeRetained = 0.50;
