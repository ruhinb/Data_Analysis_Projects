/*
PatientCare Analytics
Script 15: Build the fact tables

core.fact_appointments            one row per appointment (73,715) - the centre of the model
core.fact_appointment_events      one row per status change
core.fact_schedule_sessions       one row per planned doctor session
core.fact_reminders               one row per reminder attempt
core.fact_telemedicine_sessions   one row per video consultation
core.fact_payments                one row per current payment
core.fact_feedback                one row per patient survey
core.data_quality_issues          the issue log, copied for reporting

Every fact gets surrogate keys that link to the dimensions (0 = Unknown)
and a date_key in YYYYMMDD format that links to dim_date.

fact_appointments also gets the analysis columns that used to be DAX
calculated columns in Power BI (lead time, time band, age band, pilot
target segment and reminder delivery group). Calculating them once here
keeps the Power BI model smaller and faster.
*/

DROP TABLE IF EXISTS core.fact_appointments;
DROP TABLE IF EXISTS core.fact_appointment_events;
DROP TABLE IF EXISTS core.fact_schedule_sessions;
DROP TABLE IF EXISTS core.fact_reminders;
DROP TABLE IF EXISTS core.fact_telemedicine_sessions;
DROP TABLE IF EXISTS core.fact_payments;
DROP TABLE IF EXISTS core.fact_feedback;
DROP TABLE IF EXISTS core.data_quality_issues;

-- ---------------------------------------------------------------------------
-- fact_appointments
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_appointments AS
WITH issue_counts AS (
    SELECT
        business_key AS appointment_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.appointments'
    GROUP BY
        business_key
),
reminder_summary AS (
    -- one row per appointment: how many reminders, how many delivered / failed
    SELECT
        appointment_id,
        COUNT(*) AS reminder_count,
        SUM(CASE WHEN delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_count,
        SUM(CASE WHEN delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count
    FROM
        staging.reminders_clean
    GROUP BY
        appointment_id
),
appointment_base AS (
    SELECT
        appointment.*,
        COALESCE(patient.patient_key, 0) AS patient_key,
        COALESCE(clinic.clinic_key, 0) AS clinic_key,
        COALESCE(doctor.doctor_key, 0) AS doctor_key,
        patient.birth_date,
        patient.urban_rural AS patient_urban_rural,
        COALESCE(issue.issue_count, 0) AS issue_count,
        reminder.reminder_count,
        reminder.delivered_count,
        reminder.failed_count,
        EXTRACT(HOUR FROM appointment.scheduled_start_at) AS scheduled_hour,
        -- days between booking and the appointment (blank if the dates are missing or reversed)
        CASE
            WHEN appointment.booked_at IS NULL
              OR appointment.scheduled_start_at IS NULL
              OR appointment.scheduled_start_at < appointment.booked_at
            THEN NULL
            ELSE CAST(appointment.scheduled_start_at AS DATE) - CAST(appointment.booked_at AS DATE)
        END AS lead_time_days,
        -- patient age in whole years on the appointment date
        CAST(DATE_PART('year', AGE(CAST(appointment.scheduled_start_at AS DATE), patient.birth_date)) AS INTEGER) AS calculated_age
    FROM
        staging.appointments_clean AS appointment
    LEFT JOIN core.dim_patient AS patient
        ON patient.patient_id = appointment.patient_id
    LEFT JOIN core.dim_clinic AS clinic
        ON clinic.clinic_id = appointment.clinic_id
    LEFT JOIN core.dim_doctor AS doctor
        ON doctor.doctor_id = appointment.doctor_id
    LEFT JOIN issue_counts AS issue
        ON issue.appointment_id = appointment.appointment_id
    LEFT JOIN reminder_summary AS reminder
        ON reminder.appointment_id = appointment.appointment_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY appointment_id) AS appointment_key,
    appointment_id,
    appointment_record_id,
    record_version,
    available_version_count,
    patient_key,
    clinic_key,
    doctor_key,
    COALESCE(CAST(TO_CHAR(booked_at, 'YYYYMMDD') AS INTEGER), 0) AS booked_date_key,
    COALESCE(CAST(TO_CHAR(scheduled_start_at, 'YYYYMMDD') AS INTEGER), 0) AS scheduled_date_key,
    COALESCE(CAST(TO_CHAR(cancellation_at, 'YYYYMMDD') AS INTEGER), 0) AS cancellation_date_key,
    COALESCE(CAST(TO_CHAR(consultation_start_at, 'YYYYMMDD') AS INTEGER), 0) AS consultation_date_key,
    specialty,
    booked_at,
    scheduled_start_at,
    scheduled_end_at,
    check_in_at,
    consultation_start_at,
    consultation_end_at,
    appointment_status,
    booking_channel,
    consultation_mode,
    visit_type,
    priority_level,
    reason_code,
    is_follow_up,
    parent_appointment_id,
    referral_source,
    cancellation_at,
    cancellation_reason,
    rescheduled_from_appointment_id,
    source_system,
    source_created_at,
    source_updated_at,
    patient_reference_valid,
    clinic_reference_valid,
    doctor_reference_valid,
    scheduled_start_valid,
    issue_count AS data_quality_issue_count,
    CASE WHEN issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue,

    -- analysis columns -----------------------------------------------------
    lead_time_days,
    CASE
        WHEN lead_time_days IS NULL THEN 'Unknown or invalid'
        WHEN lead_time_days = 0 THEN 'Same day'
        WHEN lead_time_days <= 2 THEN '1-2 days'
        WHEN lead_time_days <= 7 THEN '3-7 days'
        WHEN lead_time_days <= 14 THEN '8-14 days'
        WHEN lead_time_days <= 30 THEN '15-30 days'
        ELSE '31+ days'
    END AS lead_time_band,
    CASE
        WHEN lead_time_days IS NULL THEN 7
        WHEN lead_time_days = 0 THEN 1
        WHEN lead_time_days <= 2 THEN 2
        WHEN lead_time_days <= 7 THEN 3
        WHEN lead_time_days <= 14 THEN 4
        WHEN lead_time_days <= 30 THEN 5
        ELSE 6
    END AS lead_time_band_sort,
    CASE
        WHEN scheduled_hour IS NULL THEN 'Unknown'
        WHEN scheduled_hour < 10 THEN 'Early morning (before 10:00)'
        WHEN scheduled_hour < 12 THEN 'Late morning (10:00-11:59)'
        WHEN scheduled_hour < 14 THEN 'Early afternoon (12:00-13:59)'
        WHEN scheduled_hour < 17 THEN 'Late afternoon (14:00-16:59)'
        ELSE 'Evening (17:00+)'
    END AS scheduled_time_band,
    CASE
        WHEN scheduled_hour IS NULL THEN 6
        WHEN scheduled_hour < 10 THEN 1
        WHEN scheduled_hour < 12 THEN 2
        WHEN scheduled_hour < 14 THEN 3
        WHEN scheduled_hour < 17 THEN 4
        ELSE 5
    END AS scheduled_time_band_sort,
    CASE
        WHEN calculated_age < 0 OR calculated_age > 115 THEN NULL
        ELSE calculated_age
    END AS patient_age_at_appointment,
    CASE
        WHEN calculated_age IS NULL OR calculated_age < 0 OR calculated_age > 115 THEN 'Unknown or invalid'
        WHEN calculated_age <= 17 THEN '0-17 years'
        WHEN calculated_age <= 29 THEN '18-29 years'
        WHEN calculated_age <= 44 THEN '30-44 years'
        WHEN calculated_age <= 59 THEN '45-59 years'
        ELSE '60+ years'
    END AS patient_age_band,
    CASE
        WHEN calculated_age IS NULL OR calculated_age < 0 OR calculated_age > 115 THEN 6
        WHEN calculated_age <= 17 THEN 1
        WHEN calculated_age <= 29 THEN 2
        WHEN calculated_age <= 44 THEN 3
        WHEN calculated_age <= 59 THEN 4
        ELSE 5
    END AS patient_age_band_sort,
    -- the segment chosen for the reminder pilot: semi-urban patients
    -- (the high no-show group) with a morning appointment (before 12:00)
    CASE
        WHEN patient_urban_rural = 'Semi-urban' AND scheduled_hour < 12
        THEN 'Target: Semi-urban morning'
        ELSE 'Other appointments'
    END AS pilot_target_segment,
    CASE
        WHEN reminder_count IS NULL THEN 'No reminder record'
        WHEN delivered_count > 0 THEN 'Delivered'
        WHEN failed_count > 0 THEN 'Failed'
        ELSE 'Pending or unknown'
    END AS reminder_delivery_group
FROM
    appointment_base;

ALTER TABLE core.fact_appointments ADD PRIMARY KEY (appointment_key);

-- ---------------------------------------------------------------------------
-- fact_appointment_events
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_appointment_events AS
WITH issue_counts AS (
    SELECT
        business_key AS event_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.appointment_events'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY event.event_id) AS event_key,
    event.event_id,
    appointment.appointment_key,
    event.appointment_id,
    COALESCE(CAST(TO_CHAR(event.event_at, 'YYYYMMDD') AS INTEGER), 0) AS event_date_key,
    event.event_sequence,
    event.event_type,
    event.event_at,
    event.from_status,
    event.to_status,
    event.actor_type,
    event.reason_code,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.appointment_events_clean AS event
INNER JOIN core.fact_appointments AS appointment
    ON appointment.appointment_id = event.appointment_id
LEFT JOIN issue_counts AS issue
    ON issue.event_id = event.event_id;

ALTER TABLE core.fact_appointment_events ADD PRIMARY KEY (event_key);

-- ---------------------------------------------------------------------------
-- fact_schedule_sessions
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_schedule_sessions AS
WITH issue_counts AS (
    SELECT
        business_key AS schedule_session_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.schedule_sessions'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY session.schedule_session_id) AS schedule_session_key,
    session.schedule_session_id,
    COALESCE(CAST(TO_CHAR(session.session_date, 'YYYYMMDD') AS INTEGER), 0) AS session_date_key,
    COALESCE(clinic.clinic_key, 0) AS clinic_key,
    COALESCE(doctor.doctor_key, 0) AS doctor_key,
    session.session_date,
    session.planned_start_time,
    session.planned_end_time,
    session.slot_length_minutes,
    session.planned_slots,
    session.blocked_slots,
    session.overbook_allowed,
    session.session_status,
    session.session_cancel_reason,
    session.roster_batch_id,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.schedule_sessions_clean AS session
LEFT JOIN core.dim_clinic AS clinic
    ON clinic.clinic_id = session.clinic_id
LEFT JOIN core.dim_doctor AS doctor
    ON doctor.doctor_id = session.doctor_id
LEFT JOIN issue_counts AS issue
    ON issue.schedule_session_id = session.schedule_session_id;

ALTER TABLE core.fact_schedule_sessions ADD PRIMARY KEY (schedule_session_key);

-- ---------------------------------------------------------------------------
-- fact_reminders
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_reminders AS
WITH issue_counts AS (
    SELECT
        business_key AS reminder_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.reminders'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY reminder.reminder_id) AS reminder_key,
    reminder.reminder_id,
    appointment.appointment_key,
    reminder.appointment_id,
    COALESCE(CAST(TO_CHAR(reminder.scheduled_send_at, 'YYYYMMDD') AS INTEGER), 0) AS scheduled_send_date_key,
    COALESCE(CAST(TO_CHAR(reminder.sent_at, 'YYYYMMDD') AS INTEGER), 0) AS sent_date_key,
    COALESCE(CAST(TO_CHAR(reminder.delivered_at, 'YYYYMMDD') AS INTEGER), 0) AS delivered_date_key,
    COALESCE(CAST(TO_CHAR(reminder.read_at, 'YYYYMMDD') AS INTEGER), 0) AS read_date_key,
    reminder.reminder_type,
    reminder.channel,
    reminder.provider_name,
    reminder.attempt_number,
    reminder.scheduled_send_at,
    reminder.sent_at,
    reminder.delivery_status,
    reminder.delivered_at,
    reminder.read_at,
    reminder.failure_reason,
    reminder.template_code,
    reminder.language,
    reminder.provider_message_id,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.reminders_clean AS reminder
INNER JOIN core.fact_appointments AS appointment
    ON appointment.appointment_id = reminder.appointment_id
LEFT JOIN issue_counts AS issue
    ON issue.reminder_id = reminder.reminder_id;

ALTER TABLE core.fact_reminders ADD PRIMARY KEY (reminder_key);

-- ---------------------------------------------------------------------------
-- fact_telemedicine_sessions
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_telemedicine_sessions AS
WITH issue_counts AS (
    SELECT
        business_key AS telemedicine_session_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.telemedicine_sessions'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY session.telemedicine_session_id) AS telemedicine_session_key,
    session.telemedicine_session_id,
    appointment.appointment_key,
    session.appointment_id,
    COALESCE(CAST(TO_CHAR(session.scheduled_start_at, 'YYYYMMDD') AS INTEGER), 0) AS scheduled_date_key,
    session.platform_name,
    session.scheduled_start_at,
    session.patient_join_at,
    session.doctor_join_at,
    session.session_start_at,
    session.session_end_at,
    session.session_status,
    session.disconnect_count,
    session.average_latency_ms,
    session.audio_quality_score,
    session.video_quality_score,
    session.technical_issue_flag,
    session.issue_category,
    session.device_type,
    session.network_type,
    session.recording_consent,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.telemedicine_sessions_clean AS session
INNER JOIN core.fact_appointments AS appointment
    ON appointment.appointment_id = session.appointment_id
LEFT JOIN issue_counts AS issue
    ON issue.telemedicine_session_id = session.telemedicine_session_id;

ALTER TABLE core.fact_telemedicine_sessions ADD PRIMARY KEY (telemedicine_session_key);

-- ---------------------------------------------------------------------------
-- fact_payments
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_payments AS
WITH issue_counts AS (
    SELECT
        business_key AS payment_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.payments'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY payment.payment_id) AS payment_key,
    payment.payment_id,
    payment.payment_record_id,
    payment.record_version,
    payment.available_version_count,
    appointment.appointment_key,
    payment.appointment_id,
    COALESCE(CAST(TO_CHAR(payment.transaction_at, 'YYYYMMDD') AS INTEGER), 0) AS transaction_date_key,
    COALESCE(CAST(TO_CHAR(payment.refund_at, 'YYYYMMDD') AS INTEGER), 0) AS refund_date_key,
    payment.invoice_id,
    payment.payer_type,
    payment.payment_method,
    payment.gross_amount_bdt,
    payment.discount_amount_bdt,
    payment.net_amount_bdt,
    payment.amount_paid_bdt,
    payment.payment_status,
    payment.transaction_at,
    payment.refund_amount_bdt,
    payment.refund_at,
    payment.insurance_claim_id,
    payment.claim_status,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.payments_clean AS payment
INNER JOIN core.fact_appointments AS appointment
    ON appointment.appointment_id = payment.appointment_id
LEFT JOIN issue_counts AS issue
    ON issue.payment_id = payment.payment_id;

ALTER TABLE core.fact_payments ADD PRIMARY KEY (payment_key);

-- ---------------------------------------------------------------------------
-- fact_feedback
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_feedback AS
WITH issue_counts AS (
    SELECT
        business_key AS survey_id,
        COUNT(*) AS issue_count
    FROM
        audit.data_quality_issues
    WHERE
        source_table = 'raw.feedback'
    GROUP BY
        business_key
)
SELECT
    ROW_NUMBER() OVER (ORDER BY feedback.survey_id) AS feedback_key,
    feedback.survey_id,
    appointment.appointment_key,
    feedback.appointment_id,
    COALESCE(CAST(TO_CHAR(feedback.survey_sent_at, 'YYYYMMDD') AS INTEGER), 0) AS survey_sent_date_key,
    COALESCE(CAST(TO_CHAR(feedback.responded_at, 'YYYYMMDD') AS INTEGER), 0) AS responded_date_key,
    feedback.survey_sent_at,
    feedback.responded_at,
    feedback.overall_rating,
    feedback.wait_time_rating,
    feedback.doctor_rating,
    feedback.booking_experience_rating,
    feedback.telemedicine_rating,
    feedback.recommend_score_nps,
    feedback.complaint_flag,
    feedback.complaint_category,
    feedback.follow_up_required,
    COALESCE(issue.issue_count, 0) AS data_quality_issue_count,
    CASE WHEN issue.issue_count > 0 THEN TRUE ELSE FALSE END AS has_data_quality_issue
FROM
    staging.feedback_clean AS feedback
INNER JOIN core.fact_appointments AS appointment
    ON appointment.appointment_id = feedback.appointment_id
LEFT JOIN issue_counts AS issue
    ON issue.survey_id = feedback.survey_id;

ALTER TABLE core.fact_feedback ADD PRIMARY KEY (feedback_key);

-- ---------------------------------------------------------------------------
-- data_quality_issues (reporting copy of the audit log)
-- ---------------------------------------------------------------------------

CREATE TABLE core.data_quality_issues AS
SELECT
    issue_id AS data_quality_issue_key,
    check_stage,
    source_table,
    source_raw_row_id,
    business_key,
    column_name,
    issue_type,
    severity,
    raw_value,
    issue_description,
    detected_at
FROM
    audit.data_quality_issues;

ALTER TABLE core.data_quality_issues ADD PRIMARY KEY (data_quality_issue_key);

-- check: expected 73715, 257288, 17788, 86527, 7652, 57261, 18509, 4342
SELECT 'fact_appointments' AS table_name, COUNT(*) AS row_count FROM core.fact_appointments
UNION ALL SELECT 'fact_appointment_events', COUNT(*) FROM core.fact_appointment_events
UNION ALL SELECT 'fact_schedule_sessions', COUNT(*) FROM core.fact_schedule_sessions
UNION ALL SELECT 'fact_reminders', COUNT(*) FROM core.fact_reminders
UNION ALL SELECT 'fact_telemedicine_sessions', COUNT(*) FROM core.fact_telemedicine_sessions
UNION ALL SELECT 'fact_payments', COUNT(*) FROM core.fact_payments
UNION ALL SELECT 'fact_feedback', COUNT(*) FROM core.fact_feedback
UNION ALL SELECT 'data_quality_issues', COUNT(*) FROM core.data_quality_issues;
