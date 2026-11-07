/*
PatientCare Analytics
Script 05: Check the raw load before any cleaning

Answers four questions about the raw data:
1. Did every file load the expected number of rows?
2. Are the master IDs (clinic, doctor, patient) unique?
3. How many appointment rows are duplicates or older versions?
4. Do appointments point to patients, clinics and doctors that exist?

Results are saved in audit.raw_row_count_check so they can be reviewed later.
Nothing in the data is changed by this script.
*/

-- ---------------------------------------------------------------------------
-- 1. Expected vs loaded row counts
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS audit.raw_row_count_check;

CREATE TABLE audit.raw_row_count_check AS
WITH loaded AS (
    SELECT 'clinics' AS table_name, 14 AS expected_rows, COUNT(*) AS loaded_rows FROM raw.clinics
    UNION ALL SELECT 'doctors', 115, COUNT(*) FROM raw.doctors
    UNION ALL SELECT 'patients', 34460, COUNT(*) FROM raw.patients
    UNION ALL SELECT 'appointments', 75291, COUNT(*) FROM raw.appointments
    UNION ALL SELECT 'appointment_events', 257288, COUNT(*) FROM raw.appointment_events
    UNION ALL SELECT 'schedule_sessions', 17788, COUNT(*) FROM raw.schedule_sessions
    UNION ALL SELECT 'reminders', 86527, COUNT(*) FROM raw.reminders
    UNION ALL SELECT 'telemedicine_sessions', 7652, COUNT(*) FROM raw.telemedicine_sessions
    UNION ALL SELECT 'payments', 58354, COUNT(*) FROM raw.payments
    UNION ALL SELECT 'feedback', 18509, COUNT(*) FROM raw.feedback
    UNION ALL SELECT 'reminder_pilot_assignment', 1409, COUNT(*) FROM raw.reminder_pilot_assignment
    UNION ALL SELECT 'reporting_process_log', 16, COUNT(*) FROM raw.reporting_process_log
)
SELECT
    table_name,
    expected_rows,
    loaded_rows,
    CASE
        WHEN loaded_rows = expected_rows THEN 'PASS'
        ELSE 'FAIL'
    END AS check_result
FROM
    loaded;

SELECT
    *
FROM
    audit.raw_row_count_check
ORDER BY
    table_name;

-- ---------------------------------------------------------------------------
-- 2. Master IDs must be unique and never blank
-- ---------------------------------------------------------------------------

SELECT
    'clinic_id' AS id_checked,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT clinic_id) AS distinct_ids,
    SUM(CASE WHEN clinic_id IS NULL THEN 1 ELSE 0 END) AS blank_ids
FROM
    raw.clinics

UNION ALL

SELECT
    'doctor_id',
    COUNT(*),
    COUNT(DISTINCT doctor_id),
    SUM(CASE WHEN doctor_id IS NULL THEN 1 ELSE 0 END)
FROM
    raw.doctors

UNION ALL

SELECT
    'patient_id',
    COUNT(*),
    COUNT(DISTINCT patient_id),
    SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END)
FROM
    raw.patients;

-- expected: total_rows = distinct_ids and blank_ids = 0 for all three

-- ---------------------------------------------------------------------------
-- 3. Appointment duplicates and versions
--    appointment_record_id identifies one version of an appointment.
--    The same record_id appearing twice is a duplicate extract row.
--    The same appointment_id with several record_ids means it was updated.
-- ---------------------------------------------------------------------------

SELECT
    COUNT(*) AS raw_rows,                                                      -- 75,291
    COUNT(DISTINCT appointment_record_id) AS distinct_versions,                 -- 75,025
    COUNT(*) - COUNT(DISTINCT appointment_record_id) AS duplicate_extract_rows, -- 266
    COUNT(DISTINCT appointment_id) AS distinct_appointments,                   -- 73,715
    SUM(CASE WHEN doctor_id IS NULL THEN 1 ELSE 0 END) AS blank_doctor_ids     -- 226
FROM
    raw.appointments;

-- ---------------------------------------------------------------------------
-- 4. Appointment references that do not match a master record
-- ---------------------------------------------------------------------------

SELECT
    'patient not found' AS check_name,
    COUNT(*) AS appointment_rows        -- 45
FROM
    raw.appointments AS appointment
LEFT JOIN raw.patients AS patient
    ON appointment.patient_id = patient.patient_id
WHERE
    appointment.patient_id IS NOT NULL
    AND patient.patient_id IS NULL

UNION ALL

SELECT
    'clinic not found',
    COUNT(*)                            -- 42
FROM
    raw.appointments AS appointment
LEFT JOIN raw.clinics AS clinic
    ON appointment.clinic_id = clinic.clinic_id
WHERE
    appointment.clinic_id IS NOT NULL
    AND clinic.clinic_id IS NULL

UNION ALL

SELECT
    'doctor not found',
    COUNT(*)                            -- 0 (missing doctors are blank, not wrong)
FROM
    raw.appointments AS appointment
LEFT JOIN raw.doctors AS doctor
    ON appointment.doctor_id = doctor.doctor_id
WHERE
    appointment.doctor_id IS NOT NULL
    AND doctor.doctor_id IS NULL;

-- ---------------------------------------------------------------------------
-- 5. Child tables must point to a known appointment (all should be 0)
-- ---------------------------------------------------------------------------

WITH appointment_ids AS (
    SELECT DISTINCT
        appointment_id
    FROM
        raw.appointments
)
SELECT
    'appointment_events' AS child_table,
    COUNT(*) AS rows_without_appointment
FROM
    raw.appointment_events AS child
LEFT JOIN appointment_ids AS parent
    ON child.appointment_id = parent.appointment_id
WHERE
    parent.appointment_id IS NULL

UNION ALL

SELECT
    'reminders',
    COUNT(*)
FROM
    raw.reminders AS child
LEFT JOIN appointment_ids AS parent
    ON child.appointment_id = parent.appointment_id
WHERE
    parent.appointment_id IS NULL

UNION ALL

SELECT
    'telemedicine_sessions',
    COUNT(*)
FROM
    raw.telemedicine_sessions AS child
LEFT JOIN appointment_ids AS parent
    ON child.appointment_id = parent.appointment_id
WHERE
    parent.appointment_id IS NULL

UNION ALL

SELECT
    'payments',
    COUNT(*)
FROM
    raw.payments AS child
LEFT JOIN appointment_ids AS parent
    ON child.appointment_id = parent.appointment_id
WHERE
    parent.appointment_id IS NULL

UNION ALL

SELECT
    'feedback',
    COUNT(*)
FROM
    raw.feedback AS child
LEFT JOIN appointment_ids AS parent
    ON child.appointment_id = parent.appointment_id
WHERE
    parent.appointment_id IS NULL

UNION ALL

SELECT
    'reminder_pilot_assignment',
    COUNT(*)
FROM
    raw.reminder_pilot_assignment AS child
LEFT JOIN appointment_ids AS parent
    ON child.appointment_id = parent.appointment_id
WHERE
    parent.appointment_id IS NULL;
