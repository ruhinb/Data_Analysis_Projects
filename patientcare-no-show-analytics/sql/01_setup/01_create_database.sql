/*
PatientCare Analytics
Script 01: Create the project database

Run this while connected to the default "postgres" database.
Every other script (02-18) runs against the new patientcare_analytics database,
so after this script, switch the connection to patientcare_analytics.

DROP DATABASE fails if any connection is still open on patientcare_analytics.
Disconnect from it first when rebuilding from scratch.
*/

DROP DATABASE IF EXISTS patientcare_analytics;

CREATE DATABASE patientcare_analytics;
