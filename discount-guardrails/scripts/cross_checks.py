"""
cross_checks.py
Recalculates key SQL results a second way, with pandas reading the raw CSVs directly
(no SQL, no fact view), then compares them with the query results in /results.
Writes results/validation_log.csv: the 24 SQL checks from 90_tests.sql
(results/validation_sql_checks.csv) plus these 9.

Usage (from the repo root): python scripts/cross_checks.py
"""
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / "results"

orders = pd.read_csv(ROOT / "data" / "ORDERS.csv")
product = pd.read_csv(ROOT / "data" / "PRODUCT.csv").rename(
    columns={"ID": "PRODUCT_ID", "NAME": "CATEGORY", "CATEGORY": "SUB_CATEGORY", "SUBCATEGORY": "PRODUCT_NAME"})
df = orders.merge(product, on="PRODUCT_ID", how="left")
df["ORDER_DATE"] = pd.to_datetime(df["ORDER_DATE"], format="%m/%d/%Y")
df["COST"] = df["SALES"] - df["PROFIT"]


def band(d):
    if d == 0:
        return "1. No Discount"
    if d <= 0.20:
        return "2. Standard (up to 20%)"
    if d <= 0.50:
        return "3. Deep (over 20% to 50%)"
    return "4. Clearance (over 50%)"


df["DISCOUNT_BAND"] = df["DISCOUNT"].map(band)
checks = []


def add(check_id, name, expected, actual, tolerance=0.01):
    ok = abs(expected - actual) <= tolerance
    checks.append({"CHECK_ID": check_id, "CHECK_NAME": name, "CHECK_RULE": f"within {tolerance}",
                   "EXPECTED": round(expected, 2), "ACTUAL": round(actual, 2), "STATUS": "PASS" if ok else "FAIL"})


# V9: scenario model recomputed line by line in plain Python, compared with all 25 SQL scenario rows
sql_scen = pd.read_csv(RES / "q4_scenarios_company.csv")
worst = 0.0
for _, row in sql_scen.iterrows():
    cap, keep = row["MAX_DISCOUNT"], row["VOLUME_RETAINED"]
    total = 0.0
    for sales, disc, profit, cost in zip(df["SALES"], df["DISCOUNT"], df["PROFIT"], df["COST"]):
        if disc > cap + 1e-9:
            total += keep * (sales / (1 - disc) * (1 - cap) - cost)
        else:
            total += profit
    worst = max(worst, abs(total - row["MODELLED_PROFIT"]))
add("V9a", "Scenario model: largest gap between Python and SQL across 25 scenarios ($)", 0.0, worst)

# V10: monitoring procedure returns the right quarters and totals
q6 = pd.read_csv(RES / "proc_last_6_quarters_subcategory.csv")
add("V10a", "Monitoring procedure (@Quarters=6): distinct quarters returned", 6, q6["QUARTER_YEAR"].nunique(), 0)
add("V10b", "Monitoring procedure: newest quarter is Q4-2017 (1 = yes)", 1,
    int(set(q6.loc[q6["QUARTER_RANK"] == 1, "QUARTER_YEAR"]) == {"Q4-2017"}), 0)
last6 = df[df["ORDER_DATE"] >= "2016-07-01"]
add("V10c", "Monitoring procedure: total profit in last 6 quarters vs pandas ($)",
    last6["PROFIT"].sum(), q6["TOTAL_PROFIT"].sum(), 1.0)       # $1 allows for per-row rounding
q4s = pd.read_csv(RES / "proc_last_4_quarters_state.csv")
add("V10d", "Monitoring procedure (@Quarters=4, by state): distinct quarters returned", 4,
    q4s["QUARTER_YEAR"].nunique(), 0)

# V11: band x sub-category table recomputed with pandas
sql_cells = pd.read_csv(RES / "q2_subcategory_band_vs_baseline.csv")
pd_cells = df.groupby(["SUB_CATEGORY", "DISCOUNT_BAND"]).agg(
    LINES=("ROW_ID", "size"), SALES=("SALES", "sum"), PROFIT=("PROFIT", "sum")).reset_index()
merged = sql_cells.merge(pd_cells, on=["SUB_CATEGORY", "DISCOUNT_BAND"], how="outer", indicator=True)
add("V11a", "Band x sub-category cells missing on one side", 0, int((merged["_merge"] != "both").sum()), 0)
add("V11b", "Band x sub-category: largest profit gap SQL vs pandas ($)", 0.0,
    (merged["TOTAL_PROFIT"] - merged["PROFIT"]).abs().max())
add("V11c", "Band x sub-category: largest line-count gap", 0, (merged["LINES_x"] - merged["LINES_y"]).abs().max(), 0)

# V13: the scenario procedure gives the same answer as the scenario grid
proc = pd.read_csv(RES / "proc_ceiling_scenario_20pct_half_volume.csv")
grid = pd.read_csv(RES / "q4_scenarios_subcategory.csv")
grid = grid[(grid["MAX_DISCOUNT"] == 0.20) & (grid["VOLUME_RETAINED"] == 0.50)]
both = proc.merge(grid, on="SUB_CATEGORY", suffixes=("_proc", "_grid"))
add("V13", "Scenario procedure (20%, 0.50) vs scenario grid: largest profit gap ($)", 0.0,
    (both["MODELLED_PROFIT_proc"] - both["MODELLED_PROFIT_grid"]).abs().max())

indep = pd.DataFrame(checks)
indep.insert(2, "METHOD", "pandas recompute (cross_checks.py)")

sql_checks = pd.read_csv(RES / "validation_sql_checks.csv")
sql_checks.insert(2, "METHOD", "SQL (90_tests.sql)")
log = pd.concat([sql_checks, indep], ignore_index=True)
log.to_csv(RES / "validation_log.csv", index=False)
print(log.to_string(index=False))
print("\nFAILED:", int((log["STATUS"] != "PASS").sum()), "of", len(log))
