/*
PatientCare Analytics
Script 18: Export the core model to CSV for Power BI

BEFORE RUNNING: replace /PATH/TO/patientcare-no-show-analytics with the full path of
the project folder, the same way as in script 04.

Files are written to data/processed/. Power BI reads them from there.
The data/processed folder must already exist (it is part of the project).
*/

-- 14 reporting tables

COPY (SELECT * FROM core.dim_date ORDER BY date_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/dim_date.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.dim_clinic ORDER BY clinic_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/dim_clinic.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.dim_doctor ORDER BY doctor_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/dim_doctor.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.dim_patient ORDER BY patient_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/dim_patient.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_appointments ORDER BY appointment_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_appointments.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_appointment_events ORDER BY event_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_appointment_events.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_schedule_sessions ORDER BY schedule_session_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_schedule_sessions.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_reminders ORDER BY reminder_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_reminders.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_telemedicine_sessions ORDER BY telemedicine_session_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_telemedicine_sessions.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_payments ORDER BY payment_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_payments.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_feedback ORDER BY feedback_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_feedback.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_reminder_pilot_assignment ORDER BY pilot_assignment_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_reminder_pilot_assignment.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.fact_reporting_process_log ORDER BY reporting_log_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/fact_reporting_process_log.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY (SELECT * FROM core.data_quality_issues ORDER BY data_quality_issue_key)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/data_quality_issues.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

-- column list of every core table (a simple data dictionary)
COPY (SELECT table_name, ordinal_position, column_name, data_type FROM information_schema.columns WHERE table_schema = 'core' ORDER BY table_name, ordinal_position)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/core_columns.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

-- validation results, kept next to the exported files
COPY (SELECT test_group, test_name, actual_value, expected_value, test_result FROM audit.core_model_validation ORDER BY test_group, test_name)
TO '/PATH/TO/patientcare-no-show-analytics/data/processed/validation_results.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

SELECT 'Export complete: files written to data/processed/' AS status;
