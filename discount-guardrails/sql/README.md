# SQL scripts (T-SQL, SQL Server 2022)

Run the folders in order, and the files inside each folder in number order. Each script starts with a comment block that gives the question it answers and what one output row means.

| Step | Script | What it does | Output |
|---|---|---|---|
| 1. Setup | [00_load.sql](1_setup/00_load.sql) | Creates the four raw tables and loads the CSVs with `BULK INSERT` | Row counts (793 / 9 / 1,862 / 9,994) |
| | [01_fact_view.sql](1_setup/01_fact_view.sql) | Creates `dbo.fct_order_line`: one row per order line, with clean product columns, quarter, discount band and implied cost | The view every analysis reads from |
| 2. Analysis | [10_q1_where_discounts_lose_money.sql](2_analysis/10_q1_where_discounts_lose_money.sql) | **Q1:** profit and margin by discount band, discount level and category | `results/q1_*.csv` |
| | [11_q2_discount_or_product.sql](2_analysis/11_q2_discount_or_product.sql) | **Q2:** compares each band with the same sub-categories at full price, to separate the discount from the product mix | `results/q2_*.csv` |
| | [12_q3_concentration.sql](2_analysis/12_q3_concentration.sql) | **Q3:** how many customers get heavy discounts, and which sub-categories and products cause the loss | `results/q3_*.csv` |
| | [13_q4_ceiling_scenarios.sql](2_analysis/13_q4_ceiling_scenarios.sql) | **Q4 (modelled):** re-prices past orders at 20–50% ceilings under different assumptions about lost volume | `results/q4_*.csv` |
| | [14_q5_stability.sql](2_analysis/14_q5_stability.sql) | **Q5:** checks the pattern by year, customer segment and region | `results/q5_*.csv` |
| 3. Procedures | [20_scenario_procedure.sql](3_procedures/20_scenario_procedure.sql) | `usp_CeilingScenario`: the Q4 model for any ceiling and volume assumption | `results/proc_ceiling_*.csv` |
| | [30_monitoring_procedure.sql](3_procedures/30_monitoring_procedure.sql) | `usp_LastQuartersSummary`: quarterly check of heavy discounting by sub-category or state | `results/proc_last_*.csv` |
| 4. Tests | [90_tests.sql](4_tests/90_tests.sql) | 24 validation checks, each returning PASS or FAIL | Every row should say PASS |

**Concepts used:** joins, views, `CASE`, CTEs, window functions (`SUM() OVER`, `DENSE_RANK`), stored procedures with parameters, `UNION ALL` test tables.
