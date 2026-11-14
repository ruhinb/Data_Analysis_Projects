/*
PatientCare Analytics
Script 09: Clean and de-duplicate appointments

The appointment extract has 75,291 rows but only 73,715 real appointments:
- 266 rows are exact duplicate extract copies (same appointment_record_id twice)
- 1,310 rows are older versions of an appointment that was later updated

Steps:
1. appointments_typed  every raw row with clean types and standard labels
2. appointments_clean  one row per appointment, the latest version only

Latest version = highest record_version, then latest source_updated_at,
then highest raw_row_id as a final tie-breaker.
*/

DROP TABLE IF EXISTS staging.appointments_typed;
DROP TABLE IF EXISTS staging.appointments_clean;

-- ---------------------------------------------------------------------------
-- Step 1: type and standardise every raw row
-- ---------------------------------------------------------------------------

CREATE TABLE staging.appointments_typed AS
SELECT
    appointment.raw_row_id AS source_raw_row_id,
    TRIM(appointment.appointment_record_id) AS appointment_record_id,
    TRIM(appointment.appointment_id) AS appointment_id,
    CAST(appointment.record_version AS INTEGER) AS record_version,
    TRIM(appointment.patient_id) AS patient_id,
    TRIM(appointment.clinic_id) AS clinic_id,
    TRIM(appointment.doctor_id) AS doctor_id,
    specialty_map.standard_value AS specialty,
    CAST(appointment.booked_at AS TIMESTAMP) AS booked_at,
    -- every valid value looks like 'YYYY-MM-DD HH:MM:SS'. 24 rows contain
    -- '31/02/2023 09:00' (not a real date). They become NULL instead of
    -- stopping the script. After de-duplication they are 23 appointments,
    -- which script 13 logs.
    CASE
        WHEN appointment.scheduled_start_at LIKE '____-__-__ __:__:__'
        THEN CAST(appointment.scheduled_start_at AS TIMESTAMP)
        ELSE NULL
    END AS scheduled_start_at,
    CAST(appointment.scheduled_end_at AS TIMESTAMP) AS scheduled_end_at,
    CAST(appointment.check_in_at AS TIMESTAMP) AS check_in_at,
    CAST(appointment.consultation_start_at AS TIMESTAMP) AS consultation_start_at,
    CAST(appointment.consultation_end_at AS TIMESTAMP) AS consultation_end_at,
    status_map.standard_value AS appointment_status,
    channel_map.standard_value AS booking_channel,
    mode_map.standard_value AS consultation_mode,
    visit_map.standard_value AS visit_type,
    priority_map.standard_value AS priority_level,
    TRIM(appointment.reason_code_raw) AS reason_code,
    staging.to_yes_no(appointment.is_follow_up_raw) AS is_follow_up,
    TRIM(appointment.parent_appointment_id) AS parent_appointment_id,
    TRIM(appointment.referral_source_raw) AS referral_source,
    CAST(appointment.cancellation_at AS TIMESTAMP) AS cancellation_at,
    TRIM(appointment.cancellation_reason_raw) AS cancellation_reason,
    TRIM(appointment.rescheduled_from_appointment_id) AS rescheduled_from_appointment_id,
    TRIM(appointment.source_system) AS source_system,
    CAST(appointment.source_created_at AS TIMESTAMP) AS source_created_at,
    CAST(appointment.source_updated_at AS TIMESTAMP) AS source_updated_at,
    TRIM(appointment.batch_id) AS batch_id
FROM
    raw.appointments AS appointment
LEFT JOIN staging.category_map AS specialty_map
    ON specialty_map.category_group = 'specialty'
   AND specialty_map.source_value = LOWER(TRIM(appointment.specialty_raw))
LEFT JOIN staging.category_map AS status_map
    ON status_map.category_group = 'appointment_status'
   AND status_map.source_value = LOWER(TRIM(appointment.appointment_status_raw))
LEFT JOIN staging.category_map AS channel_map
    ON channel_map.category_group = 'booking_channel'
   AND channel_map.source_value = LOWER(TRIM(appointment.booking_channel_raw))
LEFT JOIN staging.category_map AS mode_map
    ON mode_map.category_group = 'consultation_mode'
   AND mode_map.source_value = LOWER(TRIM(appointment.consultation_mode_raw))
LEFT JOIN staging.category_map AS visit_map
    ON visit_map.category_group = 'visit_type'
   AND visit_map.source_value = LOWER(TRIM(appointment.visit_type_raw))
LEFT JOIN staging.category_map AS priority_map
    ON priority_map.category_group = 'priority_level'
   AND priority_map.source_value = LOWER(TRIM(appointment.priority_level_raw));

-- ---------------------------------------------------------------------------
-- Step 2: keep one row per appointment (latest version, no duplicate copies)
-- ---------------------------------------------------------------------------

CREATE TABLE staging.appointments_clean AS
WITH numbered_copies AS (
    -- the same appointment_record_id more than once = duplicate extract row,
    -- copy_number 1 is the first copy in the file and is the one we keep
    SELECT
        typed.*,
        ROW_NUMBER() OVER (
            PARTITION BY appointment_record_id
            ORDER BY source_raw_row_id
        ) AS copy_number
    FROM
        staging.appointments_typed AS typed
),
unique_versions AS (
    SELECT
        *
    FROM
        numbered_copies
    WHERE
        copy_number = 1
),
ranked_versions AS (
    SELECT
        unique_versions.*,
        COUNT(*) OVER (PARTITION BY appointment_id) AS available_version_count,
        ROW_NUMBER() OVER (
            PARTITION BY appointment_id
            ORDER BY
                record_version DESC,
                source_updated_at DESC,
                source_raw_row_id DESC
        ) AS version_rank
    FROM
        unique_versions
)
SELECT
    appointment.source_raw_row_id,
    appointment.appointment_record_id,
    appointment.appointment_id,
    appointment.record_version,
    appointment.available_version_count,
    appointment.patient_id,
    appointment.clinic_id,
    appointment.doctor_id,
    appointment.specialty,
    appointment.booked_at,
    appointment.scheduled_start_at,
    appointment.scheduled_end_at,
    appointment.check_in_at,
    appointment.consultation_start_at,
    appointment.consultation_end_at,
    appointment.appointment_status,
    appointment.booking_channel,
    appointment.consultation_mode,
    appointment.visit_type,
    appointment.priority_level,
    appointment.reason_code,
    appointment.is_follow_up,
    appointment.parent_appointment_id,
    appointment.referral_source,
    appointment.cancellation_at,
    appointment.cancellation_reason,
    appointment.rescheduled_from_appointment_id,
    appointment.source_system,
    appointment.source_created_at,
    appointment.source_updated_at,
    -- reference flags: does the ID exist in the cleaned master table?
    CASE WHEN patient.patient_id IS NOT NULL THEN TRUE ELSE FALSE END AS patient_reference_valid,
    CASE WHEN clinic.clinic_id IS NOT NULL THEN TRUE ELSE FALSE END AS clinic_reference_valid,
    CASE WHEN doctor.doctor_id IS NOT NULL THEN TRUE ELSE FALSE END AS doctor_reference_valid,
    CASE WHEN appointment.scheduled_start_at IS NOT NULL THEN TRUE ELSE FALSE END AS scheduled_start_valid
FROM
    ranked_versions AS appointment
LEFT JOIN staging.patients_clean AS patient
    ON patient.patient_id = appointment.patient_id
LEFT JOIN staging.clinics_clean AS clinic
    ON clinic.clinic_id = appointment.clinic_id
LEFT JOIN staging.doctors_clean AS doctor
    ON doctor.doctor_id = appointment.doctor_id
WHERE
    appointment.version_rank = 1;

ALTER TABLE staging.appointments_clean ADD PRIMARY KEY (appointment_id);

-- check: 75,291 raw rows -> 73,715 clean appointments
SELECT
    (SELECT COUNT(*) FROM staging.appointments_typed) AS raw_rows,
    (SELECT COUNT(DISTINCT appointment_record_id) FROM staging.appointments_typed) AS unique_versions,
    (SELECT COUNT(*) FROM staging.appointments_clean) AS clean_appointments;
