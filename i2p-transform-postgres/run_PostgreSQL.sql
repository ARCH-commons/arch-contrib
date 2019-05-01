-------------------------------------------------------------------------------------------------------------------------
-- run.sql Script
-- This is a PostgreSQL version script to build PopMedNet database. See MSSQL version for reference.
-- Orignal MSSQL version authored by: Jeff Klann, PhD
-- PostgreSQL version authored by: Dan Vianello (Washington University in St Louis), 04/11/2016
-- PostgreSQL version last modified by: Snehil Gupta (Washington University in St Louis), 07/25/2017 to include PCORNet CDM v3.1 changes

-- Note:
-- PostgresQL current version does not transform: Dispensing, Condition, Death, Death_Condition, PCORnet_Trial and PRO_CM. This is because WU datamart doesn't have data for these domains.
-- To successfully adopt the PostgreSQL version script, user must be able to work with foreign data wrapper and dblink module in PostgreSQL.
-- Please contact WU team at help@bmi.wustl.edu for questions or feedback regarding this script.
-------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
-- Assumption: Functions will be run under schema 'popmednet' of popmednet database. 
-- Maintain the order of functions from popmednet.pcornetclear() through popmednet.PCORNetEncounter() as described below. There are dependecies between these functions.
-- To improve performance, functions after popmednet.PCORNetEncounter() (i.e., popmednet.PCORNetEnroll() through popmednet.PCORNetLabResultCM()) can be run in parallel.
-- Run PCORNetReport() function at the very end.
-------------------------------------------------------------------------------------------------------------------------

select popmednet.pcornetclear();
select popmednet.PCORNetHarvest();
select popmednet.populate_pmn_labnormal();
select popmednet.pcornet_popcodelist();
select popmednet.PCORNetDemographics(min_percentile_setting=>[replace_with_kvalue]);  -- provide the appropriate k-value for each refresh
select popmednet.PCORNetEncounter();

select popmednet.PCORNetEnroll();
select popmednet.PCORNetDispensing();
select popmednet.PCORNetCondition();
select popmednet.PCORNetProcedure();
select popmednet.PCORNetDiagnosis();
select popmednet.PCORNetPrescribing();
select popmednet.PCORNetVital();
select popmednet.PCORNetLabResultCM();

select popmednet.PCORNetReport();

select * from popmednet.i2pReport;