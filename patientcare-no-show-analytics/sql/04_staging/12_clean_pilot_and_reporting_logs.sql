/*
PatientCare Analytics
Script 12: Clean the reminder pilot and reporting-process logs

reminder_pilot_assignment (1,409 rows)
    One row per appointment in the 30 April - 15 June 2023 reminder pilot
    (semi-urban patients, appointments before 12:00), showing which
    group it was assigned to (Standard or Enhanced reminder), whether the
    enhanced reminder was delivered, and the attendance outcome.

reporting_process_log (16 rows)
    Minutes spent on the weekly report, by stage, for 8 weeks before and
    8 weeks after the reporting workflow was automated.
*/

DROP TABLE IF EXISTS staging.reminder_pilot_assignment_clean;
DROP TABLE IF EXISTS staging.reporting_process_log_clean;

CREATE TABLE staging.reminder_pilot_assignment_clean AS
SELECT
    raw_row_id AS source_raw_row_id,
    TRIM(pilot_record_id) AS pilot_record_id,
    TRIM(appointment_id) AS appointment_id,
    CAST(assignment_date AS DATE) AS assignment_date,
    CAST(scheduled_date AS DATE) AS scheduled_date,
    TRIM(clinic_id) AS clinic_id,
    TRIM(assignment_month) AS assignment_month,
    TRIM(assignment_group) AS assignment_group,
    TRIM(intervention_type) AS intervention_type,
    TRIM(intervention_delivery_status) AS intervention_delivery_status,
    TRIM(pilot_outcome) AS pilot_outcome,
    staging.to_yes_no(attendance_eligible_flag) AS attendance_eligible_flag,
    staging.to_yes_no(no_show_flag) AS no_show_flag,
    TRIM(analysis_exclusion_reason) AS analysis_exclusion_reason,
    TRIM(randomisation_block) AS randomisation_block,
    TRIM(assignment_method) AS assignment_method,
    TRIM(pilot_phase) AS pilot_phase
FROM
    raw.reminder_pilot_assignment;

ALTER TABLE staging.reminder_pilot_assignment_clean ADD PRIMARY KEY (pilot_record_id);

CREATE TABLE staging.reporting_process_log_clean AS
SELECT
    raw_row_id AS source_raw_row_id,
    TRIM(report_log_id) AS report_log_id,
    CAST(reporting_week_start AS DATE) AS reporting_week_start,
    TRIM(process_phase) AS process_phase,
    TRIM(reporting_method) AS reporting_method,
    CAST(data_preparation_minutes AS INTEGER) AS data_preparation_minutes,
    CAST(validation_minutes AS INTEGER) AS validation_minutes,
    CAST(formatting_minutes AS INTEGER) AS formatting_minutes,
    CAST(distribution_minutes AS INTEGER) AS distribution_minutes
FROM
    raw.reporting_process_log;

ALTER TABLE staging.reporting_process_log_clean ADD PRIMARY KEY (report_log_id);

-- check: pilot group sizes (expected 704 standard, 705 enhanced)
SELECT
    assignment_group,
    COUNT(*) AS appointments,
    SUM(CASE WHEN attendance_eligible_flag THEN 1 ELSE 0 END) AS attendance_eligible,
    SUM(CASE WHEN no_show_flag THEN 1 ELSE 0 END) AS no_shows
FROM
    staging.reminder_pilot_assignment_clean
GROUP BY
    assignment_group;
