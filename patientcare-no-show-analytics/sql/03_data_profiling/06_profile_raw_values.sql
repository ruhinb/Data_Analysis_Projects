/*
PatientCare Analytics
Script 06: Profile the raw values

Part 1 lists every spelling found in the category and yes/no columns. This is
how the inconsistent labels were found (for example "Done", "COMPLETED" and
"complete" all mean Completed). Script 07 maps each spelling to one standard value.

Part 2 counts values that are not in the expected format, so they would not
convert to a date, time or number:
    timestamp  'YYYY-MM-DD HH:MM:SS'   checked with LIKE '____-__-__ __:__:__'
    date       'YYYY-MM-DD'            checked with LIKE '____-__-__'
    time       'HH:MM:SS'              checked with LIKE '__:__:__'
    number     digits only             TRANSLATE removes every digit, minus sign
                                       and decimal point. Anything left over is
                                       not a number

Result of part 2 on this data: the only bad values are 24 appointment rows
whose scheduled_start_at is '31/02/2023 09:00' (31 February does not exist).
*/

-- ---------------------------------------------------------------------------
-- Part 1: distinct spellings in category and yes/no columns
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS audit.category_profile;

CREATE TABLE audit.category_profile AS
SELECT 'raw.appointments' AS source_table, 'appointment_status_raw' AS source_column, appointment_status_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointments GROUP BY appointment_status_raw
UNION ALL
SELECT 'raw.appointments' AS source_table, 'booking_channel_raw' AS source_column, booking_channel_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointments GROUP BY booking_channel_raw
UNION ALL
SELECT 'raw.appointments' AS source_table, 'consultation_mode_raw' AS source_column, consultation_mode_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointments GROUP BY consultation_mode_raw
UNION ALL
SELECT 'raw.appointments' AS source_table, 'visit_type_raw' AS source_column, visit_type_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointments GROUP BY visit_type_raw
UNION ALL
SELECT 'raw.appointments' AS source_table, 'priority_level_raw' AS source_column, priority_level_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointments GROUP BY priority_level_raw
UNION ALL
SELECT 'raw.appointments' AS source_table, 'specialty_raw' AS source_column, specialty_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointments GROUP BY specialty_raw
UNION ALL
SELECT 'raw.appointments' AS source_table, 'is_follow_up_raw' AS source_column, is_follow_up_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointments GROUP BY is_follow_up_raw
UNION ALL
SELECT 'raw.appointment_events' AS source_table, 'event_type_raw' AS source_column, event_type_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointment_events GROUP BY event_type_raw
UNION ALL
SELECT 'raw.appointment_events' AS source_table, 'actor_type_raw' AS source_column, actor_type_raw AS raw_value, COUNT(*) AS row_count FROM raw.appointment_events GROUP BY actor_type_raw
UNION ALL
SELECT 'raw.clinics' AS source_table, 'urban_rural' AS source_column, urban_rural AS raw_value, COUNT(*) AS row_count FROM raw.clinics GROUP BY urban_rural
UNION ALL
SELECT 'raw.clinics' AS source_table, 'telemedicine_enabled_raw' AS source_column, telemedicine_enabled_raw AS raw_value, COUNT(*) AS row_count FROM raw.clinics GROUP BY telemedicine_enabled_raw
UNION ALL
SELECT 'raw.clinics' AS source_table, 'active_flag_raw' AS source_column, active_flag_raw AS raw_value, COUNT(*) AS row_count FROM raw.clinics GROUP BY active_flag_raw
UNION ALL
SELECT 'raw.doctors' AS source_table, 'gender_raw' AS source_column, gender_raw AS raw_value, COUNT(*) AS row_count FROM raw.doctors GROUP BY gender_raw
UNION ALL
SELECT 'raw.doctors' AS source_table, 'specialty_raw' AS source_column, specialty_raw AS raw_value, COUNT(*) AS row_count FROM raw.doctors GROUP BY specialty_raw
UNION ALL
SELECT 'raw.doctors' AS source_table, 'active_flag_raw' AS source_column, active_flag_raw AS raw_value, COUNT(*) AS row_count FROM raw.doctors GROUP BY active_flag_raw
UNION ALL
SELECT 'raw.patients' AS source_table, 'gender_raw' AS source_column, gender_raw AS raw_value, COUNT(*) AS row_count FROM raw.patients GROUP BY gender_raw
UNION ALL
SELECT 'raw.patients' AS source_table, 'patient_status_raw' AS source_column, patient_status_raw AS raw_value, COUNT(*) AS row_count FROM raw.patients GROUP BY patient_status_raw
UNION ALL
SELECT 'raw.patients' AS source_table, 'urban_rural' AS source_column, urban_rural AS raw_value, COUNT(*) AS row_count FROM raw.patients GROUP BY urban_rural
UNION ALL
SELECT 'raw.patients' AS source_table, 'chronic_condition_flag_raw' AS source_column, chronic_condition_flag_raw AS raw_value, COUNT(*) AS row_count FROM raw.patients GROUP BY chronic_condition_flag_raw
UNION ALL
SELECT 'raw.patients' AS source_table, 'sms_opt_in_raw' AS source_column, sms_opt_in_raw AS raw_value, COUNT(*) AS row_count FROM raw.patients GROUP BY sms_opt_in_raw
UNION ALL
SELECT 'raw.schedule_sessions' AS source_table, 'session_status_raw' AS source_column, session_status_raw AS raw_value, COUNT(*) AS row_count FROM raw.schedule_sessions GROUP BY session_status_raw
UNION ALL
SELECT 'raw.schedule_sessions' AS source_table, 'overbook_allowed_raw' AS source_column, overbook_allowed_raw AS raw_value, COUNT(*) AS row_count FROM raw.schedule_sessions GROUP BY overbook_allowed_raw
UNION ALL
SELECT 'raw.reminders' AS source_table, 'reminder_type_raw' AS source_column, reminder_type_raw AS raw_value, COUNT(*) AS row_count FROM raw.reminders GROUP BY reminder_type_raw
UNION ALL
SELECT 'raw.reminders' AS source_table, 'channel_raw' AS source_column, channel_raw AS raw_value, COUNT(*) AS row_count FROM raw.reminders GROUP BY channel_raw
UNION ALL
SELECT 'raw.reminders' AS source_table, 'delivery_status_raw' AS source_column, delivery_status_raw AS raw_value, COUNT(*) AS row_count FROM raw.reminders GROUP BY delivery_status_raw
UNION ALL
SELECT 'raw.telemedicine_sessions' AS source_table, 'session_status_raw' AS source_column, session_status_raw AS raw_value, COUNT(*) AS row_count FROM raw.telemedicine_sessions GROUP BY session_status_raw
UNION ALL
SELECT 'raw.telemedicine_sessions' AS source_table, 'technical_issue_flag_raw' AS source_column, technical_issue_flag_raw AS raw_value, COUNT(*) AS row_count FROM raw.telemedicine_sessions GROUP BY technical_issue_flag_raw
UNION ALL
SELECT 'raw.payments' AS source_table, 'payment_status_raw' AS source_column, payment_status_raw AS raw_value, COUNT(*) AS row_count FROM raw.payments GROUP BY payment_status_raw
UNION ALL
SELECT 'raw.feedback' AS source_table, 'complaint_flag_raw' AS source_column, complaint_flag_raw AS raw_value, COUNT(*) AS row_count FROM raw.feedback GROUP BY complaint_flag_raw
UNION ALL
SELECT 'raw.feedback' AS source_table, 'follow_up_required_raw' AS source_column, follow_up_required_raw AS raw_value, COUNT(*) AS row_count FROM raw.feedback GROUP BY follow_up_required_raw;

-- review: one row per spelling, most common first
SELECT
    source_table,
    source_column,
    raw_value,
    row_count
FROM
    audit.category_profile
ORDER BY
    source_table,
    source_column,
    row_count DESC;

-- ---------------------------------------------------------------------------
-- Part 2: values that cannot be converted to their real data type
-- (blank values are ignored because they are allowed to be empty)
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS audit.conversion_check;

CREATE TABLE audit.conversion_check AS
SELECT 'raw.appointments' AS source_table, 'booked_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN booked_at IS NOT NULL AND booked_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'scheduled_start_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN scheduled_start_at IS NOT NULL AND scheduled_start_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'scheduled_end_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN scheduled_end_at IS NOT NULL AND scheduled_end_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'check_in_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN check_in_at IS NOT NULL AND check_in_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'consultation_start_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN consultation_start_at IS NOT NULL AND consultation_start_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'consultation_end_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN consultation_end_at IS NOT NULL AND consultation_end_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'cancellation_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN cancellation_at IS NOT NULL AND cancellation_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'source_created_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN source_created_at IS NOT NULL AND source_created_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'source_updated_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN source_updated_at IS NOT NULL AND source_updated_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.appointments' AS source_table, 'record_version' AS source_column, 'integer' AS target_type, SUM(CASE WHEN record_version IS NOT NULL AND TRANSLATE(record_version, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointments
UNION ALL
SELECT 'raw.patients' AS source_table, 'registration_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN registration_date IS NOT NULL AND registration_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.patients
UNION ALL
SELECT 'raw.patients' AS source_table, 'birth_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN birth_date IS NOT NULL AND birth_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.patients
UNION ALL
SELECT 'raw.doctors' AS source_table, 'joining_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN joining_date IS NOT NULL AND joining_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.doctors
UNION ALL
SELECT 'raw.doctors' AS source_table, 'leaving_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN leaving_date IS NOT NULL AND leaving_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.doctors
UNION ALL
SELECT 'raw.doctors' AS source_table, 'standard_consultation_fee_bdt' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN standard_consultation_fee_bdt IS NOT NULL AND TRANSLATE(standard_consultation_fee_bdt, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.doctors
UNION ALL
SELECT 'raw.clinics' AS source_table, 'opening_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN opening_date IS NOT NULL AND opening_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.clinics
UNION ALL
SELECT 'raw.clinics' AS source_table, 'operating_start_time' AS source_column, 'time' AS target_type, SUM(CASE WHEN operating_start_time IS NOT NULL AND operating_start_time NOT LIKE '__:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.clinics
UNION ALL
SELECT 'raw.clinics' AS source_table, 'operating_end_time' AS source_column, 'time' AS target_type, SUM(CASE WHEN operating_end_time IS NOT NULL AND operating_end_time NOT LIKE '__:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.clinics
UNION ALL
SELECT 'raw.clinics' AS source_table, 'consultation_room_count' AS source_column, 'integer' AS target_type, SUM(CASE WHEN consultation_room_count IS NOT NULL AND TRANSLATE(consultation_room_count, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.clinics
UNION ALL
SELECT 'raw.appointment_events' AS source_table, 'event_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN event_at IS NOT NULL AND event_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointment_events
UNION ALL
SELECT 'raw.appointment_events' AS source_table, 'event_sequence' AS source_column, 'integer' AS target_type, SUM(CASE WHEN event_sequence IS NOT NULL AND TRANSLATE(event_sequence, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.appointment_events
UNION ALL
SELECT 'raw.schedule_sessions' AS source_table, 'session_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN session_date IS NOT NULL AND session_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.schedule_sessions
UNION ALL
SELECT 'raw.schedule_sessions' AS source_table, 'planned_start_time' AS source_column, 'time' AS target_type, SUM(CASE WHEN planned_start_time IS NOT NULL AND planned_start_time NOT LIKE '__:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.schedule_sessions
UNION ALL
SELECT 'raw.schedule_sessions' AS source_table, 'planned_end_time' AS source_column, 'time' AS target_type, SUM(CASE WHEN planned_end_time IS NOT NULL AND planned_end_time NOT LIKE '__:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.schedule_sessions
UNION ALL
SELECT 'raw.schedule_sessions' AS source_table, 'planned_slots' AS source_column, 'integer' AS target_type, SUM(CASE WHEN planned_slots IS NOT NULL AND TRANSLATE(planned_slots, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.schedule_sessions
UNION ALL
SELECT 'raw.schedule_sessions' AS source_table, 'blocked_slots' AS source_column, 'integer' AS target_type, SUM(CASE WHEN blocked_slots IS NOT NULL AND TRANSLATE(blocked_slots, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.schedule_sessions
UNION ALL
SELECT 'raw.reminders' AS source_table, 'scheduled_send_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN scheduled_send_at IS NOT NULL AND scheduled_send_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reminders
UNION ALL
SELECT 'raw.reminders' AS source_table, 'sent_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN sent_at IS NOT NULL AND sent_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reminders
UNION ALL
SELECT 'raw.reminders' AS source_table, 'delivered_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN delivered_at IS NOT NULL AND delivered_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reminders
UNION ALL
SELECT 'raw.reminders' AS source_table, 'read_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN read_at IS NOT NULL AND read_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reminders
UNION ALL
SELECT 'raw.reminders' AS source_table, 'attempt_number' AS source_column, 'integer' AS target_type, SUM(CASE WHEN attempt_number IS NOT NULL AND TRANSLATE(attempt_number, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reminders
UNION ALL
SELECT 'raw.telemedicine_sessions' AS source_table, 'scheduled_start_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN scheduled_start_at IS NOT NULL AND scheduled_start_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.telemedicine_sessions
UNION ALL
SELECT 'raw.telemedicine_sessions' AS source_table, 'session_start_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN session_start_at IS NOT NULL AND session_start_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.telemedicine_sessions
UNION ALL
SELECT 'raw.telemedicine_sessions' AS source_table, 'session_end_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN session_end_at IS NOT NULL AND session_end_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.telemedicine_sessions
UNION ALL
SELECT 'raw.telemedicine_sessions' AS source_table, 'audio_quality_score' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN audio_quality_score IS NOT NULL AND TRANSLATE(audio_quality_score, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.telemedicine_sessions
UNION ALL
SELECT 'raw.telemedicine_sessions' AS source_table, 'video_quality_score' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN video_quality_score IS NOT NULL AND TRANSLATE(video_quality_score, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.telemedicine_sessions
UNION ALL
SELECT 'raw.payments' AS source_table, 'transaction_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN transaction_at IS NOT NULL AND transaction_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.payments' AS source_table, 'refund_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN refund_at IS NOT NULL AND refund_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.payments' AS source_table, 'gross_amount_bdt' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN gross_amount_bdt IS NOT NULL AND TRANSLATE(gross_amount_bdt, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.payments' AS source_table, 'discount_amount_bdt' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN discount_amount_bdt IS NOT NULL AND TRANSLATE(discount_amount_bdt, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.payments' AS source_table, 'net_amount_bdt' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN net_amount_bdt IS NOT NULL AND TRANSLATE(net_amount_bdt, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.payments' AS source_table, 'amount_paid_bdt' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN amount_paid_bdt IS NOT NULL AND TRANSLATE(amount_paid_bdt, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.payments' AS source_table, 'refund_amount_bdt' AS source_column, 'numeric' AS target_type, SUM(CASE WHEN refund_amount_bdt IS NOT NULL AND TRANSLATE(refund_amount_bdt, '0123456789.-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.payments' AS source_table, 'record_version' AS source_column, 'integer' AS target_type, SUM(CASE WHEN record_version IS NOT NULL AND TRANSLATE(record_version, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.payments
UNION ALL
SELECT 'raw.feedback' AS source_table, 'survey_sent_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN survey_sent_at IS NOT NULL AND survey_sent_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.feedback
UNION ALL
SELECT 'raw.feedback' AS source_table, 'responded_at' AS source_column, 'timestamp' AS target_type, SUM(CASE WHEN responded_at IS NOT NULL AND responded_at NOT LIKE '____-__-__ __:__:__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.feedback
UNION ALL
SELECT 'raw.feedback' AS source_table, 'overall_rating' AS source_column, 'integer' AS target_type, SUM(CASE WHEN overall_rating IS NOT NULL AND TRANSLATE(overall_rating, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.feedback
UNION ALL
SELECT 'raw.feedback' AS source_table, 'recommend_score_nps' AS source_column, 'integer' AS target_type, SUM(CASE WHEN recommend_score_nps IS NOT NULL AND TRANSLATE(recommend_score_nps, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.feedback
UNION ALL
SELECT 'raw.reminder_pilot_assignment' AS source_table, 'assignment_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN assignment_date IS NOT NULL AND assignment_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reminder_pilot_assignment
UNION ALL
SELECT 'raw.reminder_pilot_assignment' AS source_table, 'scheduled_date' AS source_column, 'date' AS target_type, SUM(CASE WHEN scheduled_date IS NOT NULL AND scheduled_date NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reminder_pilot_assignment
UNION ALL
SELECT 'raw.reporting_process_log' AS source_table, 'reporting_week_start' AS source_column, 'date' AS target_type, SUM(CASE WHEN reporting_week_start IS NOT NULL AND reporting_week_start NOT LIKE '____-__-__' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reporting_process_log
UNION ALL
SELECT 'raw.reporting_process_log' AS source_table, 'data_preparation_minutes' AS source_column, 'integer' AS target_type, SUM(CASE WHEN data_preparation_minutes IS NOT NULL AND TRANSLATE(data_preparation_minutes, '0123456789-', '') <> '' THEN 1 ELSE 0 END) AS invalid_values FROM raw.reporting_process_log;

-- review: only columns with a problem (expected: appointments.scheduled_start_at = 24)
SELECT
    source_table,
    source_column,
    target_type,
    invalid_values
FROM
    audit.conversion_check
WHERE
    invalid_values > 0;
