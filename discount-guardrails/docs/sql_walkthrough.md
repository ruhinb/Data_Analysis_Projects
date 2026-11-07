# SQL walkthrough

A plain-English tour of each script, plus the questions I had to answer for myself along the way. Most of the SQL uses the same patterns as my earlier SQL Server exercises. Three things were new to me on this project, and I've flagged them below: views, running totals and DENSE_RANK.

## 01_fact_view.sql: the starting point

This view joins ORDERS to PRODUCT and CUSTOMER, renames the mislabelled product columns, and adds `QUARTER_YEAR`, `DISCOUNT_BAND` and `IMPLIED_COST`.

`CREATE OR ALTER VIEW` was new to me. A view is a saved SELECT that other scripts can query like a table. That way the joins and the band rule only live in one place, and if I change the band rule, every script picks it up.

The bands have number prefixes (`1. No Discount`) so that `ORDER BY DISCOUNT_BAND` sorts them in order instead of alphabetically.

The order of the CASE branches matters. `DISCOUNT = 0` is tested first, so `<= 0.20` only catches discounts above 0 and up to 0.20.

> *How do I know the joins didn't duplicate rows?* PRODUCT.ID and CUSTOMER.ID are primary keys, so each order line can match at most one row. Check V4 confirms the view has 9,994 rows, the same as ORDERS, and V5 confirms sales and profit totals didn't change.

## 10_q1: where discounts lose money

Each result is a CTE that groups and totals, followed by a SELECT that works out the ratios. I only ROUND at the very end.

`SUM(CASE WHEN PROFIT < 0 THEN 1 ELSE 0 END)` counts the loss-making lines.

`SUM(SALES) OVER ()` is the grand total across all rows, which I need for "share of sales". It's the same idea as `SUM() OVER (PARTITION BY …)`, just without a partition.

I multiply by `100.0` before dividing to avoid integer division. In SQL Server, `5 / 10` is 0.

> *Why SUM(profit)/SUM(sales) and not the average of each line's margin?* An average would give a \$2 line the same weight as a \$2,000 line. A ratio of totals gives the real margin.

## 11_q2: discount or product?

The `no_discount` CTE gets each sub-category's margin at 0% discount. Joining it back to every band lets me compare each band with its own products at full price.

Result 2 uses `MAX(CASE WHEN PROFIT > 0 AND LINES >= 20 THEN DISCOUNT END)` to find the highest discount that still made a profit in each sub-category. I ignore levels with fewer than 20 lines because they're too small to trust.

Result 4 splits each band's margin gap into two parts. The mix effect is the part caused by which products are in the band. The discount effect is whatever is left once the products are allowed for.

`CROSS JOIN company_no_discount` adds a one-row table (the company-wide baseline) to every row.

> *Couldn't the losses just come from bad products?* That's what result 4 tests. Products in the Deep band would earn 26.6% at no discount, close to the company's 29.5%, so mix explains only about 3 of the 49 points.

## 12_q3: concentration

`COUNT(DISTINCT CASE WHEN DISCOUNT > 0.20 THEN CUSTOMER_ID END)` counts the customers who got at least one deep discount. The CASE returns NULL for everything else, and COUNT skips NULLs.

Result 3 stacks products, customers and orders with UNION ALL, so one query covers all three.

The running total was new to me. `SUM(LOSS) OVER (PARTITION BY ENTITY_TYPE ORDER BY LOSS DESC, ENTITY_ID ROWS UNBOUNDED PRECEDING)` adds up the losses from biggest to smallest. `ENTITY_ID` in the ORDER BY breaks ties, so the result is the same every time.

To count how many products make up 50% of the loss, I count the rows where the running total before that row (`RUNNING_LOSS - LOSS`) was still under 50%.

## 13_q4 and 20_scenario_procedure: the cap model

`ceilings` and `volume` are small lists built with `SELECT … UNION ALL SELECT …`. `CROSS JOIN` pairs every order line with every cap and every volume assumption.

The CASE does the re-pricing. If a line's discount is above the cap, it undoes the discount (`SALES / (1 - DISCOUNT)`), applies the cap (`* (1 - MAX_DISCOUNT)`), takes off the implied cost, and multiplies by the share of volume kept. Lines at or below the cap stay as they were.

Result 3 uses `ROW_NUMBER() OVER (PARTITION BY SUB_CATEGORY, VOLUME_RETAINED ORDER BY profit DESC)` to pick the best cap for each sub-category. It's the same pattern I used with RANK in exercise Q3.

`usp_CeilingScenario` is the same formula as a stored procedure, with `@MaxDiscount` and `@VolumeRetained` as parameters. I built it the same way as my exercise Q6 procedure.

> *Is +\$177k a real saving?* No. It's a model of past orders. It assumes costs stay the same and that a chosen share of customers keep buying. All it shows is that a 20% cap is worth testing. A pilot would measure the real effect.

## 30_monitoring_procedure.sql: the last N quarters

DENSE_RANK was new to me. `DENSE_RANK() OVER (ORDER BY ORDER_YEAR DESC, ORDER_QUARTER DESC)` gives every row in the newest quarter a 1, the next quarter a 2, and so on, with no gaps. `WHERE QUARTER_RANK <= @Quarters` then keeps the latest N.

Because the quarters come from the data and not from dates typed into the query, the procedure keeps working when new orders arrive.

`CASE WHEN @GroupBy = 'STATE' THEN STATE ELSE SUB_CATEGORY END` lets one procedure group by either column without dynamic SQL.

> *Why not PIVOT the quarters into columns?* The column names would change every quarter, which means dynamic SQL. Returning rows and pivoting in Excel or Power BI is simpler to maintain.

## 90_tests.sql: validation

Every check returns the same columns (`CHECK_ID, CHECK_NAME, CHECK_RULE, EXPECTED, ACTUAL`), stacked with UNION ALL. The final SELECT uses CASE to mark each one PASS or FAIL.

V8 tests the edge cases of the what-if formula:

- a cap of 80% changes nothing, because 80% is the highest discount in the data;
- keeping 0% of volume gives the same answer as deleting the capped lines;
- re-pricing a line at its own discount gives back its original profit.
