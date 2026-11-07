/*
PatientCare Analytics
Script 10: Clean appointment events, doctor schedule sessions and reminders

These three feeds have no duplicates, so cleaning is only:
trim text, convert data types and standardise category spellings.
*/

DROP TABLE IF EXISTS staging.appointment_events_clean;
DROP TABLE IF EXISTS staging.schedule_sessions_clean;
DROP TABLE IF EXISTS staging.reminders_clean;

-- ---------------------------------------------------------------------------
-- Appointment events (257,288 rows): every status change in an appointment's life
-- ---------------------------------------------------------------------------

CREATE TABLE staging.appointment_events_clean AS
SELECT
    event.raw_row_id AS source_raw_row_id,
    TRIM(event.event_id) AS event_id,
    TRIM(event.appointment_id) AS appointment_id,
    CAST(event.event_sequence AS INTEGER) AS event_sequence,
    event_type_map.standard_value AS event_type,
    CAST(event.event_at AS TIMESTAMP) AS event_at,
    TRIM(event.from_status_raw) AS from_status,
    TRIM(event.to_status_raw) AS to_status,
    actor_map.standard_value AS actor_type,
    TRIM(event.reason_code_raw) AS reason_code
FROM
    raw.appointment_events AS event
LEFT JOIN staging.category_map AS event_type_map
    ON event_type_map.category_group = 'event_type'
   AND event_type_map.source_value = LOWER(TRIM(event.event_type_raw))
LEFT JOIN staging.category_map AS actor_map
    ON actor_map.category_group = 'actor_type'
   AND actor_map.source_value = LOWER(TRIM(event.actor_type_raw));

ALTER TABLE staging.appointment_events_clean ADD PRIMARY KEY (event_id);

-- ---------------------------------------------------------------------------
-- Doctor schedule sessions (17,788 rows): planned clinic sessions per doctor
-- ---------------------------------------------------------------------------

CREATE TABLE staging.schedule_sessions_clean AS
SELECT
    session.raw_row_id AS source_raw_row_id,
    TRIM(session.schedule_session_id) AS schedule_session_id,
    CAST(session.session_date AS DATE) AS session_date,
    TRIM(session.clinic_id) AS clinic_id,
    TRIM(session.doctor_id) AS doctor_id,
    CAST(session.planned_start_time AS TIME) AS planned_start_time,
    CAST(session.planned_end_time AS TIME) AS planned_end_time,
    CAST(session.slot_length_minutes AS INTEGER) AS slot_length_minutes,
    CAST(session.planned_slots AS INTEGER) AS planned_slots,
    CAST(session.blocked_slots AS INTEGER) AS blocked_slots,
    staging.to_yes_no(session.overbook_allowed_raw) AS overbook_allowed,
    status_map.standard_value AS session_status,
    TRIM(session.session_cancel_reason_raw) AS session_cancel_reason,
    TRIM(session.roster_batch_id) AS roster_batch_id
FROM
    raw.schedule_sessions AS session
LEFT JOIN staging.category_map AS status_map
    ON status_map.category_group = 'schedule_status'
   AND status_map.source_value = LOWER(TRIM(session.session_status_raw));

ALTER TABLE staging.schedule_sessions_clean ADD PRIMARY KEY (schedule_session_id);

-- ---------------------------------------------------------------------------
-- Reminders (86,527 rows): each SMS / WhatsApp / call reminder attempt
-- ---------------------------------------------------------------------------

CREATE TABLE staging.reminders_clean AS
SELECT
    reminder.raw_row_id AS source_raw_row_id,
    TRIM(reminder.reminder_id) AS reminder_id,
    TRIM(reminder.appointment_id) AS appointment_id,
    TRIM(reminder.patient_id) AS patient_id,
    type_map.standard_value AS reminder_type,
    channel_map.standard_value AS channel,
    TRIM(reminder.provider_name) AS provider_name,
    CAST(reminder.attempt_number AS INTEGER) AS attempt_number,
    CAST(reminder.scheduled_send_at AS TIMESTAMP) AS scheduled_send_at,
    CAST(reminder.sent_at AS TIMESTAMP) AS sent_at,
    delivery_map.standard_value AS delivery_status,
    CAST(reminder.delivered_at AS TIMESTAMP) AS delivered_at,
    CAST(reminder.read_at AS TIMESTAMP) AS read_at,
    TRIM(reminder.failure_reason_raw) AS failure_reason,
    TRIM(reminder.template_code) AS template_code,
    TRIM(reminder.language_raw) AS language,
    TRIM(reminder.provider_message_id) AS provider_message_id
FROM
    raw.reminders AS reminder
LEFT JOIN staging.category_map AS type_map
    ON type_map.category_group = 'reminder_type'
   AND type_map.source_value = LOWER(TRIM(reminder.reminder_type_raw))
LEFT JOIN staging.category_map AS channel_map
    ON channel_map.category_group = 'reminder_channel'
   AND channel_map.source_value = LOWER(TRIM(reminder.channel_raw))
LEFT JOIN staging.category_map AS delivery_map
    ON delivery_map.category_group = 'delivery_status'
   AND delivery_map.source_value = LOWER(TRIM(reminder.delivery_status_raw));

ALTER TABLE staging.reminders_clean ADD PRIMARY KEY (reminder_id);

-- check: raw rows vs clean rows (should match)
SELECT 'appointment_events' AS table_name, (SELECT COUNT(*) FROM raw.appointment_events) AS raw_rows, (SELECT COUNT(*) FROM staging.appointment_events_clean) AS clean_rows
UNION ALL SELECT 'schedule_sessions', (SELECT COUNT(*) FROM raw.schedule_sessions), (SELECT COUNT(*) FROM staging.schedule_sessions_clean)
UNION ALL SELECT 'reminders', (SELECT COUNT(*) FROM raw.reminders), (SELECT COUNT(*) FROM staging.reminders_clean);
