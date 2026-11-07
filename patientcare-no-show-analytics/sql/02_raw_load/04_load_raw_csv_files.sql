/*
PatientCare Analytics
Script 04: Load the raw CSV files

BEFORE RUNNING: replace /PATH/TO/patientcare-no-show-analytics with the full path of
the project folder (the folder that contains data/ and sql/). In VS Code use
Find and Replace (Cmd+Option+F on Mac, Ctrl+H on Windows) on this file.
Example on a Mac:  /Users/yourname/Projects/patientcare-no-show-analytics

COPY is run by the PostgreSQL server, so the path must be the full path on the
computer where PostgreSQL runs. It does the same job as BULK INSERT in SQL Server.

Script 03 drops and recreates the raw tables, so always run 03 before 04.
*/

COPY raw.clinics (
    clinic_id,
    clinic_name,
    facility_type_raw,
    ownership_model_raw,
    division,
    district,
    city_area,
    urban_rural,
    opening_date,
    operating_start_time,
    operating_end_time,
    consultation_room_count,
    telemedicine_enabled_raw,
    active_flag_raw,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_clinics.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.doctors (
    doctor_id,
    doctor_name,
    gender_raw,
    specialty_raw,
    subspecialty_raw,
    designation_raw,
    employment_type_raw,
    primary_clinic_id,
    joining_date,
    leaving_date,
    telemedicine_enabled_raw,
    standard_consultation_fee_bdt,
    active_flag_raw,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_doctors.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.patients (
    patient_id,
    registration_date,
    birth_date,
    gender_raw,
    marital_status_raw,
    division,
    district,
    upazila,
    urban_rural,
    preferred_language_raw,
    contact_consent_raw,
    sms_opt_in_raw,
    whatsapp_opt_in_raw,
    chronic_condition_flag_raw,
    chronic_condition_group_raw,
    disability_support_required_raw,
    patient_status_raw,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_patients.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.appointments (
    appointment_record_id,
    appointment_id,
    record_version,
    patient_id,
    clinic_id,
    doctor_id,
    specialty_raw,
    booked_at,
    scheduled_start_at,
    scheduled_end_at,
    check_in_at,
    consultation_start_at,
    consultation_end_at,
    appointment_status_raw,
    booking_channel_raw,
    consultation_mode_raw,
    visit_type_raw,
    priority_level_raw,
    reason_code_raw,
    is_follow_up_raw,
    parent_appointment_id,
    referral_source_raw,
    cancellation_at,
    cancellation_reason_raw,
    rescheduled_from_appointment_id,
    source_system,
    source_created_at,
    source_updated_at,
    ingested_at,
    batch_id
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_appointments.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.appointment_events (
    event_id,
    appointment_id,
    event_sequence,
    event_type_raw,
    event_at,
    from_status_raw,
    to_status_raw,
    actor_type_raw,
    reason_code_raw,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_appointment_events.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.schedule_sessions (
    schedule_session_id,
    session_date,
    clinic_id,
    doctor_id,
    planned_start_time,
    planned_end_time,
    slot_length_minutes,
    planned_slots,
    blocked_slots,
    overbook_allowed_raw,
    session_status_raw,
    session_cancel_reason_raw,
    roster_batch_id,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_schedule_sessions.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.reminders (
    reminder_id,
    appointment_id,
    patient_id,
    reminder_type_raw,
    channel_raw,
    provider_name,
    attempt_number,
    scheduled_send_at,
    sent_at,
    delivery_status_raw,
    delivered_at,
    read_at,
    failure_reason_raw,
    template_code,
    language_raw,
    provider_message_id,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_reminders.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.telemedicine_sessions (
    telemedicine_session_id,
    appointment_id,
    platform_name,
    scheduled_start_at,
    patient_join_at,
    doctor_join_at,
    session_start_at,
    session_end_at,
    session_status_raw,
    disconnect_count,
    average_latency_ms,
    audio_quality_score,
    video_quality_score,
    technical_issue_flag_raw,
    issue_category_raw,
    device_type_raw,
    network_type_raw,
    recording_consent_raw,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_telemedicine_sessions.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.payments (
    payment_record_id,
    payment_id,
    record_version,
    appointment_id,
    invoice_id,
    payer_type_raw,
    payment_method_raw,
    gross_amount_bdt,
    discount_amount_bdt,
    net_amount_bdt,
    amount_paid_bdt,
    payment_status_raw,
    transaction_at,
    refund_amount_bdt,
    refund_at,
    insurance_claim_id,
    claim_status_raw,
    source_updated_at,
    ingested_at,
    batch_id
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_payments.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.feedback (
    survey_id,
    appointment_id,
    patient_id,
    survey_sent_at,
    responded_at,
    overall_rating,
    wait_time_rating,
    doctor_rating,
    booking_experience_rating,
    telemedicine_rating,
    recommend_score_nps,
    complaint_flag_raw,
    complaint_category_raw,
    follow_up_required_raw,
    source_updated_at,
    ingested_at
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_feedback.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.reminder_pilot_assignment (
    pilot_record_id,
    appointment_id,
    assignment_date,
    scheduled_date,
    clinic_id,
    assignment_month,
    assignment_group,
    intervention_type,
    intervention_delivery_status,
    pilot_outcome,
    attendance_eligible_flag,
    no_show_flag,
    analysis_exclusion_reason,
    randomisation_block,
    assignment_method,
    pilot_phase
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_reminder_pilot_assignment.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

COPY raw.reporting_process_log (
    report_log_id,
    reporting_week_start,
    process_phase,
    reporting_method,
    data_preparation_minutes,
    validation_minutes,
    formatting_minutes,
    distribution_minutes
)
FROM '/PATH/TO/patientcare-no-show-analytics/data/raw/raw_reporting_process_log.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

-- check: rows loaded per table
SELECT 'clinics' AS table_name, COUNT(*) AS rows_loaded FROM raw.clinics
UNION ALL SELECT 'doctors', COUNT(*) FROM raw.doctors
UNION ALL SELECT 'patients', COUNT(*) FROM raw.patients
UNION ALL SELECT 'appointments', COUNT(*) FROM raw.appointments
UNION ALL SELECT 'appointment_events', COUNT(*) FROM raw.appointment_events
UNION ALL SELECT 'schedule_sessions', COUNT(*) FROM raw.schedule_sessions
UNION ALL SELECT 'reminders', COUNT(*) FROM raw.reminders
UNION ALL SELECT 'telemedicine_sessions', COUNT(*) FROM raw.telemedicine_sessions
UNION ALL SELECT 'payments', COUNT(*) FROM raw.payments
UNION ALL SELECT 'feedback', COUNT(*) FROM raw.feedback
UNION ALL SELECT 'reminder_pilot_assignment', COUNT(*) FROM raw.reminder_pilot_assignment
UNION ALL SELECT 'reporting_process_log', COUNT(*) FROM raw.reporting_process_log;
