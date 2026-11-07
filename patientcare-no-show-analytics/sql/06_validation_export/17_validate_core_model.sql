/*
PatientCare Analytics
Script 17: Validate the finished core model before exporting it

Each row is one test with the value found and the value expected.
All rows should show PASS. Results are kept in audit.core_model_validation.

Groups of tests:
1. Row counts      every table has the expected number of rows
2. Unique keys     no business ID appears twice
3. Relationships   every fact row links to a dimension row (Unknown = 0 counts)
4. Unknown rows    known bad references are kept, not dropped
5. Mappings        no category spelling was left unmapped
6. Dates           the calendar has no missing days
*/

DROP TABLE IF EXISTS audit.core_model_validation;

CREATE TABLE audit.core_model_validation AS
WITH checks AS (

    -- 1. Row counts ----------------------------------------------------------
    SELECT 'Row counts' AS test_group, 'dim_date rows' AS test_name, (SELECT COUNT(*) FROM core.dim_date) AS actual_value, 576 AS expected_value
    UNION ALL SELECT 'Row counts', 'dim_clinic rows', (SELECT COUNT(*) FROM core.dim_clinic), 15
    UNION ALL SELECT 'Row counts', 'dim_doctor rows', (SELECT COUNT(*) FROM core.dim_doctor), 116
    UNION ALL SELECT 'Row counts', 'dim_patient rows', (SELECT COUNT(*) FROM core.dim_patient), 34461
    UNION ALL SELECT 'Row counts', 'fact_appointments rows', (SELECT COUNT(*) FROM core.fact_appointments), 73715
    UNION ALL SELECT 'Row counts', 'fact_appointment_events rows', (SELECT COUNT(*) FROM core.fact_appointment_events), 257288
    UNION ALL SELECT 'Row counts', 'fact_schedule_sessions rows', (SELECT COUNT(*) FROM core.fact_schedule_sessions), 17788
    UNION ALL SELECT 'Row counts', 'fact_reminders rows', (SELECT COUNT(*) FROM core.fact_reminders), 86527
    UNION ALL SELECT 'Row counts', 'fact_telemedicine_sessions rows', (SELECT COUNT(*) FROM core.fact_telemedicine_sessions), 7652
    UNION ALL SELECT 'Row counts', 'fact_payments rows', (SELECT COUNT(*) FROM core.fact_payments), 57261
    UNION ALL SELECT 'Row counts', 'fact_feedback rows', (SELECT COUNT(*) FROM core.fact_feedback), 18509
    UNION ALL SELECT 'Row counts', 'fact_reminder_pilot_assignment rows', (SELECT COUNT(*) FROM core.fact_reminder_pilot_assignment), 1409
    UNION ALL SELECT 'Row counts', 'fact_reporting_process_log rows', (SELECT COUNT(*) FROM core.fact_reporting_process_log), 16
    UNION ALL SELECT 'Row counts', 'data_quality_issues rows', (SELECT COUNT(*) FROM core.data_quality_issues), 4342

    -- 2. Unique keys (expected 0 duplicates) ---------------------------------
    UNION ALL SELECT 'Unique keys', 'duplicate appointment_id', (SELECT COUNT(*) - COUNT(DISTINCT appointment_id) FROM core.fact_appointments), 0
    UNION ALL SELECT 'Unique keys', 'duplicate patient_id', (SELECT COUNT(*) - COUNT(DISTINCT patient_id) - 1 FROM core.dim_patient), 0
    UNION ALL SELECT 'Unique keys', 'duplicate clinic_id', (SELECT COUNT(*) - COUNT(DISTINCT clinic_id) - 1 FROM core.dim_clinic), 0
    UNION ALL SELECT 'Unique keys', 'duplicate doctor_id', (SELECT COUNT(*) - COUNT(DISTINCT doctor_id) - 1 FROM core.dim_doctor), 0
    UNION ALL SELECT 'Unique keys', 'duplicate payment_id', (SELECT COUNT(*) - COUNT(DISTINCT payment_id) FROM core.fact_payments), 0
    UNION ALL SELECT 'Unique keys', 'duplicate reminder_id', (SELECT COUNT(*) - COUNT(DISTINCT reminder_id) FROM core.fact_reminders), 0
    UNION ALL SELECT 'Unique keys', 'duplicate pilot appointment_id', (SELECT COUNT(*) - COUNT(DISTINCT appointment_id) FROM core.fact_reminder_pilot_assignment), 0

    -- 3. Relationships (expected 0 rows without a match) ---------------------
    UNION ALL
    SELECT 'Relationships', 'appointments without a patient row', COUNT(*), 0
    FROM core.fact_appointments AS fact
    LEFT JOIN core.dim_patient AS dim ON dim.patient_key = fact.patient_key
    WHERE dim.patient_key IS NULL

    UNION ALL
    SELECT 'Relationships', 'appointments without a clinic row', COUNT(*), 0
    FROM core.fact_appointments AS fact
    LEFT JOIN core.dim_clinic AS dim ON dim.clinic_key = fact.clinic_key
    WHERE dim.clinic_key IS NULL

    UNION ALL
    SELECT 'Relationships', 'appointments without a doctor row', COUNT(*), 0
    FROM core.fact_appointments AS fact
    LEFT JOIN core.dim_doctor AS dim ON dim.doctor_key = fact.doctor_key
    WHERE dim.doctor_key IS NULL

    UNION ALL
    SELECT 'Relationships', 'appointments without a scheduled date row', COUNT(*), 0
    FROM core.fact_appointments AS fact
    LEFT JOIN core.dim_date AS dim ON dim.date_key = fact.scheduled_date_key
    WHERE dim.date_key IS NULL

    UNION ALL
    SELECT 'Relationships', 'schedule sessions without a date row', COUNT(*), 0
    FROM core.fact_schedule_sessions AS fact
    LEFT JOIN core.dim_date AS dim ON dim.date_key = fact.session_date_key
    WHERE dim.date_key IS NULL

    UNION ALL
    SELECT 'Relationships', 'pilot rows without an appointment', COUNT(*), 0
    FROM core.fact_reminder_pilot_assignment
    WHERE appointment_key = 0

    UNION ALL
    SELECT 'Relationships', 'pilot rows outside the target segment', COUNT(*), 0
    FROM core.fact_reminder_pilot_assignment AS pilot
    INNER JOIN core.fact_appointments AS appointment ON appointment.appointment_key = pilot.appointment_key
    WHERE appointment.pilot_target_segment <> 'Target: Semi-urban morning'

    -- 4. Unknown rows kept on purpose ----------------------------------------
    UNION ALL SELECT 'Unknown rows', 'appointments with unknown patient', (SELECT COUNT(*) FROM core.fact_appointments WHERE patient_key = 0), 44
    UNION ALL SELECT 'Unknown rows', 'appointments with unknown clinic', (SELECT COUNT(*) FROM core.fact_appointments WHERE clinic_key = 0), 41
    UNION ALL SELECT 'Unknown rows', 'appointments with unknown doctor', (SELECT COUNT(*) FROM core.fact_appointments WHERE doctor_key = 0), 220
    UNION ALL SELECT 'Unknown rows', 'appointments with unknown scheduled date', (SELECT COUNT(*) FROM core.fact_appointments WHERE scheduled_date_key = 0), 23

    -- 5. Category mappings (expected 0 values left without a standard label) --
    UNION ALL SELECT 'Mappings', 'unmapped appointment status', (SELECT COUNT(*) FROM core.fact_appointments WHERE appointment_status IS NULL), 0
    UNION ALL SELECT 'Mappings', 'unmapped booking channel', (SELECT COUNT(*) FROM core.fact_appointments WHERE booking_channel IS NULL), 0
    UNION ALL SELECT 'Mappings', 'unmapped consultation mode', (SELECT COUNT(*) FROM core.fact_appointments WHERE consultation_mode IS NULL), 0
    UNION ALL SELECT 'Mappings', 'unmapped visit type', (SELECT COUNT(*) FROM core.fact_appointments WHERE visit_type IS NULL), 0
    UNION ALL SELECT 'Mappings', 'unmapped reminder delivery status', (SELECT COUNT(*) FROM core.fact_reminders WHERE delivery_status IS NULL), 0
    UNION ALL SELECT 'Mappings', 'unmapped payment status', (SELECT COUNT(*) FROM core.fact_payments WHERE payment_status IS NULL), 0
    UNION ALL SELECT 'Mappings', 'unmapped telemedicine status', (SELECT COUNT(*) FROM core.fact_telemedicine_sessions WHERE session_status IS NULL), 0

    -- 6. Dates ---------------------------------------------------------------
    UNION ALL SELECT 'Dates', 'missing days in calendar', (SELECT MAX(full_date) - MIN(full_date) + 1 - COUNT(full_date) FROM core.dim_date), 0
    UNION ALL SELECT 'Dates', 'unknown date rows', (SELECT COUNT(*) FROM core.dim_date WHERE date_key = 0), 1
)
SELECT
    test_group,
    test_name,
    actual_value,
    expected_value,
    CASE
        WHEN actual_value = expected_value THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result,
    CURRENT_TIMESTAMP AS tested_at
FROM
    checks;

-- full results
SELECT
    test_group,
    test_name,
    actual_value,
    expected_value,
    test_result
FROM
    audit.core_model_validation
ORDER BY
    test_group,
    test_name;

-- summary: expected 0 failed tests
SELECT
    COUNT(*) AS total_tests,
    SUM(CASE WHEN test_result = 'PASS' THEN 1 ELSE 0 END) AS passed,
    SUM(CASE WHEN test_result = 'FAIL' THEN 1 ELSE 0 END) AS failed
FROM
    audit.core_model_validation;
