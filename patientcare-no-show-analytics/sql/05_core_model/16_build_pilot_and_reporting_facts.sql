/*
PatientCare Analytics
Script 16: Build the reminder pilot and reporting-efficiency facts

core.fact_reminder_pilot_assignment   1,409 pilot appointments, linked to
                                      fact_appointments and dim_clinic
core.fact_reporting_process_log       16 weekly reporting logs, with the
                                      total minutes per week added
*/

DROP TABLE IF EXISTS core.fact_reminder_pilot_assignment;
DROP TABLE IF EXISTS core.fact_reporting_process_log;

-- ---------------------------------------------------------------------------
-- fact_reminder_pilot_assignment
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_reminder_pilot_assignment AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pilot.pilot_record_id) AS pilot_assignment_key,
    pilot.pilot_record_id,
    COALESCE(appointment.appointment_key, 0) AS appointment_key,
    pilot.appointment_id,
    COALESCE(clinic.clinic_key, 0) AS clinic_key,
    pilot.clinic_id,
    CAST(TO_CHAR(pilot.assignment_date, 'YYYYMMDD') AS INTEGER) AS assignment_date_key,
    CAST(TO_CHAR(pilot.scheduled_date, 'YYYYMMDD') AS INTEGER) AS scheduled_date_key,
    pilot.assignment_date,
    pilot.scheduled_date,
    pilot.assignment_month,
    pilot.assignment_group,
    pilot.intervention_type,
    pilot.intervention_delivery_status,
    pilot.pilot_outcome,
    pilot.attendance_eligible_flag,
    pilot.no_show_flag,
    pilot.analysis_exclusion_reason,
    pilot.randomisation_block,
    pilot.assignment_method,
    pilot.pilot_phase
FROM
    staging.reminder_pilot_assignment_clean AS pilot
LEFT JOIN core.fact_appointments AS appointment
    ON appointment.appointment_id = pilot.appointment_id
LEFT JOIN core.dim_clinic AS clinic
    ON clinic.clinic_id = pilot.clinic_id;

ALTER TABLE core.fact_reminder_pilot_assignment ADD PRIMARY KEY (pilot_assignment_key);

-- ---------------------------------------------------------------------------
-- fact_reporting_process_log
-- ---------------------------------------------------------------------------

CREATE TABLE core.fact_reporting_process_log AS
SELECT
    ROW_NUMBER() OVER (ORDER BY report_log_id) AS reporting_log_key,
    report_log_id,
    CAST(TO_CHAR(reporting_week_start, 'YYYYMMDD') AS INTEGER) AS reporting_week_date_key,
    reporting_week_start,
    process_phase,
    reporting_method,
    data_preparation_minutes,
    validation_minutes,
    formatting_minutes,
    distribution_minutes,
    data_preparation_minutes + validation_minutes + formatting_minutes + distribution_minutes AS total_reporting_minutes
FROM
    staging.reporting_process_log_clean;

ALTER TABLE core.fact_reporting_process_log ADD PRIMARY KEY (reporting_log_key);

-- check: average weekly minutes before and after automation (expected 244.4 and 62.5)
SELECT
    process_phase,
    COUNT(*) AS weeks,
    ROUND(AVG(total_reporting_minutes), 1) AS average_weekly_minutes
FROM
    core.fact_reporting_process_log
GROUP BY
    process_phase;
