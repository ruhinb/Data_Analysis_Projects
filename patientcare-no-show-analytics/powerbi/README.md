# Power BI report

Five pages, 1280 × 720, built on a star-schema model that loads either from the PostgreSQL warehouse or from the CSVs the SQL pipeline exports.

The report is saved as a Power BI Project (PBIP), as well as '.pbix'.

```text
powerbi/
├── PatientCare_Analytics.pbip            open this file in Power BI Desktop
├── PatientCare_Analytics.SemanticModel/  tables, relationships and DAX measures (TMDL)
├── PatientCare_Analytics.Report/         pages and visuals (PBIR)
└── theme/
    ├── patientcare_theme.json            colours and fonts used by every visual
    └── backgrounds/                      one background image per page (header, card shapes, gradient tiles)
```

## Opening the report

Power BI Desktop runs on Windows only.

1. Open `PatientCare_Analytics.pbip` in Power BI Desktop (2025 or later).
2. Go to **Home → Transform data → Edit parameters** and choose a source with **SourceType**:
   - **CSV** (default): set **DataFolder** to the full path of `data/processed`, for example `C:\Projects\patientcare-no-show-analytics\data\processed`. Without the full data, use `data\sample\processed`, a 500-appointment sample that ships with the repo (`data\sample\raw` will not work: those are the raw files the SQL pipeline reads).
   - **PostgreSQL**: set **PostgreSQLServer** (default `localhost`) and **PostgreSQLDatabase** (default `patientcare_analytics`).
3. Click **Refresh**. The project is saved without data, so visuals stay empty until the first refresh.

The report uses **Deneb**, a free custom visual certified by Microsoft, for 29 of its visuals: every chart and every KPI row. 

## Pages

| Page | Question it answers | Main visuals |
|---|---|---|
| Overview | How big is the 14-clinic group, and how do demand and no-shows change over time? | Slicers, reset button, KPI tiles, monthly appointments with the no-show rate below, outcome and booking-channel donuts, service-mix tiles, specialty treemap, weekday × time heatmap |
| Pre-pilot baseline | Where are no-shows concentrated, and why target semi-urban patients? | Semi-urban vs urban lines with the gap shaded, area × time heatmap, booking-channel lollipop, lead-time columns, missed fees by month and area |
| Pilot results | Did enhanced reminders lower the no-show rate? | Two gauges, forest plot of the reduction with 95% intervals, delivery donut and bars, pilot funnel, fees kept (standard rate vs actual) |
| Reporting efficiency | How much weekly reporting time did automation save? | Weekly time with phase averages, waterfall of the saving by stage, before/after donuts, cumulative hours saved |
| Outcomes | What did the project deliver, and what should happen next? | Outcome tiles, evidence chain, recommendations, 12-month projection of fees kept with its 95% range |

Images of each page are in [`docs/images`](../docs/images) (`dashboard_01_overview.jpg` to `dashboard_05_outcomes.jpg`), and the model diagram is `semantic_model.jpg`.

### Design

- **One colour, one meaning.** Colours come from a palette checked for colour-blind readers. On each page a colour stands for one thing: semi-urban (orange) vs urban (blue), standard (violet) vs enhanced reminder (green), before (orange) vs after automation (green).
- **No dual axes.** Appointments and the no-show rate sit in two stacked charts that share the month axis.
- **Gradients live in the background image.** Each page uses a background image for the header band, the card shapes and the gradient tiles. The visuals on top have transparent backgrounds.
- **Labels instead of legends where possible.** Data labels and short captions carry the numbers, so the page reads without hovering.

## Data model

A star schema with `Appointments` at the centre: 4 dimensions, 8 fact tables and 3 hidden helper tables.

| Model table | Kind | SQL source (`core` schema) | One row per |
|---|---|---|---|
| Date | Dimension | `dim_date` | Day, plus an Unknown row |
| Clinic | Dimension | `dim_clinic` | Clinic (14, plus Unknown) |
| Doctor | Dimension | `dim_doctor` | Doctor (115, plus Unknown) |
| Patient | Dimension | `dim_patient` | Patient (34,460, plus Unknown) |
| Appointments | Fact | `fact_appointments` | Appointment, with the analysis bands calculated in SQL |
| Payments | Fact | `fact_payments` | Payment; only the fee is used, to price a missed visit |
| Reminders | Fact | `fact_reminders` | Reminder attempt |
| Telemedicine Sessions | Fact | `fact_telemedicine_sessions` | Video consultation |
| Schedule Sessions | Fact | `fact_schedule_sessions` | Planned doctor session |
| Pilot Assignments | Fact | `fact_reminder_pilot_assignment` | Appointment in the reminder pilot |
| Reporting Weeks | Fact | `fact_reporting_process_log` | Logged weekly reporting cycle |
| Data Quality Issues | Fact | `data_quality_issues` | Issue logged by the pipeline |
| Pilot Stage, Pilot Period, Reporting Step | Helper (hidden) | typed in Power Query | Category rows for the funnel, forest plot and waterfall |
| _Measures | Measures | none | Holds all 84 measures |

Appointment events and feedback stay in the SQL model but are not loaded into Power BI, because it's not part of the objective.

**Relationships.** All one-to-many, single direction. Patient, Clinic, Doctor and Date filter Appointments. Appointments filters Reminders, Payments, Telemedicine Sessions and Pilot Assignments. Clinic, Doctor and Date also filter Schedule Sessions. Reporting Weeks, Data Quality Issues and the helper tables stand alone.

**Hierarchies.** Date: Year › Quarter › Month › Date. Clinic: Division › District › Clinic. Patient: Division › District.

**Measure folders.** Numbered so they list in reading order. Chart helpers sit in subfolders, so each main folder shows the headline metrics first.

| Folder | What is in it |
|---|---|
| 1 Volume | Counts: appointments, patients, clinics, doctors, reminders |
| 2 Attendance | Status counts, no-show rate, repeat, follow-up and telemedicine shares |
| 3 Pre-pilot Baseline | Baseline rates for all clinics (the all-clinic average), semi-urban and urban patients and the pilot segment |
| 4 Reminder Pilot | Pilot rate, reduction, avoided no-shows; subfolders **Groups** (standard and enhanced group figures), **Statistics** (95% interval bounds, p-value), **Forest Plot**, **Pilot Flow** |
| 5 Reporting Efficiency | Minutes before and after, hours saved; subfolder **By Stage** (stage minutes, waterfall, biggest saving) |
| 6 Data Quality | Logged issues by severity, appointments with an invalid date |
| 7 Money Estimates | Average visit fee, missed fees, fees kept; subfolders **Ranges** (95% ranges) and **Helpers** |


### Money estimates

All money figures are estimates in Bangladeshi taka (BDT), and every card that shows one says so.

- **Price of a missed visit** = the average net fee of a completed visit (`Average Visit Fee`, BDT 1,139). No-shows have no payment in this data, so each one is a fee not collected. The average ignores date and patient-area filters, so every estimate uses the same price.
- **Pre-pilot baseline**: baseline no-shows × fee ≈ BDT 3.9M, 56% of it from semi-urban patients.
- **Pilot**: the enhanced group's 622 eligible appointments at the standard group's 26.0% rate would have had about 162 no-shows (≈ BDT 184k). It had 125 (≈ BDT 142k). The difference, ≈ BDT 42k, is the fee kept. Its 95% range comes from the confidence interval: BDT 9k to 75k.
- **Projection**: baseline semi-urban no-shows per year × the 22.7% relative reduction × fee ≈ BDT 0.87M a year (95% range 0.18M to 1.56M), or ≈ BDT 0.44M for morning slots only. The relative reduction is used instead of the 5.9 points because the pilot's standard-group rate (26.0%) was higher than the baseline rate (15.9%).
- **Not included**: the cost of sending reminders, and slots that walk-ins refill. Afternoon slots were not tested in the pilot.

### Pilot statistics

- **Reduction** = standard no-show rate − enhanced no-show rate (5.9 percentage points).
- **95% confidence interval** = reduction ± 1.96 × √(p₁(1−p₁)/n₁ + p₂(1−p₂)/n₂), giving 1.2 to 10.6 points.
- **p-value** comes from a two-sided, two-proportion z-test with a pooled rate (p = 0.013).
