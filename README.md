# Data Analysis Portfolio

Welcome to my **data analysis portfolio**. Each project here goes end to end: from raw business data, through **SQL** pipelines and **Power BI** reports, to clear recommendations for a business decision-maker, with the financial impact estimated where possible.

Every project folder has its own README with the full story: background, executive summary, insights, recommendations and how to run it.

---

## SQL + Power BI Projects

End-to-end projects where the data is cleaned and analysed in SQL, then presented in Power BI.

### [Discount Guardrails: Where Deep Discounts Erode Retail Profit](./discount-guardrails)
- **Goal:** Find the maximum discount each product group should allow, for a US office-supply retailer (public Sample Superstore data, 2014–2017).
- **Highlights:** Discounts above 20% lost **\$135K** over four years, almost half of the company's **\$286K** profit. A modelled 20% cap adds **+\$135K to +\$219K**. Three product groups lose money even at up to 20% off and need a price fix, not a cap.
- **Tech Stack:** SQL Server (T-SQL, CTEs, window functions, stored procedures), Python (Matplotlib charts, automated cross-checks), Power BI with Deneb.

### [PatientCare Analytics: Reducing Missed Appointments](./patientcare-no-show-analytics)
- **Goal:** Find where outpatient no-shows concentrate across a 14-clinic network in Bangladesh, and test whether an enhanced reminder reduces them. Based on my work as a Data Analyst at Fieldbooster (2022–2023).
- **Highlights:** Consolidated **12 data sources (557,423 records)** into one reporting model. The enhanced reminder cut semi-urban no-shows from **26.0% to 20.1%** (p = 0.013), worth about **BDT 0.87M a year**. Automation cut weekly reporting from **244 to 62.5 minutes**.
- **Tech Stack:** PostgreSQL (layered raw → staging → core pipeline, data-quality logging, validation checks), A/B testing (two-proportion z-test, 95% confidence interval), Power BI.

---

## Power BI Projects

Interactive reports built with Power Query and DAX, designed for a manager to use week to week.

### [Slice & Co.: Pizza Operations Analytics](./slice-and-co-pizza-analytics)
- **Goal:** Show a pizza kitchen's General Manager when revenue comes in, which pizzas earn it, why some days are unusual, and whether staffing matches demand (2015: 21,350 orders, \$817.9K).
- **Highlights:** **56%** of revenue arrives in two rushes, at lunch and dinner. **38%** of orders are a single pizza, and converting 1 in 10 of them is worth about **\$13K a year**. **21** unusual trading days flagged against a typical same weekday.
- **Tech Stack:** Power BI (Power Query, DAX, data modelling), five-page report.

---

## Repository Structure

```
Data_Analysis_Projects
   ├── discount-guardrails             SQL Server · Python · Power BI
   │      ├── sql, scripts, data, results
   │      └── powerbi, report, docs, assets
   │
   ├── patientcare-no-show-analytics   PostgreSQL · Power BI
   │      └── sql, data, powerbi, docs
   │
   └── slice-and-co-pizza-analytics    Power BI
          └── data, powerbi, docs
```

---

## Skills Demonstrated

| Category | Key Skills |
|-----------|-------------|
| **SQL** | Multi-table joins, CTEs, window functions, CASE logic, stored procedures, bulk data loading |
| **Data Quality** | Staging layers, data-quality issue logs, validation and reconciliation checks |
| **Power BI** | Data modelling, DAX measures, Power Query, multi-page interactive reports, Deneb custom visuals |
| **Python** | Matplotlib charts, automated cross-checks against SQL results |
| **Analysis** | A/B testing (z-tests, confidence intervals), scenario modelling, anomaly detection with z-scores |
| **Communication** | Executive summaries and costed recommendations for business stakeholders |

---

## Author

**Rubaiyat Alam Ruhin**, Data Analyst  
[LinkedIn](https://linkedin.com/in/rubaiyatalamruhin) · [GitHub](https://github.com/ruhinb) · rubaiyatalam.ruhin@gmail.com
