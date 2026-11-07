# Query results

One CSV per SQL result set. The README, the report and the charts all take their numbers from these files.

| File | Produced by | Rows |
|---|---|---:|
| [q1_band_summary.csv](q1_band_summary.csv) | [10_q1_where_discounts_lose_money.sql](../sql/2_analysis/10_q1_where_discounts_lose_money.sql) | 4 |
| [q1_discount_level_summary.csv](q1_discount_level_summary.csv) | [10_q1_where_discounts_lose_money.sql](../sql/2_analysis/10_q1_where_discounts_lose_money.sql) | 12 |
| [q1_category_band.csv](q1_category_band.csv) | [10_q1_where_discounts_lose_money.sql](../sql/2_analysis/10_q1_where_discounts_lose_money.sql) | 11 |
| [q2_subcategory_band_vs_baseline.csv](q2_subcategory_band_vs_baseline.csv) | [11_q2_discount_or_product.sql](../sql/2_analysis/11_q2_discount_or_product.sql) | 45 |
| [q2_subcategory_breakeven.csv](q2_subcategory_breakeven.csv) | [11_q2_discount_or_product.sql](../sql/2_analysis/11_q2_discount_or_product.sql) | 17 |
| [q2_subcategory_discount_detail.csv](q2_subcategory_discount_detail.csv) | [11_q2_discount_or_product.sql](../sql/2_analysis/11_q2_discount_or_product.sql) | 57 |
| [q2_mix_vs_discount_effect.csv](q2_mix_vs_discount_effect.csv) | [11_q2_discount_or_product.sql](../sql/2_analysis/11_q2_discount_or_product.sql) | 4 |
| [q3_reach.csv](q3_reach.csv) | [12_q3_concentration.sql](../sql/2_analysis/12_q3_concentration.sql) | 1 |
| [q3_loss_by_subcategory.csv](q3_loss_by_subcategory.csv) | [12_q3_concentration.sql](../sql/2_analysis/12_q3_concentration.sql) | 8 |
| [q3_loss_concentration_summary.csv](q3_loss_concentration_summary.csv) | [12_q3_concentration.sql](../sql/2_analysis/12_q3_concentration.sql) | 3 |
| [q3_product_loss_pareto.csv](q3_product_loss_pareto.csv) | [12_q3_concentration.sql](../sql/2_analysis/12_q3_concentration.sql) | 618 |
| [q4_scenarios_company.csv](q4_scenarios_company.csv) | [13_q4_ceiling_scenarios.sql](../sql/2_analysis/13_q4_ceiling_scenarios.sql) | 25 |
| [q4_scenarios_subcategory.csv](q4_scenarios_subcategory.csv) | [13_q4_ceiling_scenarios.sql](../sql/2_analysis/13_q4_ceiling_scenarios.sql) | 425 |
| [q4_best_ceiling_by_subcategory.csv](q4_best_ceiling_by_subcategory.csv) | [13_q4_ceiling_scenarios.sql](../sql/2_analysis/13_q4_ceiling_scenarios.sql) | 51 |
| [q4_whole_order_loss_case.csv](q4_whole_order_loss_case.csv) | [13_q4_ceiling_scenarios.sql](../sql/2_analysis/13_q4_ceiling_scenarios.sql) | 1 |
| [q4_customer_risk_case.csv](q4_customer_risk_case.csv) | [13_q4_ceiling_scenarios.sql](../sql/2_analysis/13_q4_ceiling_scenarios.sql) | 1 |
| [q5_year_band.csv](q5_year_band.csv) | [14_q5_stability.sql](../sql/2_analysis/14_q5_stability.sql) | 16 |
| [q5_segment_band.csv](q5_segment_band.csv) | [14_q5_stability.sql](../sql/2_analysis/14_q5_stability.sql) | 12 |
| [q5_region_band.csv](q5_region_band.csv) | [14_q5_stability.sql](../sql/2_analysis/14_q5_stability.sql) | 16 |
| [proc_ceiling_scenario_20pct_half_volume.csv](proc_ceiling_scenario_20pct_half_volume.csv) | [20_scenario_procedure.sql](../sql/3_procedures/20_scenario_procedure.sql) | 17 |
| [proc_last_6_quarters_subcategory.csv](proc_last_6_quarters_subcategory.csv) | [30_monitoring_procedure.sql](../sql/3_procedures/30_monitoring_procedure.sql) | 102 |
| [proc_last_4_quarters_state.csv](proc_last_4_quarters_state.csv) | [30_monitoring_procedure.sql](../sql/3_procedures/30_monitoring_procedure.sql) | 145 |

| [validation_sql_checks.csv](validation_sql_checks.csv) | [90_tests.sql](../sql/4_tests/90_tests.sql) | 24 |
| [validation_log.csv](validation_log.csv) | 90_tests.sql + [cross_checks.py](../scripts/cross_checks.py) | 33 |
