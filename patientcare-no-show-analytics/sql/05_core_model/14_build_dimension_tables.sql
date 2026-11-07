/*
PatientCare Analytics
Script 14: Build the dimension tables

core.dim_date      one row per calendar day + an Unknown row (date_key 0)
core.dim_clinic    14 clinics + Unknown (clinic_key 0)
core.dim_doctor    115 doctors + Unknown (doctor_key 0)
core.dim_patient   34,460 patients + Unknown (patient_key 0)

Why an "Unknown" row?
Some appointments point to a patient or clinic that does not exist, or have no
valid date. Instead of dropping those rows, they are linked to key 0 so they
stay visible in Power BI and totals always add up.

Each dimension also gets data_quality_issue_count from the audit log.
*/

DROP TABLE IF EXISTS core.dim_date;
DROP TABLE IF EXISTS core.dim_clinic;
DROP TABLE IF EXISTS core.dim_doctor;
DROP TABLE IF EXISTS core.dim_patient;

-- ---------------------------------------------------------------------------
-- dim_date
-- Covers every day from the earliest to the latest date found in the data.
-- project_analysis_period labels the windows of the project timeline:
--   Pre-project history   1 Jan 2022 - 2 Oct 2022   before the formal project started
--   Pre-pilot baseline    3 Oct 2022 - 29 Apr 2023  project start to pilot start
--   Pilot                 30 Apr 2023 - 15 Jun 2023 enhanced-reminder pilot (final data cut-off)
-- ---------------------------------------------------------------------------

CREATE TABLE core.dim_date AS
WITH all_business_dates AS (
    SELECT CAST(booked_at AS DATE) AS business_date FROM staging.appointments_clean
    UNION ALL SELECT CAST(scheduled_start_at AS DATE) FROM staging.appointments_clean
    UNION ALL SELECT CAST(scheduled_end_at AS DATE) FROM staging.appointments_clean
    UNION ALL SELECT CAST(check_in_at AS DATE) FROM staging.appointments_clean
    UNION ALL SELECT CAST(consultation_start_at AS DATE) FROM staging.appointments_clean
    UNION ALL SELECT CAST(consultation_end_at AS DATE) FROM staging.appointments_clean
    UNION ALL SELECT CAST(cancellation_at AS DATE) FROM staging.appointments_clean
    UNION ALL SELECT CAST(event_at AS DATE) FROM staging.appointment_events_clean
    UNION ALL SELECT session_date FROM staging.schedule_sessions_clean
    UNION ALL SELECT CAST(scheduled_send_at AS DATE) FROM staging.reminders_clean
    UNION ALL SELECT CAST(sent_at AS DATE) FROM staging.reminders_clean
    UNION ALL SELECT CAST(delivered_at AS DATE) FROM staging.reminders_clean
    UNION ALL SELECT CAST(read_at AS DATE) FROM staging.reminders_clean
    UNION ALL SELECT CAST(scheduled_start_at AS DATE) FROM staging.telemedicine_sessions_clean
    UNION ALL SELECT CAST(patient_join_at AS DATE) FROM staging.telemedicine_sessions_clean
    UNION ALL SELECT CAST(doctor_join_at AS DATE) FROM staging.telemedicine_sessions_clean
    UNION ALL SELECT CAST(session_start_at AS DATE) FROM staging.telemedicine_sessions_clean
    UNION ALL SELECT CAST(session_end_at AS DATE) FROM staging.telemedicine_sessions_clean
    UNION ALL SELECT CAST(transaction_at AS DATE) FROM staging.payments_clean
    UNION ALL SELECT CAST(refund_at AS DATE) FROM staging.payments_clean
    UNION ALL SELECT CAST(survey_sent_at AS DATE) FROM staging.feedback_clean
    UNION ALL SELECT CAST(responded_at AS DATE) FROM staging.feedback_clean
),
calendar AS (
    -- GENERATE_SERIES returns one row per day between the first and last date
    SELECT
        CAST(GENERATE_SERIES(MIN(business_date), MAX(business_date), INTERVAL '1 day') AS DATE) AS full_date
    FROM
        all_business_dates
)
SELECT
    CAST(TO_CHAR(full_date, 'YYYYMMDD') AS INTEGER) AS date_key,
    full_date,
    CAST(EXTRACT(DAY FROM full_date) AS INTEGER) AS day_of_month,
    CAST(EXTRACT(ISODOW FROM full_date) AS INTEGER) AS day_of_week_number,   -- 1 = Monday
    TO_CHAR(full_date, 'FMDay') AS day_name,
    CAST(EXTRACT(WEEK FROM full_date) AS INTEGER) AS iso_week_number,
    CAST(EXTRACT(MONTH FROM full_date) AS INTEGER) AS month_number,
    TO_CHAR(full_date, 'FMMonth') AS month_name,
    TO_CHAR(full_date, 'Mon YYYY') AS month_year,
    CAST(TO_CHAR(full_date, 'YYYYMM') AS INTEGER) AS month_year_sort,
    CAST(EXTRACT(QUARTER FROM full_date) AS INTEGER) AS quarter_number,
    'Q' || EXTRACT(QUARTER FROM full_date) || ' ' || EXTRACT(YEAR FROM full_date) AS quarter_label,
    CAST(EXTRACT(YEAR FROM full_date) AS INTEGER) AS year_number,
    CASE WHEN EXTRACT(ISODOW FROM full_date) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE
        WHEN full_date BETWEEN '2022-01-01' AND '2022-10-02' THEN 'Pre-project history'
        WHEN full_date BETWEEN '2022-10-03' AND '2023-04-29' THEN 'Pre-pilot baseline'
        WHEN full_date BETWEEN '2023-04-30' AND '2023-06-15' THEN 'Pilot'
        ELSE 'Outside analysis window'
    END AS project_analysis_period,
    CASE
        WHEN full_date BETWEEN '2022-01-01' AND '2022-10-02' THEN 1
        WHEN full_date BETWEEN '2022-10-03' AND '2023-04-29' THEN 2
        WHEN full_date BETWEEN '2023-04-30' AND '2023-06-15' THEN 3
        ELSE 4
    END AS project_period_sort
FROM
    calendar;

-- Unknown date row, used when a timestamp is missing or invalid
INSERT INTO core.dim_date
VALUES (0, NULL, NULL, NULL, 'Unknown', NULL, NULL, 'Unknown', 'Unknown', 0, NULL, 'Unknown', NULL, FALSE, 'Unknown', 5);

ALTER TABLE core.dim_date ADD PRIMARY KEY (date_key);

-- ---------------------------------------------------------------------------
-- dim_clinic
-- ---------------------------------------------------------------------------

CREATE TABLE core.dim_clinic AS
WITH issue_counts AS (
    SELECT
        business_key AS clinic_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.clinics'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY clinic.clinic_id) AS clinic_key,
    clinic.clinic_id,
    clinic.clinic_name,
    clinic.facility_type,
    clinic.ownership_model,
    clinic.division,
    clinic.district,
    clinic.city_area,
    clinic.urban_rural,
    clinic.opening_date,
    clinic.operating_start_time,
    clinic.operating_end_time,
    clinic.consultation_room_count,
    clinic.telemedicine_enabled,
    clinic.active_flag,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.clinics_clean AS clinic
LEFT JOIN issue_counts AS issue
    ON issue.clinic_id = clinic.clinic_id;

INSERT INTO core.dim_clinic
VALUES (0, NULL, 'Unknown clinic', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', NULL, NULL, NULL, NULL, NULL, NULL, 0, FALSE);

ALTER TABLE core.dim_clinic ADD PRIMARY KEY (clinic_key);

-- ---------------------------------------------------------------------------
-- dim_doctor
-- ---------------------------------------------------------------------------

CREATE TABLE core.dim_doctor AS
WITH issue_counts AS (
    SELECT
        business_key AS doctor_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.doctors'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY doctor.doctor_id) AS doctor_key,
    doctor.doctor_id,
    doctor.doctor_name,
    doctor.gender,
    doctor.specialty,
    doctor.subspecialty,
    doctor.designation,
    doctor.employment_type,
    COALESCE(clinic.clinic_key, 0) AS primary_clinic_key,
    doctor.primary_clinic_id,
    doctor.joining_date,
    doctor.leaving_date,
    doctor.telemedicine_enabled,
    doctor.standard_consultation_fee_bdt,
    doctor.active_flag,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.doctors_clean AS doctor
LEFT JOIN core.dim_clinic AS clinic
    ON clinic.clinic_id = doctor.primary_clinic_id
LEFT JOIN issue_counts AS issue
    ON issue.doctor_id = doctor.doctor_id;

INSERT INTO core.dim_doctor
VALUES (0, NULL, 'Unknown doctor', 'Unknown', 'Unknown', NULL, 'Unknown', 'Unknown', 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, FALSE);

ALTER TABLE core.dim_doctor ADD PRIMARY KEY (doctor_key);

-- ---------------------------------------------------------------------------
-- dim_patient
-- ---------------------------------------------------------------------------

CREATE TABLE core.dim_patient AS
WITH issue_counts AS (
    SELECT
        business_key AS patient_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.patients'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY patient.patient_id) AS patient_key,
    patient.patient_id,
    patient.registration_date,
    patient.birth_date,
    patient.gender,
    patient.marital_status,
    patient.division,
    patient.district,
    patient.upazila,
    patient.urban_rural,
    patient.preferred_language,
    patient.contact_consent,
    patient.sms_opt_in,
    patient.whatsapp_opt_in,
    patient.chronic_condition_flag,
    patient.chronic_condition_group,
    patient.disability_support_required,
    patient.patient_status,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue,
    CASE
        WHEN patient.chronic_condition_flag IS NULL THEN 'Unknown'
        WHEN patient.chronic_condition_flag = TRUE THEN 'Chronic condition recorded'
        ELSE 'No chronic condition recorded'
    END AS chronic_condition_segment
FROM
    staging.patients_clean AS patient
LEFT JOIN issue_counts AS issue
    ON issue.patient_id = patient.patient_id;

INSERT INTO core.dim_patient
VALUES (0, NULL, NULL, NULL, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', NULL, NULL, NULL, NULL, NULL, NULL, 'Unknown', 0, FALSE, 'Unknown');

ALTER TABLE core.dim_patient ADD PRIMARY KEY (patient_key);

-- check: expected 576, 15, 116, 34461 rows
SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM core.dim_date
UNION ALL SELECT 'dim_clinic', COUNT(*) FROM core.dim_clinic
UNION ALL SELECT 'dim_doctor', COUNT(*) FROM core.dim_doctor
UNION ALL SELECT 'dim_patient', COUNT(*) FROM core.dim_patient;
