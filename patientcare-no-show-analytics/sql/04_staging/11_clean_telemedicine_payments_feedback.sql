/*
PatientCare Analytics
Script 11: Clean telemedicine sessions, payments and patient feedback

Payments work like appointments: the extract has 58,354 rows, of which
136 are duplicate extract copies and 957 are older versions of a payment.
The same two-step de-duplication as script 09 leaves 57,261 current payments.
*/

DROP TABLE IF EXISTS staging.telemedicine_sessions_clean;
DROP TABLE IF EXISTS staging.payments_typed;
DROP TABLE IF EXISTS staging.payments_clean;
DROP TABLE IF EXISTS staging.feedback_clean;

-- ---------------------------------------------------------------------------
-- Telemedicine sessions (7,652 rows)
-- ---------------------------------------------------------------------------

CREATE TABLE staging.telemedicine_sessions_clean AS
SELECT
    session.raw_row_id AS source_raw_row_id,
    TRIM(session.telemedicine_session_id) AS telemedicine_session_id,
    TRIM(session.appointment_id) AS appointment_id,
    TRIM(session.platform_name) AS platform_name,
    CAST(session.scheduled_start_at AS TIMESTAMP) AS scheduled_start_at,
    CAST(session.patient_join_at AS TIMESTAMP) AS patient_join_at,
    CAST(session.doctor_join_at AS TIMESTAMP) AS doctor_join_at,
    CAST(session.session_start_at AS TIMESTAMP) AS session_start_at,
    CAST(session.session_end_at AS TIMESTAMP) AS session_end_at,
    status_map.standard_value AS session_status,
    CAST(session.disconnect_count AS INTEGER) AS disconnect_count,
    CAST(session.average_latency_ms AS INTEGER) AS average_latency_ms,
    CAST(session.audio_quality_score AS NUMERIC(3, 1)) AS audio_quality_score,
    CAST(session.video_quality_score AS NUMERIC(3, 1)) AS video_quality_score,
    staging.to_yes_no(session.technical_issue_flag_raw) AS technical_issue_flag,
    TRIM(session.issue_category_raw) AS issue_category,
    TRIM(session.device_type_raw) AS device_type,
    TRIM(session.network_type_raw) AS network_type,
    staging.to_yes_no(session.recording_consent_raw) AS recording_consent
FROM
    raw.telemedicine_sessions AS session
LEFT JOIN staging.category_map AS status_map
    ON status_map.category_group = 'telemedicine_status'
   AND status_map.source_value = LOWER(TRIM(session.session_status_raw));

ALTER TABLE staging.telemedicine_sessions_clean ADD PRIMARY KEY (telemedicine_session_id);

-- ---------------------------------------------------------------------------
-- Payments step 1: type and standardise every raw row
-- ---------------------------------------------------------------------------

CREATE TABLE staging.payments_typed AS
SELECT
    payment.raw_row_id AS source_raw_row_id,
    TRIM(payment.payment_record_id) AS payment_record_id,
    TRIM(payment.payment_id) AS payment_id,
    CAST(payment.record_version AS INTEGER) AS record_version,
    TRIM(payment.appointment_id) AS appointment_id,
    TRIM(payment.invoice_id) AS invoice_id,
    TRIM(payment.payer_type_raw) AS payer_type,
    TRIM(payment.payment_method_raw) AS payment_method,
    CAST(payment.gross_amount_bdt AS NUMERIC(12, 2)) AS gross_amount_bdt,
    CAST(payment.discount_amount_bdt AS NUMERIC(12, 2)) AS discount_amount_bdt,
    CAST(payment.net_amount_bdt AS NUMERIC(12, 2)) AS net_amount_bdt,
    CAST(payment.amount_paid_bdt AS NUMERIC(12, 2)) AS amount_paid_bdt,
    status_map.standard_value AS payment_status,
    CAST(payment.transaction_at AS TIMESTAMP) AS transaction_at,
    CAST(payment.refund_amount_bdt AS NUMERIC(12, 2)) AS refund_amount_bdt,
    CAST(payment.refund_at AS TIMESTAMP) AS refund_at,
    TRIM(payment.insurance_claim_id) AS insurance_claim_id,
    TRIM(payment.claim_status_raw) AS claim_status,
    CAST(payment.source_updated_at AS TIMESTAMP) AS source_updated_at
FROM
    raw.payments AS payment
LEFT JOIN staging.category_map AS status_map
    ON status_map.category_group = 'payment_status'
   AND status_map.source_value = LOWER(TRIM(payment.payment_status_raw));

-- ---------------------------------------------------------------------------
-- Payments step 2: one row per payment (latest version, no duplicate copies)
-- ---------------------------------------------------------------------------

CREATE TABLE staging.payments_clean AS
WITH numbered_copies AS (
    SELECT
        typed.*,
        ROW_NUMBER() OVER (
            PARTITION BY payment_record_id
            ORDER BY source_raw_row_id
        ) AS copy_number
    FROM
        staging.payments_typed AS typed
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
        COUNT(*) OVER (PARTITION BY payment_id) AS available_version_count,
        ROW_NUMBER() OVER (
            PARTITION BY payment_id
            ORDER BY
                record_version DESC,
                source_updated_at DESC,
                source_raw_row_id DESC
        ) AS version_rank
    FROM
        unique_versions
)
SELECT
    source_raw_row_id,
    payment_record_id,
    payment_id,
    record_version,
    available_version_count,
    appointment_id,
    invoice_id,
    payer_type,
    payment_method,
    gross_amount_bdt,
    discount_amount_bdt,
    net_amount_bdt,
    amount_paid_bdt,
    payment_status,
    transaction_at,
    refund_amount_bdt,
    refund_at,
    insurance_claim_id,
    claim_status
FROM
    ranked_versions
WHERE
    version_rank = 1;

ALTER TABLE staging.payments_clean ADD PRIMARY KEY (payment_id);

-- ---------------------------------------------------------------------------
-- Patient feedback surveys (18,509 rows)
-- ---------------------------------------------------------------------------

CREATE TABLE staging.feedback_clean AS
SELECT
    raw_row_id AS source_raw_row_id,
    TRIM(survey_id) AS survey_id,
    TRIM(appointment_id) AS appointment_id,
    TRIM(patient_id) AS patient_id,
    CAST(survey_sent_at AS TIMESTAMP) AS survey_sent_at,
    CAST(responded_at AS TIMESTAMP) AS responded_at,
    CAST(overall_rating AS INTEGER) AS overall_rating,
    CAST(wait_time_rating AS INTEGER) AS wait_time_rating,
    CAST(doctor_rating AS INTEGER) AS doctor_rating,
    CAST(booking_experience_rating AS INTEGER) AS booking_experience_rating,
    CAST(telemedicine_rating AS INTEGER) AS telemedicine_rating,
    CAST(recommend_score_nps AS INTEGER) AS recommend_score_nps,
    staging.to_yes_no(complaint_flag_raw) AS complaint_flag,
    TRIM(complaint_category_raw) AS complaint_category,
    staging.to_yes_no(follow_up_required_raw) AS follow_up_required
FROM
    raw.feedback;

ALTER TABLE staging.feedback_clean ADD PRIMARY KEY (survey_id);

-- check: raw rows vs clean rows
SELECT 'telemedicine_sessions' AS table_name, (SELECT COUNT(*) FROM raw.telemedicine_sessions) AS raw_rows, (SELECT COUNT(*) FROM staging.telemedicine_sessions_clean) AS clean_rows
UNION ALL SELECT 'payments', (SELECT COUNT(*) FROM raw.payments), (SELECT COUNT(*) FROM staging.payments_clean)
UNION ALL SELECT 'feedback', (SELECT COUNT(*) FROM raw.feedback), (SELECT COUNT(*) FROM staging.feedback_clean);
