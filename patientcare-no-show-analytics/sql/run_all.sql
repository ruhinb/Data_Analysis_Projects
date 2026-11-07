/*
PatientCare Analytics
Run the whole pipeline from a terminal with psql (optional)

In VS Code with SQLTools, open and run scripts 01 to 18 one by one instead
(see sql/README.md). This file is a shortcut for the same steps in psql.

Before running, replace /PATH/TO/patientcare-no-show-analytics in scripts 04 and 18
with your project folder. Then, from the project root folder, run:

    psql -d postgres -f sql/run_all.sql

This creates (or recreates) the patientcare_analytics database, loads the raw
CSV files, cleans them, builds the core model, validates it and exports the
reporting CSVs to data/processed/. It takes about 1-2 minutes.
*/

\set ON_ERROR_STOP on

\echo '01 create database'
\ir 01_setup/01_create_database.sql
\connect patientcare_analytics

\echo '02 create schemas'
\ir 01_setup/02_create_schemas.sql

\echo '03-04 load raw CSV files'
\ir 02_raw_load/03_create_raw_tables.sql
\ir 02_raw_load/04_load_raw_csv_files.sql

\echo '05-06 profile raw data'
\ir 03_data_profiling/05_check_raw_row_counts_and_keys.sql
\ir 03_data_profiling/06_profile_raw_values.sql

\echo '07-13 clean into staging and log data-quality issues'
\ir 04_staging/07_create_cleaning_helpers.sql
\ir 04_staging/08_clean_master_tables.sql
\ir 04_staging/09_clean_and_deduplicate_appointments.sql
\ir 04_staging/10_clean_operational_tables.sql
\ir 04_staging/11_clean_telemedicine_payments_feedback.sql
\ir 04_staging/12_clean_pilot_and_reporting_logs.sql
\ir 04_staging/13_log_data_quality_issues.sql

\echo '14-16 build core star schema'
\ir 05_core_model/14_build_dimension_tables.sql
\ir 05_core_model/15_build_fact_tables.sql
\ir 05_core_model/16_build_pilot_and_reporting_facts.sql

\echo '17-18 validate and export'
\ir 06_validation_export/17_validate_core_model.sql
\ir 06_validation_export/18_export_core_tables.sql
