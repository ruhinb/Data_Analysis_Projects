# Measure catalogue

99 measures in the `_Measures` table, grouped by display folder.

## 1 Sales

| Measure | Format | Description |
|---|---|---|
| Total Revenue | `$#,##0` | Sum of quantity x unit price for every order line. |
| Total Quantity Sold | `#,##0` | Number of pizzas sold. |
| Total Orders | `#,##0` | Distinct orders. Counted on the Sales fact so it responds to pizza, category and size filters. |
| Average Order Value | `$#,##0.00` | Revenue per order. |
| Average Pizzas per Order | `#,##0.00` | Pizzas per order. |
| Average Selling Price | `$#,##0.00` | Revenue per pizza sold (quantity-weighted price). |
| Revenue Share | `0.0%` | Share of revenue within the pizzas currently selected by slicers. |
| Quantity Share | `0.0%` | Share of pizzas sold within the pizzas currently selected by slicers. |
| Category Revenue Rank | `#,##0` | Rank of a category by revenue. |
| Category Quantity Rank | `#,##0` | Rank of a category by pizzas sold. |

## 2 Orders & Timing

| Measure | Format | Description |
|---|---|---|
| Trading Days | `#,##0` | Days with at least one recorded order. |
| Orders per Trading Day | `#,##0.0` | Average orders per trading day. Used for day x time heatmaps, so closed days do not dilute averages. |
| Revenue per Trading Day | `$#,##0` | Average revenue per trading day. |
| Single Pizza Orders | `#,##0` | Orders containing exactly one pizza. |
| Single Pizza Order % | `0.0%` | Share of orders containing exactly one pizza. |
| Average Order Gap (min) | `#,##0.0` | Average minutes between consecutive orders on the same trading day (orders sorted chronologically). |
| Peak Hour | `text` | Hour of the day with the most orders. |
| Peak Hour Orders per Day | `#,##0.0` | Average orders per trading day in the peak hour. |
| Peak Day | `text` | Weekday with the highest average orders per trading day. |
| Peak Day Orders per Day | `#,##0.0` | Average orders on the peak weekday. |
| Weekend Order Share | `0.0%` | Share of orders placed on Saturday or Sunday. |
| Peak Day Order Share | `0.0%` | Share of orders placed on the peak weekday. |

## 3 Period Comparison

| Measure | Format | Description |
|---|---|---|
| Revenue Change % | `+0.0%;-0.0%;0.0%` | Revenue change versus the comparison period (see Comparison Label). |
| Orders Change % | `+0.0%;-0.0%;0.0%` | Order change versus the comparison period. |
| Quantity Change % | `+0.0%;-0.0%;0.0%` | Pizzas-sold change versus the comparison period. |
| Average Order Value Change % | `+0.0%;-0.0%;0.0%` | Average order value change versus the comparison period. |
| Average Selling Price Change % | `+0.0%;-0.0%;0.0%` | Average selling price change versus the comparison period. |
| Single Pizza Order % Change (pp) | `+0.0%;-0.0%;0.0%` | Change in single-pizza order share, in percentage points. |
| Comparison Label | `text` | Describes the period used by the change measures. |
| Selection Label | `text` | Short description of the months selected. |
| KPI Revenue | `$#,##0` | Revenue for the full selection, used by KPI cards that also plot a weekly sparkline. |
| KPI Orders | `#,##0` | Orders for the full selection (KPI cards). |
| KPI Quantity Sold | `#,##0` | Pizzas sold for the full selection (KPI cards). |
| KPI Average Order Value | `$#,##0.00` | Average order value for the full selection (KPI cards). |
| KPI Average Pizzas per Order | `#,##0.00` | Pizzas per order for the full selection (KPI cards). |
| KPI Peak Hour | `text` | Peak hour for the full selection (KPI cards). |
| KPI Peak Day | `text` | Peak weekday for the full selection (KPI cards). |
| KPI Orders per Trading Day | `#,##0.0` | Orders per trading day for the full selection (KPI cards). |
| KPI Average Order Gap | `#,##0.0` | Average order gap for the full selection (KPI cards). |

## 4 Trend Switcher

| Measure | Format | Description |
|---|---|---|
| Selected Trend Metric | `text` | Metric chosen in the trend chart switcher (default Revenue). |
| Trend Numerator | `#,##0.00` | Numerator of the selected trend metric. Average Order Value uses revenue / orders. |
| Trend Denominator | `#,##0` | Denominator of the selected trend metric (orders for Average Order Value, otherwise 1). |

## 5 Menu

| Measure | Format | Description |
|---|---|---|
| Top Revenue Pizza | `text` | Pizza with the highest revenue. |
| Top Revenue Pizza Revenue | `$#,##0` | Revenue of the top revenue pizza. |
| Top Revenue Pizza Change % | `+0.0%;-0.0%;0.0%` | Revenue change of the top revenue pizza versus the comparison period. |
| Top Volume Pizza | `text` | Pizza with the most units sold. |
| Top Volume Pizza Quantity | `#,##0` | Units sold of the top volume pizza. |
| Top Volume Pizza Change % | `+0.0%;-0.0%;0.0%` | Units-sold change of the top volume pizza versus the comparison period. |
| Selected Rank By | `text` | Ranking basis for the top and bottom five tables (Revenue or Quantity). |
| Ingredient Pizzas Sold | `#,##0` | Pizzas sold that contain the ingredient (bridge filter applied only inside this measure). |
| Most Popular Ingredient | `text` | Ingredient found in the most pizzas sold for the current selection. |
| Least Popular Ingredient | `text` | Ingredient found in the fewest pizzas sold for the current selection (ingredients with no sales excluded). |
| Most Popular Ingredient Pizzas | `#,##0` | Pizzas sold containing the most popular ingredient. |
| Least Popular Ingredient Pizzas | `#,##0` | Pizzas sold containing the least popular ingredient. |
| Top Category | `text` | Category with the highest revenue. |
| Top Category Revenue Share | `0.0%` | Revenue share of the top category. |
| Bottom Revenue Pizza | `text` | Pizza with the lowest revenue (among pizzas with sales). |
| Bottom Revenue Pizza Revenue | `$#,##0` | Revenue of the lowest-revenue pizza. |
| Bottom Revenue Pizza Change % | `+0.0%;-0.0%;0.0%` | Revenue change of the lowest-revenue pizza versus the comparison period. |

## 6 Trading Day Investigation

| Measure | Format | Description |
|---|---|---|
| Investigated Date | `ddd d mmm yyyy` | Date chosen in the Investigate a date slicer; defaults to the day with the largest revenue z-score. |
| Investigated Date Label | `text` | Investigated date as text. |
| Investigated Anomaly Type | `text` | Anomaly classification of the investigated date. |
| Investigated Revenue | `$#,##0` | Revenue on the investigated date. |
| Investigated Orders | `#,##0` | Orders on the investigated date. |
| Investigated Pizzas | `#,##0` | Pizzas sold on the investigated date. |
| Investigated Average Order Value | `$#,##0.00` | Average order value on the investigated date. |
| Investigated Revenue Z-Score | `0.0` | Revenue z-score of the investigated date against other days of the same weekday. |
| Typical Weekday Revenue | `$#,##0` | Average revenue of the same weekday, excluding the investigated date. |
| Typical Weekday Orders | `#,##0.0` | Average orders of the same weekday, excluding the investigated date. |
| Typical Weekday Average Order Value | `$#,##0.00` | Average order value of a typical same weekday. |
| Revenue Variance vs Typical | `+$#,##0;-$#,##0;$0` | Revenue above (+) or below (-) a typical same weekday. |
| Revenue Variance vs Typical % | `+0%;-0%;0%` | Revenue variance as a share of a typical same weekday. |
| Orders Variance vs Typical % | `+0%;-0%;0%` | Order variance as a share of a typical same weekday. |
| Average Order Value Variance vs Typical % | `+0%;-0%;0%` | Basket-size variance as a share of a typical same weekday. |
| Order Volume Effect | `+$#,##0;-$#,##0;$0` | Part of the revenue variance explained by the number of orders. |
| Basket Size Effect | `+$#,##0;-$#,##0;$0` | Part of the revenue variance explained by spend per order. |
| Investigated Top Category | `text` | Category with the most revenue on the investigated date. |
| Investigated Top Category Share | `0.0%` | Revenue share of that category on the investigated date. |
| Typical Top Category Share | `0.0%` | Revenue share of the same category on a typical same weekday. |
| Investigated Peak Hour | `0` | Hour with the most revenue on the investigated date (0-23). |
| Investigated Peak Hour Label | `text` | Peak hour of the investigated date as a range, for example 6–7 PM. |
| Investigated Peak Hour Revenue | `$#,##0` | Revenue in the peak hour of the investigated date. |
| Typical Peak Hour Revenue | `$#,##0` | Average revenue in the same hour on a typical same weekday. |
| Day Revenue Variance % | `+0%;-0%;0%` | Row-level revenue variance against a typical same weekday (used in the flagged-day table). |
| Investigated Calendar Event | `text` | Holiday or notable retail date on the investigated date, if any. |
| Investigated Weekday | `text` | Weekday name of the investigated date. |

## 7 Workforce

| Measure | Format | Description |
|---|---|---|
| Baseline Labour Cost | `$#,##0` | Cost of the baseline roster. |
| Recommended Labour Cost | `$#,##0` | Cost of the demand-based recommended roster. |
| Potential Labour Savings | `$#,##0` | Baseline minus recommended labour cost. |
| Potential Labour Savings % | `0.0%` | Savings as a share of baseline labour cost. |
| Staffing Revenue | `$#,##0` | Revenue in the staffed half-hours (responds to the demand band slicer). |
| Baseline Labour Cost % | `0.0%` | Baseline labour cost as a share of revenue. |
| Recommended Labour Cost % | `0.0%` | Recommended labour cost as a share of revenue. |
| Baseline Labour Hours | `#,##0` | Paid hours in the baseline roster. |
| Recommended Labour Hours | `#,##0` | Paid hours in the recommended roster. |
| Average Scheduled Staff | `#,##0.0` | People on shift per half-hour in the baseline roster. |
| Average Recommended Staff | `#,##0.0` | People needed per half-hour under the recommended roster. |
| Average Slot Orders | `#,##0.0` | Orders per half-hour. |
| Average Staffing Gap | `+0.0;-0.0;0.0` | Scheduled minus recommended people per half-hour (positive = overstaffed). |

## DAX

### Total Revenue

```dax
Total Revenue =
SUM ( Sales[Line Revenue] )
```

### Total Quantity Sold

```dax
Total Quantity Sold =
SUM ( Sales[Quantity] )
```

### Total Orders

```dax
Total Orders =
DISTINCTCOUNT ( Sales[Order ID] )
```

### Average Order Value

```dax
Average Order Value =
DIVIDE ( [Total Revenue], [Total Orders] )
```

### Average Pizzas per Order

```dax
Average Pizzas per Order =
DIVIDE ( [Total Quantity Sold], [Total Orders] )
```

### Average Selling Price

```dax
Average Selling Price =
DIVIDE ( [Total Revenue], [Total Quantity Sold] )
```

### Revenue Share

```dax
Revenue Share =
DIVIDE ( [Total Revenue], CALCULATE ( [Total Revenue], ALLSELECTED ( Pizza ) ) )
```

### Quantity Share

```dax
Quantity Share =
DIVIDE ( [Total Quantity Sold], CALCULATE ( [Total Quantity Sold], ALLSELECTED ( Pizza ) ) )
```

### Category Revenue Rank

```dax
Category Revenue Rank =
IF ( NOT ISBLANK ( [Total Revenue] ), RANKX ( ALLSELECTED ( Pizza[Category] ), [Total Revenue], , DESC, DENSE ) )
```

### Category Quantity Rank

```dax
Category Quantity Rank =
IF ( NOT ISBLANK ( [Total Quantity Sold] ), RANKX ( ALLSELECTED ( Pizza[Category] ), [Total Quantity Sold], , DESC, DENSE ) )
```

### Trading Days

```dax
Trading Days =
CALCULATE ( COUNTROWS ( 'Date' ), KEEPFILTERS ( 'Date'[Is Trading Day] = TRUE () ) )
```

### Orders per Trading Day

```dax
Orders per Trading Day =
DIVIDE ( [Total Orders], [Trading Days] )
```

### Revenue per Trading Day

```dax
Revenue per Trading Day =
DIVIDE ( [Total Revenue], [Trading Days] )
```

### Single Pizza Orders

```dax
Single Pizza Orders =
CALCULATE ( [Total Orders], KEEPFILTERS ( Sales[Order Pizza Count] = 1 ) )
```

### Single Pizza Order %

```dax
Single Pizza Order % =
DIVIDE ( [Single Pizza Orders], [Total Orders] )
```

### Average Order Gap (min)

```dax
Average Order Gap (min) =
AVERAGE ( Orders[Minutes Since Previous Order] )
```

### Peak Hour

```dax
Peak Hour =
VAR _hours = FILTER ( ADDCOLUMNS ( VALUES ( 'Time Slot'[Hour] ), "@orders", [Total Orders] ), NOT ISBLANK ( [@orders] ) )
VAR _top = TOPN ( 1, _hours, [@orders], DESC, 'Time Slot'[Hour], ASC )
VAR _hour = MAXX ( _top, 'Time Slot'[Hour] )
RETURN
    IF ( NOT ISBLANK ( _hour ), FORMAT ( TIME ( _hour, 0, 0 ), "h AM/PM" ) )
```

### Peak Hour Orders per Day

```dax
Peak Hour Orders per Day =
VAR _hours = FILTER ( ADDCOLUMNS ( VALUES ( 'Time Slot'[Hour] ), "@orders", [Orders per Trading Day] ), NOT ISBLANK ( [@orders] ) )
RETURN
    MAXX ( _hours, [@orders] )
```

### Peak Day

```dax
Peak Day =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( 'Date'[Weekday Name] ), "@value", [Orders per Trading Day] ), NOT ISBLANK ( [@value] ) )
VAR _top = TOPN ( 1, _items, [@value], DESC, 'Date'[Weekday Name], ASC )
RETURN
    MAXX ( _top, 'Date'[Weekday Name] )
```

### Peak Day Orders per Day

```dax
Peak Day Orders per Day =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( 'Date'[Weekday Name] ), "@value", [Orders per Trading Day] ), NOT ISBLANK ( [@value] ) )
VAR _top = TOPN ( 1, _items, [@value], DESC, 'Date'[Weekday Name], ASC )
RETURN
    MAXX ( _top, [@value] )
```

### Weekend Order Share

```dax
Weekend Order Share =
DIVIDE ( CALCULATE ( [Total Orders], KEEPFILTERS ( 'Date'[Day Type] = "Weekend" ) ), [Total Orders] )
```

### Peak Day Order Share

```dax
Peak Day Order Share =
VAR _day = [Peak Day]
RETURN
    DIVIDE ( CALCULATE ( [Total Orders], KEEPFILTERS ( 'Date'[Weekday Name] = _day ) ), [Total Orders] )
```

### Revenue Change %

```dax
Revenue Change % =
VAR _months = CALCULATETABLE ( VALUES ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _n = COUNTROWS ( _months )
VAR _first = MINX ( _months, 'Date'[Month Index] )
VAR _last = MAXX ( _months, 'Date'[Month Index] )
VAR _dataFirst = CALCULATE ( MIN ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
VAR _hasPrevious = _first - _n >= _dataFirst
VAR _half = INT ( _n / 2 )
VAR _current =
    IF (
        _hasPrevious,
        CALCULATE ( [Total Revenue], ALLSELECTED ( 'Date' ) ),
        CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] > _last - _half, 'Date'[Month Index] <= _last )
    )
VAR _baseline =
    IF (
        _hasPrevious,
        CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first - _n, 'Date'[Month Index] < _first ),
        CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first, 'Date'[Month Index] < _first + _half )
    )
RETURN
    IF ( _hasPrevious || _n >= 2, DIVIDE ( _current - _baseline, _baseline ) )
```

### Orders Change %

```dax
Orders Change % =
VAR _months = CALCULATETABLE ( VALUES ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _n = COUNTROWS ( _months )
VAR _first = MINX ( _months, 'Date'[Month Index] )
VAR _last = MAXX ( _months, 'Date'[Month Index] )
VAR _dataFirst = CALCULATE ( MIN ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
VAR _hasPrevious = _first - _n >= _dataFirst
VAR _half = INT ( _n / 2 )
VAR _current =
    IF (
        _hasPrevious,
        CALCULATE ( [Total Orders], ALLSELECTED ( 'Date' ) ),
        CALCULATE ( [Total Orders], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] > _last - _half, 'Date'[Month Index] <= _last )
    )
VAR _baseline =
    IF (
        _hasPrevious,
        CALCULATE ( [Total Orders], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first - _n, 'Date'[Month Index] < _first ),
        CALCULATE ( [Total Orders], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first, 'Date'[Month Index] < _first + _half )
    )
RETURN
    IF ( _hasPrevious || _n >= 2, DIVIDE ( _current - _baseline, _baseline ) )
```

### Quantity Change %

```dax
Quantity Change % =
VAR _months = CALCULATETABLE ( VALUES ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _n = COUNTROWS ( _months )
VAR _first = MINX ( _months, 'Date'[Month Index] )
VAR _last = MAXX ( _months, 'Date'[Month Index] )
VAR _dataFirst = CALCULATE ( MIN ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
VAR _hasPrevious = _first - _n >= _dataFirst
VAR _half = INT ( _n / 2 )
VAR _current =
    IF (
        _hasPrevious,
        CALCULATE ( [Total Quantity Sold], ALLSELECTED ( 'Date' ) ),
        CALCULATE ( [Total Quantity Sold], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] > _last - _half, 'Date'[Month Index] <= _last )
    )
VAR _baseline =
    IF (
        _hasPrevious,
        CALCULATE ( [Total Quantity Sold], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first - _n, 'Date'[Month Index] < _first ),
        CALCULATE ( [Total Quantity Sold], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first, 'Date'[Month Index] < _first + _half )
    )
RETURN
    IF ( _hasPrevious || _n >= 2, DIVIDE ( _current - _baseline, _baseline ) )
```

### Average Order Value Change %

```dax
Average Order Value Change % =
VAR _months = CALCULATETABLE ( VALUES ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _n = COUNTROWS ( _months )
VAR _first = MINX ( _months, 'Date'[Month Index] )
VAR _last = MAXX ( _months, 'Date'[Month Index] )
VAR _dataFirst = CALCULATE ( MIN ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
VAR _hasPrevious = _first - _n >= _dataFirst
VAR _half = INT ( _n / 2 )
VAR _current =
    IF (
        _hasPrevious,
        CALCULATE ( [Average Order Value], ALLSELECTED ( 'Date' ) ),
        CALCULATE ( [Average Order Value], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] > _last - _half, 'Date'[Month Index] <= _last )
    )
VAR _baseline =
    IF (
        _hasPrevious,
        CALCULATE ( [Average Order Value], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first - _n, 'Date'[Month Index] < _first ),
        CALCULATE ( [Average Order Value], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first, 'Date'[Month Index] < _first + _half )
    )
RETURN
    IF ( _hasPrevious || _n >= 2, DIVIDE ( _current - _baseline, _baseline ) )
```

### Average Selling Price Change %

```dax
Average Selling Price Change % =
VAR _months = CALCULATETABLE ( VALUES ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _n = COUNTROWS ( _months )
VAR _first = MINX ( _months, 'Date'[Month Index] )
VAR _last = MAXX ( _months, 'Date'[Month Index] )
VAR _dataFirst = CALCULATE ( MIN ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
VAR _hasPrevious = _first - _n >= _dataFirst
VAR _half = INT ( _n / 2 )
VAR _current =
    IF (
        _hasPrevious,
        CALCULATE ( [Average Selling Price], ALLSELECTED ( 'Date' ) ),
        CALCULATE ( [Average Selling Price], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] > _last - _half, 'Date'[Month Index] <= _last )
    )
VAR _baseline =
    IF (
        _hasPrevious,
        CALCULATE ( [Average Selling Price], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first - _n, 'Date'[Month Index] < _first ),
        CALCULATE ( [Average Selling Price], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first, 'Date'[Month Index] < _first + _half )
    )
RETURN
    IF ( _hasPrevious || _n >= 2, DIVIDE ( _current - _baseline, _baseline ) )
```

### Single Pizza Order % Change (pp)

```dax
Single Pizza Order % Change (pp) =
VAR _months = CALCULATETABLE ( VALUES ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _n = COUNTROWS ( _months )
VAR _first = MINX ( _months, 'Date'[Month Index] )
VAR _last = MAXX ( _months, 'Date'[Month Index] )
VAR _dataFirst = CALCULATE ( MIN ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
VAR _hasPrevious = _first - _n >= _dataFirst
VAR _half = INT ( _n / 2 )
VAR _current =
    IF (
        _hasPrevious,
        CALCULATE ( [Single Pizza Order %], ALLSELECTED ( 'Date' ) ),
        CALCULATE ( [Single Pizza Order %], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] > _last - _half, 'Date'[Month Index] <= _last )
    )
VAR _baseline =
    IF (
        _hasPrevious,
        CALCULATE ( [Single Pizza Order %], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first - _n, 'Date'[Month Index] < _first ),
        CALCULATE ( [Single Pizza Order %], REMOVEFILTERS ( 'Date' ), 'Date'[Month Index] >= _first, 'Date'[Month Index] < _first + _half )
    )
RETURN
    IF ( _hasPrevious || _n >= 2, _current - _baseline )
```

### Comparison Label

```dax
Comparison Label =
VAR _months = CALCULATETABLE ( VALUES ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _n = COUNTROWS ( _months )
VAR _first = MINX ( _months, 'Date'[Month Index] )
VAR _dataFirst = CALCULATE ( MIN ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
VAR _hasPrevious = _first - _n >= _dataFirst
VAR _previousMonth = DATE ( INT ( ( _first - 2 ) / 12 ), MOD ( _first - 2, 12 ) + 1, 1 )
RETURN
    SWITCH (
        TRUE (),
        _hasPrevious && _n = 1, "vs " & FORMAT ( _previousMonth, "mmm yyyy" ),
        _hasPrevious, "vs previous " & _n & " months",
        _n = 12, "H2 vs H1",
        _n >= 2, "later vs earlier months",
        "no earlier month"
    )
```

### Selection Label

```dax
Selection Label =
VAR _n = CALCULATE ( DISTINCTCOUNT ( 'Date'[Month Index] ), ALLSELECTED ( 'Date' ) )
VAR _all = CALCULATE ( DISTINCTCOUNT ( 'Date'[Month Index] ), REMOVEFILTERS ( 'Date' ) )
RETURN
    SWITCH (
        TRUE (),
        _n = _all, "All months",
        _n = 1, CALCULATE ( MAX ( 'Date'[Month Year] ), ALLSELECTED ( 'Date' ) ),
        _n & " months"
    )
```

### KPI Revenue

```dax
KPI Revenue =
CALCULATE ( [Total Revenue], ALLSELECTED ( 'Date' ) )
```

### KPI Orders

```dax
KPI Orders =
CALCULATE ( [Total Orders], ALLSELECTED ( 'Date' ) )
```

### KPI Quantity Sold

```dax
KPI Quantity Sold =
CALCULATE ( [Total Quantity Sold], ALLSELECTED ( 'Date' ) )
```

### KPI Average Order Value

```dax
KPI Average Order Value =
CALCULATE ( [Average Order Value], ALLSELECTED ( 'Date' ) )
```

### KPI Average Pizzas per Order

```dax
KPI Average Pizzas per Order =
CALCULATE ( [Average Pizzas per Order], ALLSELECTED ( 'Date' ) )
```

### Selected Trend Metric

```dax
Selected Trend Metric =
SELECTEDVALUE ( 'Trend Metric'[Metric], "Revenue" )
```

### Trend Numerator

```dax
Trend Numerator =
SWITCH (
    [Selected Trend Metric],
    "Orders", [Total Orders],
    "Pizzas Sold", [Total Quantity Sold],
    [Total Revenue]
)
```

### Trend Denominator

```dax
Trend Denominator =
IF ( [Selected Trend Metric] = "Average Order Value", [Total Orders], 1 )
```

### Top Revenue Pizza

```dax
Top Revenue Pizza =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Pizza[Short Name] ), "@value", [Total Revenue] ), NOT ISBLANK ( [@value] ) )
VAR _top = TOPN ( 1, _items, [@value], DESC, Pizza[Short Name], ASC )
RETURN
    MAXX ( _top, Pizza[Short Name] )
```

### Top Revenue Pizza Revenue

```dax
Top Revenue Pizza Revenue =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Pizza[Short Name] ), "@value", [Total Revenue] ), NOT ISBLANK ( [@value] ) )
VAR _top = TOPN ( 1, _items, [@value], DESC, Pizza[Short Name], ASC )
RETURN
    MAXX ( _top, [@value] )
```

### Top Revenue Pizza Change %

```dax
Top Revenue Pizza Change % =
VAR _pizza = [Top Revenue Pizza]
RETURN
    CALCULATE ( [Revenue Change %], KEEPFILTERS ( Pizza[Short Name] = _pizza ) )
```

### Top Volume Pizza

```dax
Top Volume Pizza =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Pizza[Short Name] ), "@value", [Total Quantity Sold] ), NOT ISBLANK ( [@value] ) )
VAR _top = TOPN ( 1, _items, [@value], DESC, Pizza[Short Name], ASC )
RETURN
    MAXX ( _top, Pizza[Short Name] )
```

### Top Volume Pizza Quantity

```dax
Top Volume Pizza Quantity =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Pizza[Short Name] ), "@value", [Total Quantity Sold] ), NOT ISBLANK ( [@value] ) )
VAR _top = TOPN ( 1, _items, [@value], DESC, Pizza[Short Name], ASC )
RETURN
    MAXX ( _top, [@value] )
```

### Top Volume Pizza Change %

```dax
Top Volume Pizza Change % =
VAR _pizza = [Top Volume Pizza]
RETURN
    CALCULATE ( [Quantity Change %], KEEPFILTERS ( Pizza[Short Name] = _pizza ) )
```

### Selected Rank By

```dax
Selected Rank By =
SELECTEDVALUE ( 'Rank By'[Rank By], "Revenue" )
```

### Ingredient Pizzas Sold

```dax
Ingredient Pizzas Sold =
CALCULATE ( [Total Quantity Sold], CROSSFILTER ( 'Pizza Ingredient'[Pizza Key], Pizza[Pizza Key], BOTH ) )
```

### Most Popular Ingredient

```dax
Most Popular Ingredient =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Ingredient[Ingredient] ), "@qty", [Ingredient Pizzas Sold] ), [@qty] > 0 )
RETURN
    MAXX ( TOPN ( 1, _items, [@qty], DESC, Ingredient[Ingredient], ASC ), Ingredient[Ingredient] )
```

### Least Popular Ingredient

```dax
Least Popular Ingredient =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Ingredient[Ingredient] ), "@qty", [Ingredient Pizzas Sold] ), [@qty] > 0 )
RETURN
    MAXX ( TOPN ( 1, _items, [@qty], ASC, Ingredient[Ingredient], ASC ), Ingredient[Ingredient] )
```

### Most Popular Ingredient Pizzas

```dax
Most Popular Ingredient Pizzas =
VAR _ingredient = [Most Popular Ingredient]
RETURN
    CALCULATE ( [Ingredient Pizzas Sold], KEEPFILTERS ( Ingredient[Ingredient] = _ingredient ) )
```

### Least Popular Ingredient Pizzas

```dax
Least Popular Ingredient Pizzas =
VAR _ingredient = [Least Popular Ingredient]
RETURN
    CALCULATE ( [Ingredient Pizzas Sold], KEEPFILTERS ( Ingredient[Ingredient] = _ingredient ) )
```

### Top Category

```dax
Top Category =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Pizza[Category] ), "@value", [Total Revenue] ), NOT ISBLANK ( [@value] ) )
VAR _top = TOPN ( 1, _items, [@value], DESC, Pizza[Category], ASC )
RETURN
    MAXX ( _top, Pizza[Category] )
```

### Top Category Revenue Share

```dax
Top Category Revenue Share =
VAR _category = [Top Category]
RETURN
    DIVIDE ( CALCULATE ( [Total Revenue], KEEPFILTERS ( Pizza[Category] = _category ) ), [Total Revenue] )
```

### Investigated Date

```dax
Investigated Date =
VAR _picked = SELECTEDVALUE ( 'Investigation Date'[Date] )
VAR _tradingDays = CALCULATETABLE ( 'Date', REMOVEFILTERS ( 'Date' ), 'Date'[Is Trading Day] = TRUE () )
VAR _strongest = MAXX ( TOPN ( 1, _tradingDays, ABS ( 'Date'[Revenue Z-Score] ), DESC ), 'Date'[Date] )
RETURN
    COALESCE ( _picked, _strongest )
```

### Investigated Date Label

```dax
Investigated Date Label =
FORMAT ( [Investigated Date], "ddd d mmm yyyy" )
```

### Investigated Anomaly Type

```dax
Investigated Anomaly Type =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( MAX ( 'Date'[Anomaly Type] ), REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Investigated Revenue

```dax
Investigated Revenue =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Investigated Orders

```dax
Investigated Orders =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( [Total Orders], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Investigated Pizzas

```dax
Investigated Pizzas =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( [Total Quantity Sold], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Investigated Average Order Value

```dax
Investigated Average Order Value =
DIVIDE ( [Investigated Revenue], [Investigated Orders] )
```

### Investigated Revenue Z-Score

```dax
Investigated Revenue Z-Score =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( MAX ( 'Date'[Revenue Z-Score] ), REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Typical Weekday Revenue

```dax
Typical Weekday Revenue =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( MAX ( 'Date'[Typical Weekday Revenue] ), REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Typical Weekday Orders

```dax
Typical Weekday Orders =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( MAX ( 'Date'[Typical Weekday Orders] ), REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Typical Weekday Average Order Value

```dax
Typical Weekday Average Order Value =
DIVIDE ( [Typical Weekday Revenue], [Typical Weekday Orders] )
```

### Revenue Variance vs Typical

```dax
Revenue Variance vs Typical =
[Investigated Revenue] - [Typical Weekday Revenue]
```

### Revenue Variance vs Typical %

```dax
Revenue Variance vs Typical % =
DIVIDE ( [Revenue Variance vs Typical], [Typical Weekday Revenue] )
```

### Orders Variance vs Typical %

```dax
Orders Variance vs Typical % =
DIVIDE ( [Investigated Orders] - [Typical Weekday Orders], [Typical Weekday Orders] )
```

### Average Order Value Variance vs Typical %

```dax
Average Order Value Variance vs Typical % =
DIVIDE ( [Investigated Average Order Value] - [Typical Weekday Average Order Value], [Typical Weekday Average Order Value] )
```

### Order Volume Effect

```dax
Order Volume Effect =
( [Investigated Orders] - [Typical Weekday Orders] ) * [Typical Weekday Average Order Value]
```

### Basket Size Effect

```dax
Basket Size Effect =
[Investigated Orders] * ( [Investigated Average Order Value] - [Typical Weekday Average Order Value] )
```

### Investigated Top Category

```dax
Investigated Top Category =
VAR _day = [Investigated Date]
VAR _categories = ADDCOLUMNS ( VALUES ( Pizza[Category] ), "@revenue", CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day ) )
RETURN
    MAXX ( TOPN ( 1, _categories, [@revenue], DESC, Pizza[Category], ASC ), Pizza[Category] )
```

### Investigated Top Category Share

```dax
Investigated Top Category Share =
VAR _day = [Investigated Date]
VAR _category = [Investigated Top Category]
RETURN
    DIVIDE (
        CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day, Pizza[Category] = _category ),
        CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
    )
```

### Typical Top Category Share

```dax
Typical Top Category Share =
VAR _day = [Investigated Date]
VAR _weekday = WEEKDAY ( _day, 2 )
VAR _typicalDays =
    CALCULATETABLE (
        VALUES ( 'Date'[Date] ),
        REMOVEFILTERS ( 'Date' ),
        'Date'[Day of Week Number] = _weekday,
        'Date'[Is Trading Day] = TRUE (),
        'Date'[Date] <> _day
    )
VAR _category = [Investigated Top Category]
RETURN
    DIVIDE (
        CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), _typicalDays, Pizza[Category] = _category ),
        CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), _typicalDays )
    )
```

### Investigated Peak Hour

```dax
Investigated Peak Hour =
VAR _day = [Investigated Date]
VAR _hours = FILTER ( ADDCOLUMNS ( VALUES ( 'Time Slot'[Hour] ), "@revenue", CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day ) ), NOT ISBLANK ( [@revenue] ) )
RETURN
    MAXX ( TOPN ( 1, _hours, [@revenue], DESC, 'Time Slot'[Hour], ASC ), 'Time Slot'[Hour] )
```

### Investigated Peak Hour Label

```dax
Investigated Peak Hour Label =
VAR _hour = [Investigated Peak Hour]
RETURN
    IF (
        NOT ISBLANK ( _hour ),
        ( MOD ( _hour + 11, 12 ) + 1 ) & "–" & ( MOD ( _hour, 12 ) + 1 ) & IF ( _hour + 1 >= 12 && _hour + 1 < 24, " PM", " AM" )
    )
```

### Investigated Peak Hour Revenue

```dax
Investigated Peak Hour Revenue =
VAR _day = [Investigated Date]
VAR _hour = [Investigated Peak Hour]
RETURN
    CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day, 'Time Slot'[Hour] = _hour )
```

### Typical Peak Hour Revenue

```dax
Typical Peak Hour Revenue =
VAR _day = [Investigated Date]
VAR _weekday = WEEKDAY ( _day, 2 )
VAR _typicalDays =
    CALCULATETABLE (
        VALUES ( 'Date'[Date] ),
        REMOVEFILTERS ( 'Date' ),
        'Date'[Day of Week Number] = _weekday,
        'Date'[Is Trading Day] = TRUE (),
        'Date'[Date] <> _day
    )
VAR _hour = [Investigated Peak Hour]
RETURN
    DIVIDE ( CALCULATE ( [Total Revenue], REMOVEFILTERS ( 'Date' ), _typicalDays, 'Time Slot'[Hour] = _hour ), COUNTROWS ( _typicalDays ) )
```

### Day Revenue Variance %

```dax
Day Revenue Variance % =
VAR _typical = MAX ( 'Date'[Typical Weekday Revenue] )
RETURN
    IF ( HASONEVALUE ( 'Date'[Date] ), DIVIDE ( [Total Revenue] - _typical, _typical ) )
```

### Baseline Labour Cost

```dax
Baseline Labour Cost =
SUM ( Staffing[Scheduled Labour Cost] )
```

### Recommended Labour Cost

```dax
Recommended Labour Cost =
SUM ( Staffing[Recommended Labour Cost] )
```

### Potential Labour Savings

```dax
Potential Labour Savings =
[Baseline Labour Cost] - [Recommended Labour Cost]
```

### Potential Labour Savings %

```dax
Potential Labour Savings % =
DIVIDE ( [Potential Labour Savings], [Baseline Labour Cost] )
```

### Staffing Revenue

```dax
Staffing Revenue =
SUM ( Staffing[Slot Revenue] )
```

### Baseline Labour Cost %

```dax
Baseline Labour Cost % =
DIVIDE ( [Baseline Labour Cost], [Staffing Revenue] )
```

### Recommended Labour Cost %

```dax
Recommended Labour Cost % =
DIVIDE ( [Recommended Labour Cost], [Staffing Revenue] )
```

### Baseline Labour Hours

```dax
Baseline Labour Hours =
SUM ( Staffing[Scheduled Labour Hours] )
```

### Recommended Labour Hours

```dax
Recommended Labour Hours =
SUM ( Staffing[Recommended Labour Hours] )
```

### Average Scheduled Staff

```dax
Average Scheduled Staff =
AVERAGE ( Staffing[Scheduled Staff] )
```

### Average Recommended Staff

```dax
Average Recommended Staff =
AVERAGE ( Staffing[Recommended Staff] )
```

### Average Slot Orders

```dax
Average Slot Orders =
AVERAGE ( Staffing[Slot Orders] )
```

### Average Staffing Gap

```dax
Average Staffing Gap =
AVERAGE ( Staffing[Staffing Gap] )
```

### KPI Peak Hour

```dax
KPI Peak Hour =
CALCULATE ( [Peak Hour], ALLSELECTED ( 'Date' ), ALLSELECTED ( 'Time Slot' ) )
```

### KPI Peak Day

```dax
KPI Peak Day =
CALCULATE ( [Peak Day], ALLSELECTED ( 'Date' ), ALLSELECTED ( 'Time Slot' ) )
```

### KPI Orders per Trading Day

```dax
KPI Orders per Trading Day =
CALCULATE ( [Orders per Trading Day], ALLSELECTED ( 'Date' ), ALLSELECTED ( 'Time Slot' ) )
```

### KPI Average Order Gap

```dax
KPI Average Order Gap =
CALCULATE ( [Average Order Gap (min)], ALLSELECTED ( 'Date' ), ALLSELECTED ( 'Time Slot' ) )
```

### Bottom Revenue Pizza

```dax
Bottom Revenue Pizza =
VAR _items = FILTER ( ADDCOLUMNS ( VALUES ( Pizza[Short Name] ), "@value", [Total Revenue] ), NOT ISBLANK ( [@value] ) )
RETURN
    MAXX ( TOPN ( 1, _items, [@value], ASC, Pizza[Short Name], ASC ), Pizza[Short Name] )
```

### Bottom Revenue Pizza Revenue

```dax
Bottom Revenue Pizza Revenue =
VAR _pizza = [Bottom Revenue Pizza]
RETURN
    CALCULATE ( [Total Revenue], KEEPFILTERS ( Pizza[Short Name] = _pizza ) )
```

### Bottom Revenue Pizza Change %

```dax
Bottom Revenue Pizza Change % =
VAR _pizza = [Bottom Revenue Pizza]
RETURN
    CALCULATE ( [Revenue Change %], KEEPFILTERS ( Pizza[Short Name] = _pizza ) )
```

### Investigated Calendar Event

```dax
Investigated Calendar Event =
VAR _day = [Investigated Date]
RETURN
    CALCULATE ( MAX ( 'Date'[Calendar Event] ), REMOVEFILTERS ( 'Date' ), 'Date'[Date] = _day )
```

### Investigated Weekday

```dax
Investigated Weekday =
FORMAT ( [Investigated Date], "dddd" )
```
