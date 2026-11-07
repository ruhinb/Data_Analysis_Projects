/*
PatientCare Analytics
Script 07: Create the cleaning helpers

1. staging.category_map
   A lookup table that turns every spelling found in the raw data into one
   standard label, e.g. 'done', 'complete' and 'completed' -> 'Completed'.
   Raw values are matched in lower case with spaces trimmed:
       LEFT JOIN staging.category_map AS status_map
           ON status_map.category_group = 'appointment_status'
          AND status_map.source_value = LOWER(TRIM(appointment.appointment_status_raw))
   If a new spelling ever appears, add one row here instead of editing the
   cleaning scripts.

2. staging.to_yes_no(text)
   A small function that turns the different yes/no spellings
   (Yes, Y, 1, TRUE / No, N, 0, FALSE) into a real BOOLEAN.
*/

-- ---------------------------------------------------------------------------
-- 1. Category lookup table
-- ---------------------------------------------------------------------------

DROP TABLE IF EXISTS staging.category_map;

CREATE TABLE staging.category_map (
    category_group TEXT NOT NULL,
    source_value TEXT NOT NULL,
    standard_value TEXT NOT NULL,
    PRIMARY KEY (category_group, source_value)
);

INSERT INTO staging.category_map (category_group, source_value, standard_value)
VALUES
    -- actor type
    ('actor_type', 'clinic staff', 'Clinic staff'),
    ('actor_type', 'doctor', 'Doctor'),
    ('actor_type', 'patient', 'Patient'),
    ('actor_type', 'system', 'System'),

    -- appointment status
    ('appointment_status', 'canceled', 'Cancelled'),
    ('appointment_status', 'cancelled', 'Cancelled'),
    ('appointment_status', 'complete', 'Completed'),
    ('appointment_status', 'completed', 'Completed'),
    ('appointment_status', 'done', 'Completed'),
    ('appointment_status', 'did not attend', 'No-show'),
    ('appointment_status', 'no show', 'No-show'),
    ('appointment_status', 'no-show', 'No-show'),
    ('appointment_status', 'noshow', 'No-show'),
    ('appointment_status', 're-scheduled', 'Rescheduled'),
    ('appointment_status', 'reschedule', 'Rescheduled'),
    ('appointment_status', 'rescheduled', 'Rescheduled'),
    ('appointment_status', '?', 'Status review required'),
    ('appointment_status', 'pending review', 'Status review required'),
    ('appointment_status', 'status_missing', 'Status review required'),
    ('appointment_status', 'unknown', 'Status review required'),

    -- booking channel
    ('booking_channel', 'app', 'App'),
    ('booking_channel', 'mobile app', 'App'),
    ('booking_channel', 'mobile_app', 'App'),
    ('booking_channel', 'call center', 'Call centre'),
    ('booking_channel', 'call centre', 'Call centre'),
    ('booking_channel', 'phone', 'Call centre'),
    ('booking_channel', 'front desk', 'Staff'),
    ('booking_channel', 'staff', 'Staff'),
    ('booking_channel', 'staff booking', 'Staff'),
    ('booking_channel', 'walk in', 'Walk-in'),
    ('booking_channel', 'walk-in', 'Walk-in'),
    ('booking_channel', 'walkin', 'Walk-in'),
    ('booking_channel', 'web', 'Web'),
    ('booking_channel', 'web_portal', 'Web'),
    ('booking_channel', 'website', 'Web'),

    -- consultation mode
    ('consultation_mode', 'clinic', 'In-person'),
    ('consultation_mode', 'in person', 'In-person'),
    ('consultation_mode', 'in-person', 'In-person'),
    ('consultation_mode', 'telemedicine', 'Telemedicine'),
    ('consultation_mode', 'video', 'Telemedicine'),
    ('consultation_mode', 'virtual', 'Telemedicine'),

    -- delivery status
    ('delivery_status', 'delivered', 'Delivered'),
    ('delivery_status', 'failed', 'Failed'),
    ('delivery_status', 'undelivered', 'Failed'),
    ('delivery_status', 'pending', 'Pending'),
    ('delivery_status', 'queued', 'Pending'),
    ('delivery_status', 'unknown', 'Unknown'),

    -- event type
    ('event_type', 'cancelled', 'Cancelled'),
    ('event_type', 'checked in', 'Checked in'),
    ('event_type', 'completed', 'Completed'),
    ('event_type', 'confirmed', 'Confirmed'),
    ('event_type', 'created', 'Created'),
    ('event_type', 'no-show', 'No-show'),
    ('event_type', 'rescheduled', 'Rescheduled'),

    -- gender
    ('gender', 'f', 'Female'),
    ('gender', 'female', 'Female'),
    ('gender', 'm', 'Male'),
    ('gender', 'male', 'Male'),
    ('gender', 'not stated', 'Not stated'),
    ('gender', 'unknown', 'Not stated'),
    ('gender', 'o', 'Other'),
    ('gender', 'other', 'Other'),

    -- patient status
    ('patient_status', 'active', 'Active'),
    ('patient_status', 'deceased', 'Deceased'),
    ('patient_status', 'dormant', 'Dormant'),
    ('patient_status', 'inactive', 'Inactive'),

    -- payment status
    ('payment_status', 'failed', 'Failed'),
    ('payment_status', 'paid', 'Paid'),
    ('payment_status', 'partial', 'Partial'),
    ('payment_status', 'pending', 'Pending'),
    ('payment_status', 'pending refund', 'Pending refund'),
    ('payment_status', 'refunded', 'Refunded'),

    -- priority level
    ('priority_level', 'priority', 'Priority'),
    ('priority_level', 'routine', 'Routine'),
    ('priority_level', 'urgent', 'Urgent'),

    -- reminder channel
    ('reminder_channel', 'call', 'Call'),
    ('reminder_channel', 'sms', 'SMS'),
    ('reminder_channel', 'whatsapp', 'WhatsApp'),

    -- reminder type
    ('reminder_type', '2-hour reminder', '2-hour reminder'),
    ('reminder_type', '24-hour reminder', '24-hour reminder'),

    -- schedule status
    ('schedule_status', 'canceled', 'Cancelled'),
    ('schedule_status', 'cancelled', 'Cancelled'),
    ('schedule_status', 'confirmed', 'Scheduled'),
    ('schedule_status', 'scheduled', 'Scheduled'),

    -- specialty
    ('specialty', 'cardiology', 'Cardiology'),
    ('specialty', 'dermatology', 'Dermatology'),
    ('specialty', 'ent', 'ENT'),
    ('specialty', 'endocrinology', 'Endocrinology'),
    ('specialty', 'gastroenterology', 'Gastroenterology'),
    ('specialty', 'general medicine', 'General Medicine'),
    ('specialty', 'neurology', 'Neurology'),
    ('specialty', 'obstetrics & gynecology', 'Obstetrics & Gynecology'),
    ('specialty', 'ophthalmology', 'Ophthalmology'),
    ('specialty', 'orthopedics', 'Orthopedics'),
    ('specialty', 'pediatrics', 'Pediatrics'),
    ('specialty', 'psychiatry', 'Psychiatry'),

    -- telemedicine status
    ('telemedicine_status', 'cancelled', 'Cancelled'),
    ('telemedicine_status', 'completed', 'Completed'),
    ('telemedicine_status', 'completed with issue', 'Completed with issue'),
    ('telemedicine_status', 'patient did not join', 'Patient did not join'),
    ('telemedicine_status', 'rescheduled', 'Rescheduled'),
    ('telemedicine_status', 'status review required', 'Status review required'),

    -- visit type
    ('visit_type', 'diagnostic review', 'Diagnostic review'),
    ('visit_type', 'follow-up', 'Follow-up'),
    ('visit_type', 'new consultation', 'New consultation'),
    ('visit_type', 'procedure review', 'Procedure review');

-- check: number of spellings mapped per group
SELECT
    category_group,
    COUNT(*) AS spellings_mapped
FROM
    staging.category_map
GROUP BY
    category_group
ORDER BY
    category_group;

-- ---------------------------------------------------------------------------
-- 2. Yes/no to BOOLEAN function
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION staging.to_yes_no(raw_value TEXT)
RETURNS BOOLEAN
LANGUAGE SQL
AS $$
    SELECT
        CASE
            WHEN LOWER(TRIM(raw_value)) IN ('yes', 'y', '1', 'true') THEN TRUE
            WHEN LOWER(TRIM(raw_value)) IN ('no', 'n', '0', 'false') THEN FALSE
            ELSE NULL
        END
$$;

-- check: expected TRUE, FALSE, NULL
SELECT
    staging.to_yes_no('Y') AS should_be_true,
    staging.to_yes_no('0') AS should_be_false,
    staging.to_yes_no('maybe') AS should_be_null;
