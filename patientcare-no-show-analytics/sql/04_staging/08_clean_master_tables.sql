/*
PatientCare Analytics
Script 08: Clean the clinic, doctor and patient master tables

For each table:
- trim text values
- convert text to real data types (DATE, TIME, INTEGER, NUMERIC, BOOLEAN)
- replace inconsistent category spellings with the standard label
- keep raw_row_id as source_raw_row_id so every row can be traced back

The raw tables are never changed.
*/

DROP TABLE IF EXISTS staging.clinics_clean;
DROP TABLE IF EXISTS staging.doctors_clean;
DROP TABLE IF EXISTS staging.patients_clean;

-- ---------------------------------------------------------------------------
-- Clinics (14 rows)
-- ---------------------------------------------------------------------------

CREATE TABLE staging.clinics_clean AS
SELECT
    raw_row_id AS source_raw_row_id,
    TRIM(clinic_id) AS clinic_id,
    TRIM(clinic_name) AS clinic_name,
    TRIM(facility_type_raw) AS facility_type,
    TRIM(ownership_model_raw) AS ownership_model,
    TRIM(division) AS division,
    TRIM(district) AS district,
    TRIM(city_area) AS city_area,
    TRIM(urban_rural) AS urban_rural,
    CAST(opening_date AS DATE) AS opening_date,
    CAST(operating_start_time AS TIME) AS operating_start_time,
    CAST(operating_end_time AS TIME) AS operating_end_time,
    CAST(consultation_room_count AS INTEGER) AS consultation_room_count,
    staging.to_yes_no(telemedicine_enabled_raw) AS telemedicine_enabled,
    staging.to_yes_no(active_flag_raw) AS active_flag,
    CAST(source_updated_at AS TIMESTAMP) AS source_updated_at,
    CAST(ingested_at AS TIMESTAMP) AS ingested_at
FROM
    raw.clinics;

ALTER TABLE staging.clinics_clean ADD PRIMARY KEY (clinic_id);

-- ---------------------------------------------------------------------------
-- Doctors (115 rows)
-- ---------------------------------------------------------------------------

CREATE TABLE staging.doctors_clean AS
SELECT
    doctor.raw_row_id AS source_raw_row_id,
    TRIM(doctor.doctor_id) AS doctor_id,
    TRIM(doctor.doctor_name) AS doctor_name,
    gender_map.standard_value AS gender,
    specialty_map.standard_value AS specialty,
    TRIM(doctor.subspecialty_raw) AS subspecialty,
    TRIM(doctor.designation_raw) AS designation,
    TRIM(doctor.employment_type_raw) AS employment_type,
    TRIM(doctor.primary_clinic_id) AS primary_clinic_id,
    CAST(doctor.joining_date AS DATE) AS joining_date,
    CAST(doctor.leaving_date AS DATE) AS leaving_date,
    staging.to_yes_no(doctor.telemedicine_enabled_raw) AS telemedicine_enabled,
    CAST(doctor.standard_consultation_fee_bdt AS NUMERIC(12, 2)) AS standard_consultation_fee_bdt,
    staging.to_yes_no(doctor.active_flag_raw) AS active_flag,
    CAST(doctor.source_updated_at AS TIMESTAMP) AS source_updated_at,
    CAST(doctor.ingested_at AS TIMESTAMP) AS ingested_at
FROM
    raw.doctors AS doctor
LEFT JOIN staging.category_map AS gender_map
    ON gender_map.category_group = 'gender'
   AND gender_map.source_value = LOWER(TRIM(doctor.gender_raw))
LEFT JOIN staging.category_map AS specialty_map
    ON specialty_map.category_group = 'specialty'
   AND specialty_map.source_value = LOWER(TRIM(doctor.specialty_raw));

ALTER TABLE staging.doctors_clean ADD PRIMARY KEY (doctor_id);

-- ---------------------------------------------------------------------------
-- Patients (34,460 rows)
-- ---------------------------------------------------------------------------

CREATE TABLE staging.patients_clean AS
SELECT
    patient.raw_row_id AS source_raw_row_id,
    TRIM(patient.patient_id) AS patient_id,
    CAST(patient.registration_date AS DATE) AS registration_date,
    CAST(patient.birth_date AS DATE) AS birth_date,
    gender_map.standard_value AS gender,
    TRIM(patient.marital_status_raw) AS marital_status,
    TRIM(patient.division) AS division,
    TRIM(patient.district) AS district,
    TRIM(patient.upazila) AS upazila,
    TRIM(patient.urban_rural) AS urban_rural,
    TRIM(patient.preferred_language_raw) AS preferred_language,
    staging.to_yes_no(patient.contact_consent_raw) AS contact_consent,
    staging.to_yes_no(patient.sms_opt_in_raw) AS sms_opt_in,
    staging.to_yes_no(patient.whatsapp_opt_in_raw) AS whatsapp_opt_in,
    staging.to_yes_no(patient.chronic_condition_flag_raw) AS chronic_condition_flag,
    TRIM(patient.chronic_condition_group_raw) AS chronic_condition_group,
    staging.to_yes_no(patient.disability_support_required_raw) AS disability_support_required,
    status_map.standard_value AS patient_status,
    CAST(patient.source_updated_at AS TIMESTAMP) AS source_updated_at,
    CAST(patient.ingested_at AS TIMESTAMP) AS ingested_at
FROM
    raw.patients AS patient
LEFT JOIN staging.category_map AS gender_map
    ON gender_map.category_group = 'gender'
   AND gender_map.source_value = LOWER(TRIM(patient.gender_raw))
LEFT JOIN staging.category_map AS status_map
    ON status_map.category_group = 'patient_status'
   AND status_map.source_value = LOWER(TRIM(patient.patient_status_raw));

ALTER TABLE staging.patients_clean ADD PRIMARY KEY (patient_id);

-- check: raw rows vs clean rows (should match: 14, 115, 34460)
SELECT 'clinics' AS table_name, (SELECT COUNT(*) FROM raw.clinics) AS raw_rows, (SELECT COUNT(*) FROM staging.clinics_clean) AS clean_rows
UNION ALL SELECT 'doctors', (SELECT COUNT(*) FROM raw.doctors), (SELECT COUNT(*) FROM staging.doctors_clean)
UNION ALL SELECT 'patients', (SELECT COUNT(*) FROM raw.patients), (SELECT COUNT(*) FROM staging.patients_clean);
