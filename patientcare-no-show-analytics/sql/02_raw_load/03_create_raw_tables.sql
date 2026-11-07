/*
PatientCare Analytics
Script 03: Create the raw tables

Every CSV column is stored as TEXT so that nothing is lost or rejected on load,
including bad dates and inconsistent spellings. Cleaning happens later in staging.

raw_row_id numbers each row in file order. It is used later to trace any issue
back to the exact source row and to break ties when removing duplicates.
*/

DROP TABLE IF EXISTS raw.clinics;
DROP TABLE IF EXISTS raw.doctors;
DROP TABLE IF EXISTS raw.patients;
DROP TABLE IF EXISTS raw.appointments;
DROP TABLE IF EXISTS raw.appointment_events;
DROP TABLE IF EXISTS raw.schedule_sessions;
DROP TABLE IF EXISTS raw.reminders;
DROP TABLE IF EXISTS raw.telemedicine_sessions;
DROP TABLE IF EXISTS raw.payments;
DROP TABLE IF EXISTS raw.feedback;
DROP TABLE IF EXISTS raw.reminder_pilot_assignment;
DROP TABLE IF EXISTS raw.reporting_process_log;

-- ---------------------------------------------------------------------------
-- Master data
-- ---------------------------------------------------------------------------

CREATE TABLE raw.clinics (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    clinic_id TEXT,
    clinic_name TEXT,
    facility_type_raw TEXT,
    ownership_model_raw TEXT,
    division TEXT,
    district TEXT,
    city_area TEXT,
    urban_rural TEXT,
    opening_date TEXT,
    operating_start_time TEXT,
    operating_end_time TEXT,
    consultation_room_count TEXT,
    telemedicine_enabled_raw TEXT,
    active_flag_raw TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

CREATE TABLE raw.doctors (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    doctor_id TEXT,
    doctor_name TEXT,
    gender_raw TEXT,
    specialty_raw TEXT,
    subspecialty_raw TEXT,
    designation_raw TEXT,
    employment_type_raw TEXT,
    primary_clinic_id TEXT,
    joining_date TEXT,
    leaving_date TEXT,
    telemedicine_enabled_raw TEXT,
    standard_consultation_fee_bdt TEXT,
    active_flag_raw TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

CREATE TABLE raw.patients (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id TEXT,
    registration_date TEXT,
    birth_date TEXT,
    gender_raw TEXT,
    marital_status_raw TEXT,
    division TEXT,
    district TEXT,
    upazila TEXT,
    urban_rural TEXT,
    preferred_language_raw TEXT,
    contact_consent_raw TEXT,
    sms_opt_in_raw TEXT,
    whatsapp_opt_in_raw TEXT,
    chronic_condition_flag_raw TEXT,
    chronic_condition_group_raw TEXT,
    disability_support_required_raw TEXT,
    patient_status_raw TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

-- ---------------------------------------------------------------------------
-- Appointments and their operational feeds
-- ---------------------------------------------------------------------------

CREATE TABLE raw.appointments (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_record_id TEXT,
    appointment_id TEXT,
    record_version TEXT,
    patient_id TEXT,
    clinic_id TEXT,
    doctor_id TEXT,
    specialty_raw TEXT,
    booked_at TEXT,
    scheduled_start_at TEXT,
    scheduled_end_at TEXT,
    check_in_at TEXT,
    consultation_start_at TEXT,
    consultation_end_at TEXT,
    appointment_status_raw TEXT,
    booking_channel_raw TEXT,
    consultation_mode_raw TEXT,
    visit_type_raw TEXT,
    priority_level_raw TEXT,
    reason_code_raw TEXT,
    is_follow_up_raw TEXT,
    parent_appointment_id TEXT,
    referral_source_raw TEXT,
    cancellation_at TEXT,
    cancellation_reason_raw TEXT,
    rescheduled_from_appointment_id TEXT,
    source_system TEXT,
    source_created_at TEXT,
    source_updated_at TEXT,
    ingested_at TEXT,
    batch_id TEXT
);

CREATE TABLE raw.appointment_events (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id TEXT,
    appointment_id TEXT,
    event_sequence TEXT,
    event_type_raw TEXT,
    event_at TEXT,
    from_status_raw TEXT,
    to_status_raw TEXT,
    actor_type_raw TEXT,
    reason_code_raw TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

CREATE TABLE raw.schedule_sessions (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    schedule_session_id TEXT,
    session_date TEXT,
    clinic_id TEXT,
    doctor_id TEXT,
    planned_start_time TEXT,
    planned_end_time TEXT,
    slot_length_minutes TEXT,
    planned_slots TEXT,
    blocked_slots TEXT,
    overbook_allowed_raw TEXT,
    session_status_raw TEXT,
    session_cancel_reason_raw TEXT,
    roster_batch_id TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

CREATE TABLE raw.reminders (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reminder_id TEXT,
    appointment_id TEXT,
    patient_id TEXT,
    reminder_type_raw TEXT,
    channel_raw TEXT,
    provider_name TEXT,
    attempt_number TEXT,
    scheduled_send_at TEXT,
    sent_at TEXT,
    delivery_status_raw TEXT,
    delivered_at TEXT,
    read_at TEXT,
    failure_reason_raw TEXT,
    template_code TEXT,
    language_raw TEXT,
    provider_message_id TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

CREATE TABLE raw.telemedicine_sessions (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    telemedicine_session_id TEXT,
    appointment_id TEXT,
    platform_name TEXT,
    scheduled_start_at TEXT,
    patient_join_at TEXT,
    doctor_join_at TEXT,
    session_start_at TEXT,
    session_end_at TEXT,
    session_status_raw TEXT,
    disconnect_count TEXT,
    average_latency_ms TEXT,
    audio_quality_score TEXT,
    video_quality_score TEXT,
    technical_issue_flag_raw TEXT,
    issue_category_raw TEXT,
    device_type_raw TEXT,
    network_type_raw TEXT,
    recording_consent_raw TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

CREATE TABLE raw.payments (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_record_id TEXT,
    payment_id TEXT,
    record_version TEXT,
    appointment_id TEXT,
    invoice_id TEXT,
    payer_type_raw TEXT,
    payment_method_raw TEXT,
    gross_amount_bdt TEXT,
    discount_amount_bdt TEXT,
    net_amount_bdt TEXT,
    amount_paid_bdt TEXT,
    payment_status_raw TEXT,
    transaction_at TEXT,
    refund_amount_bdt TEXT,
    refund_at TEXT,
    insurance_claim_id TEXT,
    claim_status_raw TEXT,
    source_updated_at TEXT,
    ingested_at TEXT,
    batch_id TEXT
);

CREATE TABLE raw.feedback (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    survey_id TEXT,
    appointment_id TEXT,
    patient_id TEXT,
    survey_sent_at TEXT,
    responded_at TEXT,
    overall_rating TEXT,
    wait_time_rating TEXT,
    doctor_rating TEXT,
    booking_experience_rating TEXT,
    telemedicine_rating TEXT,
    recommend_score_nps TEXT,
    complaint_flag_raw TEXT,
    complaint_category_raw TEXT,
    follow_up_required_raw TEXT,
    source_updated_at TEXT,
    ingested_at TEXT
);

-- ---------------------------------------------------------------------------
-- Reminder pilot and reporting-process logs
-- ---------------------------------------------------------------------------

CREATE TABLE raw.reminder_pilot_assignment (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pilot_record_id TEXT,
    appointment_id TEXT,
    assignment_date TEXT,
    scheduled_date TEXT,
    clinic_id TEXT,
    assignment_month TEXT,
    assignment_group TEXT,
    intervention_type TEXT,
    intervention_delivery_status TEXT,
    pilot_outcome TEXT,
    attendance_eligible_flag TEXT,
    no_show_flag TEXT,
    analysis_exclusion_reason TEXT,
    randomisation_block TEXT,
    assignment_method TEXT,
    pilot_phase TEXT
);

CREATE TABLE raw.reporting_process_log (
    raw_row_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_log_id TEXT,
    reporting_week_start TEXT,
    process_phase TEXT,
    reporting_method TEXT,
    data_preparation_minutes TEXT,
    validation_minutes TEXT,
    formatting_minutes TEXT,
    distribution_minutes TEXT
);
