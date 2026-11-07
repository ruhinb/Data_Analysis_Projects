# Validation

[`results/validation_log.csv`](../results/validation_log.csv) lists every check, how it was run, what was expected, what came back, and PASS/FAIL. Current result: **33 of 33 pass**.

| Checks | Method | What they prove |
|---|---|---|
| V1–V8, V12 | `sql/4_tests/90_tests.sql` (SQL) | The load is complete; keys are unique and all match; the fact view neither adds nor loses rows; totals reconcile to the cent; dates were read in month/day order; every line has one band; the scenario formula behaves correctly at its edges; the one possible duplicate does not matter |
| V9a | `scripts/cross_checks.py` (pandas) | All 25 company-level scenarios recalculated line by line in plain Python match the SQL to \$0.01 |
| V10a–d | `scripts/cross_checks.py` | The monitoring procedure returns exactly 6 (or 4) quarters, newest first, and its totals match a direct calculation |
| V11a–c | `scripts/cross_checks.py` | The band × sub-category table rebuilt from the raw CSVs matches the SQL (cells, line counts, profit) |
| V13 | `scripts/cross_checks.py` | The scenario stored procedure gives the same answer as the scenario grid query |

V10c allows a \$1 tolerance because the procedure rounds each row to cents before the rows are added up.

## Worked examples of the scenario formula (20% ceiling, all volume kept)

| ROW_ID | Sub-category | Sales | Discount | Profit | List price sales = Sales / (1 − d) | Implied cost = Sales − Profit | Re-priced sales = List × 0.80 | Re-priced profit |
|---:|---|---:|---:|---:|---:|---:|---:|---:|
| 7773 | Machines | \$4,499.99 | 70% | −\$6,599.98 | \$14,999.95 | \$11,099.96 | \$11,999.96 | **+\$900.00** |
| 9775 | Binders | \$2,177.58 | 80% | −\$3,701.89 | \$10,887.92 | \$5,879.48 | \$8,710.34 | **+\$2,830.86** |
| 9640 | Tables | \$4,297.64 | 40% | −\$1,862.31 | \$7,162.74 | \$6,159.96 | \$5,730.19 | **−\$429.76** |

The Tables line still loses money at 20%, which is why Tables also needs a pricing review.
