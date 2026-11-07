# Data dictionary

## Source tables (loaded by `sql/1_setup/00_load.sql`)

| Table | One row = | Rows | Key | Notes |
|---|---|---:|---|---|
| ORDERS | one order line (one product in one order) | 9,994 | `ROW_ID` | 5,009 distinct `ORDER_ID`s; order dates 3 Jan 2014 – 30 Dec 2017; no nulls in sales, profit, discount or keys |
| PRODUCT | one product | 1,862 | `ID` | **Column names do not match contents** (see below) |
| CUSTOMER | one customer | 793 | `ID` | US only; 41 states, 252 cities; one location per customer |
| EMPLOYEES | one sales rep | 9 | `ID_EMPLOYEE` | Not used (see Problems with the data) |

ORDERS joins to PRODUCT on `PRODUCT_ID = ID` and to CUSTOMER on `CUSTOMER_ID = ID`. Every order line finds a match, and every product and customer has at least one order.

### PRODUCT column fix

| Source column | Actually contains | Name in `fct_order_line` |
|---|---|---|
| `NAME` | Category (Furniture, Office Supplies, Technology) | `CATEGORY` |
| `CATEGORY` | Sub-category (17, e.g. Chairs, Binders) | `SUB_CATEGORY` |
| `SUBCATEGORY` | Product name | `PRODUCT_NAME` |

## `dbo.fct_order_line` (one row per order line, 9,994 rows)

| Column | Meaning |
|---|---|
| `ROW_ID`, `ORDER_ID`, `ORDER_DATE` | From ORDERS |
| `ORDER_YEAR`, `ORDER_QUARTER`, `QUARTER_YEAR` | Calendar year, quarter number, and a label such as `Q4-2017` |
| `SHIP_MODE` | From ORDERS |
| `CUSTOMER_ID`, `SEGMENT`, `REGION`, `STATE` | Customer and their **listed** location (not the delivery address) |
| `PRODUCT_ID`, `CATEGORY`, `SUB_CATEGORY`, `PRODUCT_NAME` | Product, with fixed names |
| `QUANTITY`, `DISCOUNT` | Units; discount as a fraction (0.20 = 20%) |
| `DISCOUNT_BAND` | `1. No Discount` (0) · `2. Standard (up to 20%)` (0 < d ≤ 0.20) · `3. Deep (over 20% to 50%)` (0.20 < d ≤ 0.50) · `4. Clearance (over 50%)` (d > 0.50) |
| `SALES` | Revenue after discount, US\$ |
| `PROFIT` | Profit as supplied in the data, US$ |
| `IMPLIED_COST` | `SALES − PROFIT`. Derived; the data has no cost field |


## Problems with the data

- **Sales reps.** Reps are assigned to individual order lines, not to orders, so 2,288 orders have more than one rep. A rep's region doesn't match the customer's region, and all nine reps have nearly identical category and discount mixes. It looks like random assignment, so I didn't use the field.
- **Geography.** Each customer has one listed state. Region and state results describe where customers are listed, not where orders were shipped.
- **Possible duplicate.** ROW_IDs 3406 and 3407 are identical apart from the rep. I kept both; removing one changes total profit by under 0.01%. Seven other order + product pairs repeat, but with different quantities, so I treated them as genuine split lines.
- **Missing fields.** There is no cost, price-list or reason-for-discount data.
