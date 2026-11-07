/*
PatientCare Analytics
Script 02: Create the four schemas (layers) of the pipeline

raw      the CSV files exactly as received, every column stored as TEXT
staging  cleaned, typed and de-duplicated working tables
audit    data-quality issue log and profiling results
core     the final star schema that Power BI reads
*/

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS core;

-- check: should return the four schema names
SELECT
    schema_name
FROM
    information_schema.schemata
WHERE
    schema_name IN ('raw', 'staging', 'audit', 'core')
ORDER BY
    schema_name;
