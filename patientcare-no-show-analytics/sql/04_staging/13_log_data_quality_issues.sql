/*
PatientCare Analytics
Script 13: Log data-quality issues

Problem rows are NOT deleted. Each problem is written to audit.data_quality_issues
with the source row, the column, the original value and a plain description.
The report can then show how many records are affected and why, and every
issue can be traced back to the exact row in the raw file.

20 checks, grouped by the cleaning stage they belong to.
Severity: Error   = the value is wrong or impossible
          Warning = the value is missing or unusual but the row is still usable
*/

DROP TABLE IF EXISTS audit.data_quality_issues;

CREATE TABLE audit.data_quality_issues (
    issue_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    check_stage TEXT NOT NULL,
    source_table TEXT NOT NULL,
    source_raw_row_id INT,
    business_key TEXT,
    column_name TEXT NOT NULL,
    issue_type TEXT NOT NULL,
    severity TEXT NOT NULL,
    raw_value TEXT,
    issue_description TEXT NOT NULL,
    detected_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================================================
-- Stage 1: master tables
-- ===========================================================================

-- Check 1: patient gender not supplied (174 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_master_cleanup',
    'raw.patients',
    raw_row_id,
    TRIM(patient_id),
    'gender_raw',
    'MISSING_OPTIONAL_CATEGORY',
    'Warning',
    gender_raw,
    'Patient gender was not supplied.'
FROM
    raw.patients
WHERE
    gender_raw IS NULL;

-- ===========================================================================
-- Stage 2: appointments
-- ===========================================================================

-- Check 2: duplicate extract copies that were removed (266 rows)
WITH numbered_copies AS (
    SELECT
        source_raw_row_id,
        appointment_record_id,
        appointment_id,
        ROW_NUMBER() OVER (
            PARTITION BY appointment_record_id
            ORDER BY source_raw_row_id
        ) AS copy_number
    FROM
        staging.appointments_typed
)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    source_raw_row_id,
    appointment_id,
    'appointment_record_id',
    'DUPLICATE_EXTRACT_ROW',
    'Warning',
    appointment_record_id,
    'An extra copy of the same appointment record version was removed.'
FROM
    numbered_copies
WHERE
    copy_number > 1;

-- Check 3: specialty not supplied (449 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'specialty_raw',
    'MISSING_OPTIONAL_CATEGORY',
    'Warning',
    source.specialty_raw,
    'Appointment specialty was not supplied.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
WHERE
    source.specialty_raw IS NULL;

-- Check 4: doctor not recorded on the appointment (220 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'doctor_id',
    'MISSING_OPTIONAL_REFERENCE',
    'Warning',
    source.doctor_id,
    'Doctor ID is missing. The appointment is retained for reconciliation.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
WHERE
    appointment.doctor_id IS NULL;

-- Check 5: scheduled start is not a real date, e.g. 31 February (23 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'scheduled_start_at',
    'INVALID_TIMESTAMP',
    'Error',
    source.scheduled_start_at,
    'Scheduled start timestamp could not be converted.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
WHERE
    source.scheduled_start_at IS NOT NULL
    AND appointment.scheduled_start_at IS NULL;

-- Check 6: patient ID not found in the patient table (44 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'patient_id',
    'ORPHAN_REFERENCE',
    'Error',
    source.patient_id,
    'Patient ID does not exist in the cleaned patient master.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
WHERE
    appointment.patient_id IS NOT NULL
    AND appointment.patient_reference_valid = FALSE;

-- Check 7: clinic ID not found in the clinic table (41 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'clinic_id',
    'ORPHAN_REFERENCE',
    'Error',
    source.clinic_id,
    'Clinic ID does not exist in the cleaned clinic master.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
WHERE
    appointment.clinic_id IS NOT NULL
    AND appointment.clinic_reference_valid = FALSE;

-- Check 8: follow-up points to a parent appointment that does not exist (51 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'parent_appointment_id',
    'ORPHAN_PARENT_REFERENCE',
    'Warning',
    source.parent_appointment_id,
    'Parent appointment ID does not exist in the consolidated appointment set.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
LEFT JOIN staging.appointments_clean AS parent
    ON parent.appointment_id = appointment.parent_appointment_id
WHERE
    appointment.parent_appointment_id IS NOT NULL
    AND parent.appointment_id IS NULL;

-- Check 9: consultation started before the patient checked in (0 rows in this extract)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'consultation_start_at',
    'CONSULTATION_BEFORE_CHECK_IN',
    'Warning',
    source.consultation_start_at,
    'Consultation start is earlier than patient check-in.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
WHERE
    appointment.consultation_start_at < appointment.check_in_at;

-- Check 10: booked after the appointment was due to start (2 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_appointment_cleanup',
    'raw.appointments',
    appointment.source_raw_row_id,
    appointment.appointment_id,
    'scheduled_start_at',
    'BOOKED_AFTER_SCHEDULED_START',
    'Error',
    source.scheduled_start_at,
    'Booking timestamp is later than the scheduled start timestamp.'
FROM
    staging.appointments_clean AS appointment
INNER JOIN raw.appointments AS source
    ON source.raw_row_id = appointment.source_raw_row_id
WHERE
    appointment.booked_at > appointment.scheduled_start_at;

-- ===========================================================================
-- Stage 3: events and reminders
-- ===========================================================================

-- Check 11: stored event sequence does not match the order of the timestamps (2,015 rows)
WITH expected_order AS (
    SELECT
        source_raw_row_id,
        event_id,
        event_sequence,
        ROW_NUMBER() OVER (
            PARTITION BY appointment_id
            ORDER BY event_at, event_id
        ) AS expected_sequence
    FROM
        staging.appointment_events_clean
)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_operational_cleanup',
    'raw.appointment_events',
    source_raw_row_id,
    event_id,
    'event_sequence',
    'EVENT_SEQUENCE_MISMATCH',
    'Warning',
    CAST(event_sequence AS TEXT),
    'Stored event sequence does not match chronological lifecycle order.'
FROM
    expected_order
WHERE
    event_sequence <> expected_sequence;

-- Check 12: reminder marked Delivered but has no delivered time (324 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_operational_cleanup',
    'raw.reminders',
    reminder.source_raw_row_id,
    reminder.reminder_id,
    'delivered_at',
    'DELIVERED_WITHOUT_TIMESTAMP',
    'Error',
    source.delivered_at,
    'Delivery status is Delivered but delivered_at is missing.'
FROM
    staging.reminders_clean AS reminder
INNER JOIN raw.reminders AS source
    ON source.raw_row_id = reminder.source_raw_row_id
WHERE
    reminder.delivery_status = 'Delivered'
    AND reminder.delivered_at IS NULL;

-- Check 13: reminder has a read time but no delivered time (70 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_operational_cleanup',
    'raw.reminders',
    reminder.source_raw_row_id,
    reminder.reminder_id,
    'read_at',
    'READ_WITHOUT_DELIVERY_TIMESTAMP',
    'Warning',
    source.read_at,
    'A read timestamp exists while delivered_at is missing.'
FROM
    staging.reminders_clean AS reminder
INNER JOIN raw.reminders AS source
    ON source.raw_row_id = reminder.source_raw_row_id
WHERE
    reminder.read_at IS NOT NULL
    AND reminder.delivered_at IS NULL;

-- ===========================================================================
-- Stage 4: telemedicine, payments and feedback
-- ===========================================================================

-- Check 14: duplicate payment extract copies that were removed (136 rows)
WITH numbered_copies AS (
    SELECT
        source_raw_row_id,
        payment_record_id,
        payment_id,
        ROW_NUMBER() OVER (
            PARTITION BY payment_record_id
            ORDER BY source_raw_row_id
        ) AS copy_number
    FROM
        staging.payments_typed
)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_service_finance_feedback_cleanup',
    'raw.payments',
    source_raw_row_id,
    payment_id,
    'payment_record_id',
    'DUPLICATE_EXTRACT_ROW',
    'Warning',
    payment_record_id,
    'An extra copy of the same payment record version was removed.'
FROM
    numbered_copies
WHERE
    copy_number > 1;

-- Check 15: telemedicine session status disagrees with the appointment status (27 rows)
--           e.g. the appointment says Completed but the video session says Cancelled
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_service_finance_feedback_cleanup',
    'raw.telemedicine_sessions',
    session.source_raw_row_id,
    session.telemedicine_session_id,
    'session_status_raw',
    'SESSION_STATUS_MISMATCH',
    'Error',
    session.session_status,
    'Telemedicine session status conflicts with the consolidated appointment status.'
FROM
    staging.telemedicine_sessions_clean AS session
INNER JOIN staging.appointments_clean AS appointment
    ON appointment.appointment_id = session.appointment_id
WHERE
    CASE
        WHEN appointment.appointment_status = 'Completed'
             AND session.session_status IN ('Completed', 'Completed with issue') THEN 'match'
        WHEN appointment.appointment_status = 'No-show'
             AND session.session_status = 'Patient did not join' THEN 'match'
        WHEN appointment.appointment_status = session.session_status THEN 'match'
        ELSE 'mismatch'
    END = 'mismatch';

-- Check 16: net amount is not gross amount minus discount (91 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_service_finance_feedback_cleanup',
    'raw.payments',
    payment.source_raw_row_id,
    payment.payment_id,
    'net_amount_bdt',
    'PAYMENT_MATH_MISMATCH',
    'Error',
    source.net_amount_bdt,
    'Net amount does not equal gross amount minus discount.'
FROM
    staging.payments_clean AS payment
INNER JOIN raw.payments AS source
    ON source.raw_row_id = payment.source_raw_row_id
WHERE
    ABS(payment.net_amount_bdt - (payment.gross_amount_bdt - payment.discount_amount_bdt)) > 0.01;

-- Check 17: a payment amount is negative (64 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_service_finance_feedback_cleanup',
    'raw.payments',
    payment.source_raw_row_id,
    payment.payment_id,
    'amount_paid_bdt',
    'NEGATIVE_FINANCIAL_AMOUNT',
    'Error',
    source.amount_paid_bdt,
    'One or more payment amounts are negative.'
FROM
    staging.payments_clean AS payment
INNER JOIN raw.payments AS source
    ON source.raw_row_id = payment.source_raw_row_id
WHERE
    payment.gross_amount_bdt < 0
    OR payment.discount_amount_bdt < 0
    OR payment.net_amount_bdt < 0
    OR payment.amount_paid_bdt < 0
    OR payment.refund_amount_bdt < 0;

-- Check 18: survey answered before it was sent (315 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_service_finance_feedback_cleanup',
    'raw.feedback',
    feedback.source_raw_row_id,
    feedback.survey_id,
    'responded_at',
    'RESPONSE_BEFORE_SURVEY_SENT',
    'Error',
    source.responded_at,
    'Survey response timestamp is earlier than the sent timestamp.'
FROM
    staging.feedback_clean AS feedback
INNER JOIN raw.feedback AS source
    ON source.raw_row_id = feedback.source_raw_row_id
WHERE
    feedback.responded_at < feedback.survey_sent_at;

-- Check 19: overall rating outside the 1-5 scale (16 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_service_finance_feedback_cleanup',
    'raw.feedback',
    feedback.source_raw_row_id,
    feedback.survey_id,
    'overall_rating',
    'RATING_OUT_OF_RANGE',
    'Error',
    source.overall_rating,
    'Overall rating must be between 1 and 5.'
FROM
    staging.feedback_clean AS feedback
INNER JOIN raw.feedback AS source
    ON source.raw_row_id = feedback.source_raw_row_id
WHERE
    feedback.overall_rating NOT BETWEEN 1 AND 5;

-- Check 20: recommendation (NPS) score outside the 0-10 scale (14 rows)
INSERT INTO audit.data_quality_issues (check_stage, source_table, source_raw_row_id, business_key, column_name, issue_type, severity, raw_value, issue_description)
SELECT
    'staging_service_finance_feedback_cleanup',
    'raw.feedback',
    feedback.source_raw_row_id,
    feedback.survey_id,
    'recommend_score_nps',
    'NPS_OUT_OF_RANGE',
    'Error',
    source.recommend_score_nps,
    'NPS recommendation score must be between 0 and 10.'
FROM
    staging.feedback_clean AS feedback
INNER JOIN raw.feedback AS source
    ON source.raw_row_id = feedback.source_raw_row_id
WHERE
    feedback.recommend_score_nps NOT BETWEEN 0 AND 10;

-- ---------------------------------------------------------------------------
-- Summary: issues by table and type (expected total: 4,342)
-- ---------------------------------------------------------------------------

SELECT
    source_table,
    issue_type,
    severity,
    COUNT(*) AS issues
FROM
    audit.data_quality_issues
GROUP BY
    source_table,
    issue_type,
    severity
ORDER BY
    source_table,
    issues DESC;
