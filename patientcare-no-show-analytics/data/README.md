# Data

## About this dataset

This project is the appointment-reporting and reminder-pilot work from my time as a Data Analyst at Fieldbooster (2022–2023). The original operational data is confidential, so the project includes the insights but only a sample of the original dataset, to show the project working. Patients, doctors, all operational records and clinics appear only as anonymised aliases, such as Clinic 01 to Clinic 14 instead of real clinic names.

Data period: 1 January 2022 to 15 June 2023. Timestamps are Bangladesh local time (UTC+6).

## Folders

| Folder | Contents | In the GitHub repo? |
|---|---|---|
| `raw/` | The 12 source extracts (557,423 rows) | No, excluded by `.gitignore` |
| `processed/` | The cleaned core tables exported by `sql/run_all.sql`, read by Power BI | No, excluded by `.gitignore` |
| `sample/raw/` | About 500 appointments and their related rows, in the same format as `raw/` | Yes |
| `sample/processed/` | The same sample after the SQL pipeline, in the same format as `processed/`. Point Power BI's **DataFolder** here to open the report without a database | Yes |

The sample shows the structure of every source file and runs through the whole pipeline. Because it is small, its numbers differ from the full data, and the pilot part (27 appointments) is too small for meaningful statistics. The column-level definitions of the source files are in `docs/source_data_dictionary.csv`.

In `sample/raw/raw_patients.csv`, `birth_date` is reduced to the birth year (always 1 January) and `upazila` (sub-district) is removed.

## Source files

| File | Source system | One row per | Rows |
|---|---|---|---:|
| `raw_clinics.csv` | Clinic operations ERP | Clinic | 14 |
| `raw_doctors.csv` | Clinic operations ERP | Doctor | 115 |
| `raw_patients.csv` | PatientCare PostgreSQL | Patient | 34,460 |
| `raw_appointments.csv` | PatientCare PostgreSQL | Appointment record version | 75,291 |
| `raw_appointment_events.csv` | PatientCare event store | Appointment status change | 257,288 |
| `raw_schedule_sessions.csv` | Clinic roster system | Planned doctor session | 17,788 |
| `raw_reminders.csv` | Messaging gateway API | Reminder attempt | 86,527 |
| `raw_telemedicine_sessions.csv` | PatientCare video event logs | Video consultation | 7,652 |
| `raw_payments.csv` | Billing ERP and payment gateway | Payment record version | 58,354 |
| `raw_feedback.csv` | Patient survey platform | Survey response | 18,509 |
| `raw_reminder_pilot_assignment.csv` | Reminder pilot tracker | Pilot appointment | 1,409 |
| `raw_reporting_process_log.csv` | Reporting time log | Reporting week | 16 |
