# Data dictionary

Semantic model tables, built in Power Query from `data/data_pizza.csv` and the roster data. Hidden columns are keys or facts that report authors reach through measures.

## Sales

Fact: one row per order line (order x pizza). Grain matches the raw file; descriptive attributes moved to Pizza.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Order ID | int64 | yes |  | Degenerate dimension: order number. |
| Order Date | dateTime | yes |  | Foreign key to Date. |
| Slot Key | int64 | yes |  | Foreign key to Time Slot (minutes after midnight, rounded down to the half-hour). |
| Pizza Key | int64 | yes |  | Foreign key to Pizza. |
| Quantity | int64 | yes |  |  |
| Unit Price | decimal | yes |  |  |
| Line Revenue | decimal | yes |  | Quantity x unit price. |
| Order Pizza Count | int64 | yes |  | Pizzas in the whole order; used to classify single-pizza orders. |

## Orders

Fact: one row per order (header). Holds order-level timing such as the gap to the previous order.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Order ID (key) | int64 | yes |  |  |
| Order Date | dateTime | yes |  | Foreign key to Date. |
| Order Time | dateTime | yes |  |  |
| Slot Key | int64 | yes |  | Foreign key to Time Slot. |
| Order Lines | int64 | yes |  |  |
| Order Pizzas | int64 | yes |  |  |
| Order Revenue | decimal | yes |  |  |
| Minutes Since Previous Order | double | yes |  | Minutes since the previous order on the same day; blank for the first order of the day. |
| Order Type | string |  |  | Single pizza or Multiple pizzas. |

## Staffing

Fact: one row per trading day x half-hour (9:30 AM - 11:00 PM). Demand comes from Sales; recommended roster follows set rules.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Date | dateTime | yes |  | Foreign key to Date. |
| Slot Key | int64 | yes |  | Foreign key to Time Slot. |
| Demand Band | string |  | Demand Band Sort | Orders in the half-hour: No orders, Low (1-2), Moderate (3-4), High (5+). |
| Demand Band Sort | int64 | yes |  |  |
| Slot Orders | int64 | yes |  |  |
| Slot Pizzas | int64 | yes |  |  |
| Slot Revenue | decimal | yes |  |  |
| Shift Managers | int64 | yes |  |  |
| Kitchen Crew | int64 | yes |  |  |
| Service Crew | int64 | yes |  |  |
| Prep Utility | int64 | yes |  |  |
| Scheduled Staff | int64 | yes |  |  |
| Scheduled Labour Hours | double | yes |  |  |
| Scheduled Labour Cost | decimal | yes |  |  |
| Recommended Kitchen | int64 | yes |  |  |
| Recommended Service | int64 | yes |  |  |
| Recommended Prep | int64 | yes |  |  |
| Recommended Staff | int64 | yes |  |  |
| Recommended Labour Hours | double | yes |  |  |
| Recommended Labour Cost | decimal | yes |  |  |
| Staffing Gap | int64 | yes |  | Scheduled minus recommended people. |

## Date

Dimension: continuous calendar for every year in the sales data, with trading-day flags and weekday-adjusted anomaly scores.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Date (key) | dateTime |  |  |  |
| Year | int64 |  |  |  |
| Quarter | string |  |  |  |
| Month Number | int64 | yes |  |  |
| Month | string |  | Month Number | Three-letter month (Jan). |
| Month Name | string |  | Month Number |  |
| Month Year | string |  | Month Index |  |
| Month Index | int64 | yes |  | Year x 12 + month; used for period comparisons. |
| Week Start | dateTime |  |  | Monday of the week. |
| Day of Week Number | int64 | yes |  | 1 = Monday ... 7 = Sunday. |
| Weekday | string |  | Day of Week Number | Three-letter weekday (Mon). |
| Weekday Name | string |  | Day of Week Number |  |
| Day Type | string |  |  | Weekday or Weekend (Saturday, Sunday). |
| Typical Weekday Revenue | decimal | yes |  | Mean revenue of the same weekday, excluding this date (leave-one-out). |
| Typical Weekday Orders | double | yes |  |  |
| Typical Weekday Pizzas | double | yes |  |  |
| Revenue Z-Score | double | yes |  | (Revenue - typical) / standard deviation of the same weekday, excluding this date. |
| Orders Z-Score | double | yes |  |  |
| Anomaly Type | string |  | Anomaly Sort | High/Low revenue when \|revenue z\| >= 2, else High/Low orders when \|orders z\| >= 2, else Normal. Closed = no orders. |
| Is Trading Day | boolean |  |  | At least one order recorded. |
| Anomaly Sort | int64 | yes |  |  |
| Calendar Event | string |  |  | Public holiday or notable U.S. retail date (2015 calendar, used as context for anomalies). |

## Time Slot

Dimension: the 48 half-hours of the day. Slot Key = minutes after midnight.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Slot Key (key) | int64 | yes |  |  |
| Slot Start | dateTime | yes |  |  |
| Slot Label | string |  | Slot Key | 9:30 AM |
| Hour | int64 |  |  | Hour of day, 0-23. |
| Hour Label | string |  | Hour | 12 PM |
| Day Part | string |  | Day Part Sort |  |
| Day Part Sort | int64 | yes |  |  |

## Pizza

Dimension: one row per pizza and size (menu item). Pizza Key is a surrogate key created after removing duplicates.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Pizza Key (key) | int64 | yes |  |  |
| Pizza ID | string |  |  | Source menu code, for example thai_ckn_l. |
| Pizza Type | string | yes |  | Menu code without the size suffix. |
| Pizza Name | string |  |  |  |
| Short Name | string |  |  | Pizza name without 'The' and 'Pizza'. |
| Category | string |  | Category Sort |  |
| Category Sort | int64 | yes |  |  |
| Size | string |  | Size Sort | S, M, L, XL, XXL. |
| Size Name | string |  | Size Sort |  |
| Size Sort | int64 | yes |  |  |
| Menu Price | decimal |  |  |  |
| Ingredients | string | yes |  | Original comma-separated ingredient list; normalised into Ingredient and Pizza Ingredient. |

## Ingredient

Dimension: unique ingredients split from the comma-separated source field.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Ingredient | string |  |  |  |
| Ingredient Key (key) | int64 | yes |  |  |

## Pizza Ingredient

Bridge: which ingredients each pizza contains. Filters flow Ingredient -> bridge; measures enable the bridge -> Pizza direction only where needed (CROSSFILTER).

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Pizza Key | int64 | yes |  |  |
| Ingredient Key | int64 | yes |  |  |

## Investigation Date

Disconnected slicer table: trading days to investigate on the Trading Day Investigation page.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Date | dateTime | yes |  |  |
| Investigation Sort | int64 | yes |  | 1 = strongest anomaly; orders the slicer so the default selection is the most unusual day. |
| Investigate a Date | string |  | Investigation Sort | Date label with its anomaly flag, strongest anomalies first. |

## Trend Metric

Disconnected slicer table: metric shown by the monthly trend chart.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Metric | string |  | Metric Sort |  |
| Metric Sort | int64 | yes |  |  |

## Rank By

Disconnected slicer table: ranking basis for the top and bottom five pizza tables.

| Column | Type | Hidden | Sort by | Description |
|---|---|---|---|---|
| Rank By | string |  | Rank By Sort |  |
| Rank By Sort | int64 | yes |  |  |

## Relationships

All relationships are many-to-one, single direction, active.

| From (many) | To (one) |
|---|---|
| Sales[Order Date] | Date[Date] |
| Sales[Slot Key] | Time Slot[Slot Key] |
| Sales[Pizza Key] | Pizza[Pizza Key] |
| Orders[Order Date] | Date[Date] |
| Orders[Slot Key] | Time Slot[Slot Key] |
| Staffing[Date] | Date[Date] |
| Staffing[Slot Key] | Time Slot[Slot Key] |
| Pizza Ingredient[Pizza Key] | Pizza[Pizza Key] |
| Pizza Ingredient[Ingredient Key] | Ingredient[Ingredient Key] |
