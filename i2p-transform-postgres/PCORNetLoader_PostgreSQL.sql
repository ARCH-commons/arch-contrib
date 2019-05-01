-------------------------------------------------------------------------------------------------------------------------
-- PCORNetLoader.sql Script
-- This is a PostgreSQL version script to build PopMedNet database. See MSSQL version for reference.
-- Orignal MSSQL version authored by: Jeff Klann, PhD; Aaron Abend; Arturo Torres;  Matt Joss
-- PostgreSQL version authored by: Dan Vianello (Washington University in St Louis), 04/11/2016
-- PostgreSQL version last modified by: Snehil Gupta (Washington University in St Louis), 07/25/2017 to include PCORNet CDM v3.1 changes

-- Note:
-- PostgresQL current version does not transform: Dispensing, Condition, Death, Death_Condition, PCORnet_Trial and PRO_CM. This is because WU datamart doesn't have data for these domains.
-- To successfully adopt the PostgreSQL version script, user must be able to work with foreign data wrapper and dblink module in PostgreSQL.
-- Please contact WU team at help@bmi.wustl.edu for questions or feedback regarding this script.




-------------------------------------------------------------------------------------------------------------------------
-- CREATE THE TABLES 
-- Table Definitions below follow requirements defined in PCORNet CDMv3.1
-- Please edit this section of the script for your institution/datamart, as appropriate.
-------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
-- Assumption: Tables will be created under schema 'popmednet' of popmednet database. 
-------------------------------------------------------------------------------------------------------------------------

-------------------------------- DEMOGRAPHICS --------------------------------

-- DROP TABLE popmednet.pmndemographic;
CREATE TABLE popmednet.pmndemographic
(
  patid character varying(50) NOT NULL,
  birth_date timestamp without time zone,
  birth_time character varying(5),
  sex character varying(2),
  hispanic character varying(2),
  biobank_flag character varying(1) DEFAULT 'N'::character varying, -- change/remove the default as appropriate for your datamart
  race character varying(2),
  raw_sex character varying(50),
  raw_hispanic character varying(50),
  raw_race character varying(50),
  sexual_orientation character varying(2),
  gender_identity character varying(2),
  raw_sexual_orientation character varying(50),
  raw_gender_identity character varying(50),
  CONSTRAINT pmndemographic_pkey PRIMARY KEY (patid)
)
WITH (
  OIDS=FALSE
);


-- DROP INDEX popmednet.idx_pmndemographic_patid;
CREATE INDEX idx_pmndemographic_patid
  ON popmednet.pmndemographic
  USING btree
  (patid COLLATE pg_catalog."default");


-- DROP INDEX popmednet.idx_pmndemographic_patid_int;
CREATE INDEX idx_pmndemographic_patid_int
  ON popmednet.pmndemographic
  USING btree
  ((patid::integer));


-------------------------------- ENCOUNTER --------------------------------

-- DROP TABLE popmednet.pmnencounter;
CREATE TABLE popmednet.pmnencounter
(
  patid character varying(50) NOT NULL,
  encounterid character varying(50) NOT NULL,
  admit_date timestamp without time zone,
  admit_time character varying(5),
  discharge_date timestamp without time zone,
  discharge_time character varying(5),
  providerid character varying(50),
  facility_location character varying(3),
  enc_type character varying(2) NOT NULL,
  facilityid character varying(50),
  discharge_disposition character varying(2),
  discharge_status character varying(2),
  drg character varying(3),
  drg_type character varying(2),
  admitting_source character varying(2),
  raw_siteid character varying(50),
  raw_enc_type character varying(50),
  raw_discharge_disposition character varying(50),
  raw_discharge_status character varying(50),
  raw_drg_type character varying(50),
  raw_admitting_source character varying(50),
  CONSTRAINT pmnencounter_pkey PRIMARY KEY (encounterid),
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

-- DROP INDEX popmednet.idx_pmnencounter_admit_date;
CREATE INDEX idx_pmnencounter_admit_date
  ON popmednet.pmnencounter
  USING btree
  (admit_date);


-- DROP INDEX popmednet.idx_pmnencounter_enc_pat_admit_discharge;
CREATE INDEX idx_pmnencounter_enc_pat_admit_discharge
  ON popmednet.pmnencounter
  USING btree
  (encounterid COLLATE pg_catalog."default", patid COLLATE pg_catalog."default", admit_date, discharge_date);


-- DROP INDEX popmednet.idx_pmnencounter_encnum;
CREATE INDEX idx_pmnencounter_encnum
  ON popmednet.pmnencounter
  USING btree
  ((encounterid::integer));


-- DROP INDEX popmednet.idx_pmnencounter_patnum;
CREATE INDEX idx_pmnencounter_patnum
  ON popmednet.pmnencounter
  USING btree
  ((patid::integer));


-------------------------------- ENROLLMENT --------------------------------

-- DROP TABLE popmednet.pmnenrollment;
CREATE TABLE popmednet.pmnenrollment
(
  patid character varying(50) NOT NULL,
  enr_start_date timestamp without time zone NOT NULL,
  enr_end_date timestamp without time zone,
  chart character varying(1),
  enr_basis character varying(1) NOT NULL,
  raw_chart character varying(50),
  raw_basis character varying(50),
  CONSTRAINT pmnenrollment_pkey PRIMARY KEY (patid, enr_start_date, enr_basis),
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

-- DROP INDEX popmednet.idx_enrollment_index;
CREATE INDEX idx_enrollment_index
  ON popmednet.pmnenrollment
  USING btree
  (enr_basis COLLATE pg_catalog."default");
  

-------------------------------- DIAGNOSIS --------------------------------

  
-- DROP TABLE popmednet.pmndiagnosis;
CREATE TABLE popmednet.pmndiagnosis
(
  diagnosisid bigserial NOT NULL,
  patid character varying(50) NOT NULL,
  encounterid character varying(50) NOT NULL,
  enc_type character varying(2),
  admit_date timestamp without time zone,
  providerid character varying(50),
  dx character varying(18) NOT NULL,
  dx_type character varying(2) NOT NULL,
  dx_source character varying(2) NOT NULL,
  pdx character varying(2),
  raw_dx character varying(50),
  raw_dx_type character varying(50),
  raw_dx_source character varying(50),
  raw_origdx character varying(50),
  raw_pdx character varying(50),
  dx_origin character varying(2),
  CONSTRAINT pmndiagnosis_pkey PRIMARY KEY (diagnosisid),
  CONSTRAINT encounterid FOREIGN KEY (encounterid)
      REFERENCES popmednet.pmnencounter (encounterid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);

-- DROP INDEX popmednet.idx_diagnosis_encounterid_index;
CREATE INDEX idx_diagnosis_encounterid_index
  ON popmednet.pmndiagnosis
  USING btree
  (encounterid COLLATE pg_catalog."default");


-- DROP INDEX popmednet.idx_diagnosis_index;
CREATE INDEX idx_diagnosis_index
  ON popmednet.pmndiagnosis
  USING btree
  (dx COLLATE pg_catalog."default");


-- DROP INDEX popmednet.idx_diagnosis_patid_index;
CREATE INDEX idx_diagnosis_patid_index
  ON popmednet.pmndiagnosis
  USING btree
  (patid COLLATE pg_catalog."default");



-------------------------------- PROCEDURES --------------------------------

-- DROP TABLE popmednet.pmnprocedures;
CREATE TABLE popmednet.pmnprocedures
(
  proceduresid bigint NOT NULL DEFAULT nextval('popmednet.pmnprocedure_proceduresid_seq'::regclass),
  patid character varying(50) NOT NULL,
  encounterid character varying(50) NOT NULL,
  enc_type character varying(2),
  admit_date timestamp without time zone,
  providerid character varying(50),
  px_date timestamp without time zone,
  px character varying(11) NOT NULL,
  px_type character varying(2) NOT NULL,
  px_source character varying(2) DEFAULT 'BI'::character varying, -- change/remove the default as appropriate for your datamart
  raw_px character varying(50),
  raw_px_type character varying(50),
  CONSTRAINT pmnprocedure_pkey PRIMARY KEY (proceduresid),
  CONSTRAINT encounterid FOREIGN KEY (encounterid)
      REFERENCES popmednet.pmnencounter (encounterid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-- DROP INDEX popmednet.idx_procedure_index;
CREATE INDEX idx_procedure_index
  ON popmednet.pmnprocedures
  USING btree
  (px COLLATE pg_catalog."default");


  
-------------------------------- PRESCRIBING --------------------------------  
  
  
-- DROP TABLE popmednet.pmnprescribing;
CREATE TABLE popmednet.pmnprescribing
(
  prescribingid bigserial NOT NULL,
  patid character varying(50) NOT NULL,
  encounterid character varying(50),
  rx_providerid character varying(50),
  rx_order_date timestamp without time zone,
  rx_order_time character varying(5),
  rx_start_date timestamp without time zone,
  rx_end_date timestamp without time zone,
  rx_quantity numeric(15,8),
  rx_refills numeric(15,8),
  rx_days_supply numeric(15,8),
  rx_frequency character varying(2),
  rx_basis character varying(2),
  rxnorm_cui character varying(8),
  raw_rx_med_name character varying(50),
  raw_rx_frequency character varying(50),
  raw_rxnorm_cui character varying(50),
  rx_quantity_unit character varying(2),
  raw_rx_quantity character varying(50),
  raw_rx_ndc character varying(50),
  CONSTRAINT pmnprescribing_pkey PRIMARY KEY (prescribingid),
  CONSTRAINT encounterid FOREIGN KEY (encounterid)
      REFERENCES popmednet.pmnencounter (encounterid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-- DROP INDEX popmednet.idx_prescribing_index;
CREATE INDEX idx_prescribing_index
  ON popmednet.pmnprescribing
  USING btree
  (rxnorm_cui COLLATE pg_catalog."default");



-------------------------------- DISPENSING --------------------------------

-- DROP TABLE popmednet.pmndispensing;
CREATE TABLE popmednet.pmndispensing
(
  dispensingid bigserial NOT NULL,
  patid character varying(50) NOT NULL,
  prescribingid bigint,
  dispense_date timestamp without time zone NOT NULL,
  ndc character varying(11) NOT NULL,
  dispense_sup numeric(15,8),
  dispense_amt numeric(15,8),
  raw_ndc character varying(50),
  CONSTRAINT pmndispensing_pkey PRIMARY KEY (dispensingid),
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT prescribingid FOREIGN KEY (prescribingid)
      REFERENCES popmednet.pmnprescribing (prescribingid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-- DROP INDEX popmednet.idx_dispensing_index;
CREATE INDEX idx_dispensing_index
  ON popmednet.pmndispensing
  USING btree
  (ndc COLLATE pg_catalog."default");


-------------------------------- VITALS --------------------------------

-- DROP TABLE popmednet.pmnvital;
CREATE TABLE popmednet.pmnvital
(
  vitalid bigserial NOT NULL,
  patid character varying(50),
  encounterid character varying(50),
  measure_date timestamp without time zone,
  measure_time character varying(5),
  vital_source character varying(2),
  ht numeric(15,8),
  wt numeric(15,8),
  diastolic numeric(15,8),
  systolic numeric(15,8),
  original_bmi numeric(15,8),
  bp_position character varying(2),
  smoking character varying(2),
  tobacco character varying(2),
  tobacco_type character varying(2),
  raw_vital_source character varying(50),
  raw_ht character varying(50),
  raw_wt character varying(50),
  raw_diastolic character varying(50),
  raw_systolic character varying(50),
  raw_bp_position character varying(50),
  raw_smoking character varying(50),
  raw_tobacco character varying(50),
  raw_tobacco_type character varying(50),
  CONSTRAINT encounterid FOREIGN KEY (encounterid)
      REFERENCES popmednet.pmnencounter (encounterid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-------------------------------- LAB_RESULTS_CM --------------------------------


-- DROP TABLE popmednet.pmn_labnormal;
CREATE TABLE popmednet.pmn_labnormal
(
  lab_name character varying(150),
  norm_range_low character varying(10),
  norm_modifier_low character varying(2),
  norm_range_high character varying(10),
  norm_modifier_high character varying(2)
)
WITH (
  OIDS=FALSE
);



-- DROP TABLE popmednet.pmnlab_result_cm;
CREATE TABLE popmednet.pmnlab_result_cm
(
  lab_result_cm_id bigint NOT NULL DEFAULT nextval('popmednet.pmnlabresults_cm_lab_result_cm_id_seq'::regclass),
  patid character varying(50) NOT NULL,
  encounterid character varying(50),
  lab_name character varying(10),
  specimen_source character varying(10),
  lab_loinc character varying(10),
  priority character varying(2),
  result_loc character varying(2),
  lab_px character varying(11),
  lab_px_type character varying(2),
  lab_order_date timestamp without time zone,
  specimen_date timestamp without time zone,
  specimen_time character varying(5),
  result_date timestamp without time zone NOT NULL,
  result_time character varying(5),
  result_qual character varying(12),
  result_num numeric(15,8),
  result_modifier character varying(2),
  result_unit character varying(11),
  norm_range_low character varying(10),
  norm_modifier_low character varying(2),
  norm_range_high character varying(10),
  norm_modifier_high character varying(2),
  abn_ind character varying(2),
  raw_lab_name character varying(50),
  raw_lab_code character varying(50),
  raw_panel character varying(50),
  raw_result character varying(50),
  raw_unit character varying(50),
  raw_order_dept character varying(50),
  raw_facility_code character varying(50),
  CONSTRAINT pmnlabresults_cm_pkey PRIMARY KEY (lab_result_cm_id),
  CONSTRAINT encounterid FOREIGN KEY (encounterid)
      REFERENCES popmednet.pmnencounter (encounterid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-- DROP INDEX popmednet.idx_labresults_index;
CREATE INDEX idx_labresults_index
  ON popmednet.pmnlab_result_cm
  USING btree
  (lab_loinc COLLATE pg_catalog."default");

  
-------------------------------- HARVEST --------------------------------


-- DROP TABLE popmednet.pmnharvest;
CREATE TABLE popmednet.pmnharvest
(
  networkid character varying(10) NOT NULL,
  network_name character varying(20),
  datamartid character varying(10) NOT NULL,
  datamart_name character varying(20),
  datamart_platform character varying(2),
  cdm_version numeric(15,8),
  datamart_claims character varying(2),
  datamart_ehr character varying(2),
  birth_date_mgmt character varying(2),
  enr_start_date_mgmt character varying(2),
  enr_end_date_mgmt character varying(2),
  admit_date_mgmt character varying(2),
  discharge_date_mgmt character varying(2),
  px_date_mgmt character varying(2),
  rx_order_date_mgmt character varying(2),
  rx_start_date_mgmt character varying(2),
  rx_end_date_mgmt character varying(2),
  dispense_date_mgmt character varying(2),
  lab_order_date_mgmt character varying(2),
  specimen_date_mgmt character varying(2),
  result_date_mgmt character varying(2),
  measure_date_mgmt character varying(2),
  onset_date_mgmt character varying(2),
  report_date_mgmt character varying(2),
  resolve_date_mgmt character varying(2),
  pro_date_mgmt character varying(2),
  refresh_demographic_date timestamp without time zone,
  refresh_enrollment_date timestamp without time zone,
  refresh_encounter_date timestamp without time zone,
  refresh_diagnosis_date timestamp without time zone,
  refresh_procedures_date timestamp without time zone,
  refresh_vital_date timestamp without time zone,
  refresh_dispensing_date timestamp without time zone,
  refresh_lab_result_cm_date timestamp without time zone,
  refresh_condition_date timestamp without time zone,
  refresh_pro_cm_date timestamp without time zone,
  refresh_prescribing_date timestamp without time zone,
  refresh_pcornet_trial_date timestamp without time zone,
  refresh_death_date timestamp without time zone,
  refresh_death_cause_date timestamp without time zone,
  CONSTRAINT pmnharvest_pkey PRIMARY KEY (networkid, datamartid)
)
WITH (
  OIDS=FALSE
);



-------------------------------- PRO_CM --------------------------------

-- DROP TABLE popmednet.pmnpro_cm;
CREATE TABLE popmednet.pmnpro_cm
(
  pro_cm_id bigserial NOT NULL,
  patid character varying(50) NOT NULL,
  encounterid character varying(50),
  pro_item character varying(20) NOT NULL,
  pro_loinc character varying(10),
  pro_date timestamp without time zone NOT NULL,
  pro_time character varying(5),
  pro_response numeric(15,8) NOT NULL,
  pro_method character varying(2),
  pro_mode character varying(2),
  pro_cat character varying(2),
  raw_pro_code character varying(50),
  raw_pro_response character varying(50),
  CONSTRAINT pmnpro_cm_pkey PRIMARY KEY (pro_cm_id),
  CONSTRAINT encounterid FOREIGN KEY (encounterid)
      REFERENCES popmednet.pmnencounter (encounterid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-------------------------------- PCORNET_TRIAL --------------------------------

-- DROP TABLE popmednet.pmnpcornet_trial;
CREATE TABLE popmednet.pmnpcornet_trial
(
  patid character varying(50) NOT NULL,
  trialid character varying(20) NOT NULL,
  participantid character varying(50) NOT NULL,
  trial_siteid character varying(50),
  trial_enroll_date timestamp without time zone,
  trial_end_date timestamp without time zone,
  trial_withdraw_date timestamp without time zone,
  trial_invite_code character varying(20),
  CONSTRAINT pmnpcornet_trial_pkey PRIMARY KEY (patid, trialid, participantid),
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-------------------------------- CONDITION --------------------------------

-- DROP TABLE popmednet.pmncondition;
CREATE TABLE popmednet.pmncondition
(
  conditionid bigserial NOT NULL,
  patid character varying(50) NOT NULL,
  encounterid character varying(50),
  report_date timestamp without time zone,
  resolve_date timestamp without time zone,
  onset_date timestamp without time zone,
  condition_status character varying(2),
  condition character varying(18) NOT NULL,
  condition_type character varying(2) NOT NULL,
  condition_source character varying(2) NOT NULL,
  raw_condition_status character varying(2),
  raw_condition character varying(18),
  raw_condition_type character varying(2),
  raw_condition_source character varying(2),
  CONSTRAINT pmncondition_pkey PRIMARY KEY (conditionid),
  CONSTRAINT encounterid FOREIGN KEY (encounterid)
      REFERENCES popmednet.pmnencounter (encounterid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-- DROP INDEX popmednet.idx_condition_index;
CREATE INDEX idx_condition_index
  ON popmednet.pmncondition
  USING btree
  (condition COLLATE pg_catalog."default");


-------------------------------- DEATH --------------------------------

-- DROP TABLE popmednet.pmndeath;
CREATE TABLE popmednet.pmndeath
(
  patid character varying(50) NOT NULL,
  death_date timestamp without time zone NOT NULL,
  death_date_impute character varying(2),
  death_source character varying(2) NOT NULL,
  death_match_confidence character varying(2),
  CONSTRAINT pmndeath_pkey PRIMARY KEY (patid, death_date, death_source),
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-------------------------------- DEATH_CONDITION --------------------------------


-- DROP TABLE popmednet.pmndeath_condition;
CREATE TABLE popmednet.pmndeath_condition
(
  patid character varying(50) NOT NULL,
  death_cause character varying(8) NOT NULL,
  death_cause_code character varying(2) NOT NULL,
  death_cause_type character varying(2) NOT NULL,
  death_cause_source character varying(2) NOT NULL,
  death_cause_confidence character varying(2),
  CONSTRAINT pmndeath_cause_pkey PRIMARY KEY (patid, death_cause, death_cause_code, death_cause_type, death_cause_source),
  CONSTRAINT patid FOREIGN KEY (patid)
      REFERENCES popmednet.pmndemographic (patid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-------------------------------- PCORNET_CODELIST --------------------------------


-- DROP TABLE popmednet.pcornet_codelist;
CREATE TABLE popmednet.pcornet_codelist
(
  codetype character varying(20),
  code character varying(20),
  pcori_basecode character varying(50),
  pcori_shortcode character varying(3)
)
WITH (
  OIDS=FALSE
);


-- DROP INDEX popmednet.idx_pcornet_codelist_basecode;
CREATE INDEX idx_pcornet_codelist_basecode
  ON popmednet.pcornet_codelist
  USING btree
  (pcori_basecode COLLATE pg_catalog."default");


-- DROP INDEX popmednet.idx_pcornet_codelist_code;
CREATE INDEX idx_pcornet_codelist_code
  ON popmednet.pcornet_codelist
  USING btree
  (code COLLATE pg_catalog."default");


-- DROP INDEX popmednet.idx_pcornet_codelist_codetype;
CREATE INDEX idx_pcornet_codelist_codetype
  ON popmednet.pcornet_codelist
  USING btree
  (codetype COLLATE pg_catalog."default");


-- DROP INDEX popmednet.idx_pcornet_codelist_shortcode;
CREATE INDEX idx_pcornet_codelist_shortcode
  ON popmednet.pcornet_codelist
  USING btree
  (pcori_shortcode COLLATE pg_catalog."default");


-------------------------------- I2PREPORT --------------------------------

-- DROP TABLE popmednet.i2preport;
CREATE TABLE popmednet.i2preport
(
  runid numeric,
  rundate timestamp without time zone,
  concept character varying(20),
  sourceval numeric,
  destval numeric,
  diff numeric,
  sourcedistinct numeric,
  destdistinct numeric,
  diffdistinct numeric
)
WITH (
  OIDS=FALSE
);


-- End of CREATE THE TABLES
-------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------
-- Create synonyms for the pmn tables for use by the MENU DRIVEN QUERY TOOL 
-- PostgreSQL does not support creation of synonyms. This script will create views instead, to fulfill this requirement. 
-- NOTE: PCORNet MDQ Tool generates SQL containing "uppercase_table_names" and "uppercase_column_names". Since PostgreSQL is case-sensitive with double quotes, this requirement has been incorporated in view definitions below.
-- Please edit this for your institution/datamart, as appropriate.


----------------------------------------------------------------------------------------------------------------------  
-- Assumption: The following views are created under popmednet schema of popmednet database
----------------------------------------------------------------------------------------------------------------------

-------------------------------- DEMOGRAPHICS --------------------------------

-- DROP VIEW popmednet."DEMOGRAPHIC";
CREATE OR REPLACE VIEW popmednet."DEMOGRAPHIC" AS 
 SELECT pmndemographic.patid AS "PATID",
    pmndemographic.birth_date AS "BIRTH_DATE",
    pmndemographic.birth_time AS "BIRTH_TIME",
    pmndemographic.sex AS "SEX",
    pmndemographic.hispanic AS "HISPANIC",
    pmndemographic.biobank_flag AS "BIOBANK_FLAG",
    pmndemographic.race AS "RACE",
    pmndemographic.raw_sex AS "RAW_SEX",
    pmndemographic.raw_hispanic AS "RAW_HISPANIC",
    pmndemographic.raw_race AS "RAW_RACE",
	pmndemographic.sexual_orientation AS "SEXUAL_ORIENTATION",
	pmndemographic.gender_identity AS "GENDER_IDENTITY",
	pmndemographic.raw_sexual_orientation AS "RAW_SEXUAL_ORIENTATION",
	pmndemographic.raw_gender_identity AS "RAW_GENDER_IDENTITY"
   FROM popmednet.pmndemographic;
   
-------------------------------- ENCOUNTER --------------------------------
   
-- DROP VIEW popmednet."ENCOUNTER";
CREATE OR REPLACE VIEW popmednet."ENCOUNTER" AS 
 SELECT pmnencounter.patid AS "PATID",
    pmnencounter.encounterid AS "ENCOUNTERID",
    pmnencounter.admit_date AS "ADMIT_DATE",
    pmnencounter.admit_time AS "ADMIT_TIME",
    pmnencounter.discharge_date AS "DISCHARGE_DATE",
    pmnencounter.discharge_time AS "DISCHARGE_TIME",
    pmnencounter.providerid AS "PROVIDERID",
    pmnencounter.facility_location AS "FACILITY_LOCATION",
    pmnencounter.enc_type AS "ENC_TYPE",
    pmnencounter.facilityid AS "FACILITYID",
    pmnencounter.discharge_disposition AS "DISCHARGE_DISPOSITION",
    pmnencounter.discharge_status AS "DISCHARGE_STATUS",
    pmnencounter.drg AS "DRG",
    pmnencounter.drg_type AS "DRG_TYPE",
    pmnencounter.admitting_source AS "ADMITTING_SOURCE",
    pmnencounter.raw_siteid AS "RAW_SITEID",
    pmnencounter.raw_enc_type AS "RAW_ENC_TYPE",
    pmnencounter.raw_discharge_disposition AS "RAW_DISCHARGE_DISPOSITION",
    pmnencounter.raw_discharge_status AS "RAW_DISCHARGE_STATUS",
    pmnencounter.raw_drg_type AS "RAW_DRG_TYPE",
    pmnencounter.raw_admitting_source AS "RAW_ADMITTING_SOURCE"
   FROM popmednet.pmnencounter;

-------------------------------- ENROLLMENT --------------------------------

-- DROP VIEW popmednet."ENROLLMENT";
CREATE OR REPLACE VIEW popmednet."ENROLLMENT" AS 
 SELECT pmnenrollment.patid AS "PATID",
    pmnenrollment.enr_start_date AS "ENR_START_DATE",
    pmnenrollment.enr_end_date AS "ENR_END_DATE",
    pmnenrollment.chart AS "CHART",
    pmnenrollment.enr_basis AS "ENR_BASIS",
    pmnenrollment.raw_chart AS "RAW_CHART",
    pmnenrollment.raw_basis AS "RAW_BASIS"
   FROM popmednet.pmnenrollment;
   

-------------------------------- DIAGNOSIS --------------------------------

-- DROP VIEW popmednet."DIAGNOSIS";
CREATE OR REPLACE VIEW popmednet."DIAGNOSIS" AS 
 SELECT pmndiagnosis.diagnosisid AS "DIAGNOSISID",
    pmndiagnosis.patid AS "PATID",
    pmndiagnosis.encounterid AS "ENCOUNTERID",
    pmndiagnosis.enc_type AS "ENC_TYPE",
    pmndiagnosis.admit_date AS "ADMIT_DATE",
    pmndiagnosis.providerid AS "PROVIDERID",
    pmndiagnosis.dx AS "DX",
    pmndiagnosis.dx_type AS "DX_TYPE",
    pmndiagnosis.dx_source AS "DX_SOURCE",
    pmndiagnosis.pdx AS "PDX",
    pmndiagnosis.raw_dx AS "RAW_DX",
    pmndiagnosis.raw_dx_type AS "RAW_DX_TYPE",
    pmndiagnosis.raw_dx_source AS "RAW_DX_SOURCE",
    pmndiagnosis.raw_origdx AS "RAW_ORIGDX",
    pmndiagnosis.raw_pdx AS "RAW_PDX",
	pmndiagnosis.dx_origin AS "DX_ORIGIN"
   FROM popmednet.pmndiagnosis;   


-------------------------------- PROCEDURES --------------------------------

-- DROP VIEW popmednet."PROCEDURES";
CREATE OR REPLACE VIEW popmednet."PROCEDURES" AS 
 SELECT pmnprocedures.proceduresid AS "PROCEDURESID",
    pmnprocedures.patid AS "PATID",
    pmnprocedures.encounterid AS "ENCOUNTERID",
    pmnprocedures.enc_type AS "ENC_TYPE",
    pmnprocedures.admit_date AS "ADMIT_DATE",
    pmnprocedures.providerid AS "PROVIDERID",
    pmnprocedures.px_date AS "PX_DATE",
    pmnprocedures.px AS "PX",
    pmnprocedures.px_type AS "PX_TYPE",
    pmnprocedures.px_source AS "PX_SOURCE",
    pmnprocedures.raw_px AS "RAW_PX",
    pmnprocedures.raw_px_type AS "RAW_PX_TYPE"
   FROM popmednet.pmnprocedures;


-------------------------------- PRESCRIBING --------------------------------

-- DROP VIEW popmednet."PRESCRIBING";
CREATE OR REPLACE VIEW popmednet."PRESCRIBING" AS 
 SELECT pmnprescribing.prescribingid AS "PRESCRIBINGID",
    pmnprescribing.patid AS "PATID",
    pmnprescribing.encounterid AS "ENCOUNTERID",
    pmnprescribing.rx_providerid AS "RX_PROVIDERID",
    pmnprescribing.rx_order_date AS "RX_ORDER_DATE",
    pmnprescribing.rx_order_time AS "RX_ORDER_TIME",
    pmnprescribing.rx_start_date AS "RX_START_DATE",
    pmnprescribing.rx_end_date AS "RX_END_DATE",
    pmnprescribing.rx_quantity AS "RX_QUANTITY",
    pmnprescribing.rx_refills AS "RX_REFILLS",
    pmnprescribing.rx_days_supply AS "RX_DAYS_SUPPLY",
    pmnprescribing.rx_frequency AS "RX_FREQUENCY",
    pmnprescribing.rx_basis AS "RX_BASIS",
    pmnprescribing.rxnorm_cui AS "RXNORM_CUI",
    pmnprescribing.raw_rx_med_name AS "RAW_RX_MED_NAME",
    pmnprescribing.raw_rx_frequency AS "RAW_RX_FREQUENCY",
    pmnprescribing.raw_rxnorm_cui AS "RAW_RXNORM_CUI",
	pmnprescribing.rx_quantity_unit AS "RX_QUANTITY_UNIT",
	pmnprescribing.raw_rx_quantity AS "RAW_RX_QUANTITY",
	pmnprescribing.raw_rx_ndc AS "RAW_RX_NDC"
   FROM popmednet.pmnprescribing;   
   

-------------------------------- DISPENSING --------------------------------
   
-- DROP VIEW popmednet."DISPENSING";
CREATE OR REPLACE VIEW popmednet."DISPENSING" AS 
 SELECT pmndispensing.dispensingid AS "DISPENSINGID",
    pmndispensing.patid AS "PATID",
    pmndispensing.prescribingid AS "PRESCRIBINGID",
    pmndispensing.dispense_date AS "DISPENSE_DATE",
    pmndispensing.ndc AS "NDC",
    pmndispensing.dispense_sup AS "DISPENSE_SUP",
    pmndispensing.dispense_amt AS "DISPENSE_AMT",
    pmndispensing.raw_ndc AS "RAW_NDC"
   FROM popmednet.pmndispensing;   


-------------------------------- VITAL --------------------------------
   
-- DROP VIEW popmednet."VITAL";
CREATE OR REPLACE VIEW popmednet."VITAL" AS 
 SELECT pmnvital.vitalid AS "VITALID",
    pmnvital.patid AS "PATID",
    pmnvital.encounterid AS "ENCOUNTERID",
    pmnvital.measure_date AS "MEASURE_DATE",
    pmnvital.measure_time AS "MEASURE_TIME",
    pmnvital.vital_source AS "VITAL_SOURCE",
    pmnvital.ht AS "HT",
    pmnvital.wt AS "WT",
    pmnvital.diastolic AS "DIASTOLIC",
    pmnvital.systolic AS "SYSTOLIC",
    pmnvital.original_bmi AS "ORIGINAL_BMI",
    pmnvital.bp_position AS "BP_POSITION",
    pmnvital.smoking AS "SMOKING",
    pmnvital.tobacco AS "TOBACCO",
    pmnvital.tobacco_type AS "TOBACCO_TYPE",
    pmnvital.raw_vital_source AS "RAW_VITAL_SOURCE",
    pmnvital.raw_ht AS "RAW_HT",
    pmnvital.raw_wt AS "RAW_WT",
    pmnvital.raw_diastolic AS "RAW_DIASTOLIC",
    pmnvital.raw_systolic AS "RAW_SYSTOLIC",
    pmnvital.raw_bp_position AS "RAW_BP_POSITION",
    pmnvital.raw_smoking AS "RAW_SMOKING",
    pmnvital.raw_tobacco AS "RAW_TOBACCO",
    pmnvital.raw_tobacco_type AS "RAW_TOBACCO_TYPE"
   FROM popmednet.pmnvital;   
   
   
-------------------------------- LAB_RESULT_CM --------------------------------
   
-- DROP VIEW popmednet."LAB_RESULT_CM";
CREATE OR REPLACE VIEW popmednet."LAB_RESULT_CM" AS 
 SELECT pmnlab_result_cm.lab_result_cm_id AS "LAB_RESULT_CM_ID",
    pmnlab_result_cm.patid AS "PATID",
    pmnlab_result_cm.encounterid AS "ENCOUNTERID",
    pmnlab_result_cm.lab_name AS "LAB_NAME",
    pmnlab_result_cm.specimen_source AS "SPECIMEN_SOURCE",
    pmnlab_result_cm.lab_loinc AS "LAB_LOINC",
    pmnlab_result_cm.priority AS "PRIORITY",
    pmnlab_result_cm.result_loc AS "RESULT_LOC",
    pmnlab_result_cm.lab_px AS "LAB_PX",
    pmnlab_result_cm.lab_px_type AS "LAB_PX_TYPE",
    pmnlab_result_cm.lab_order_date AS "LAB_ORDER_DATE",
    pmnlab_result_cm.specimen_date AS "SPECIMEN_DATE",
    pmnlab_result_cm.specimen_time AS "SPECIMEN_TIME",
    pmnlab_result_cm.result_date AS "RESULT_DATE",
    pmnlab_result_cm.result_time AS "RESULT_TIME",
    pmnlab_result_cm.result_qual AS "RESULT_QUAL",
    pmnlab_result_cm.result_num AS "RESULT_NUM",
    pmnlab_result_cm.result_modifier AS "RESULT_MODIFIER",
    pmnlab_result_cm.result_unit AS "RESULT_UNIT",
    pmnlab_result_cm.norm_range_low AS "NORM_RANGE_LOW",
    pmnlab_result_cm.norm_modifier_low AS "NORM_MODIFIER_LOW",
    pmnlab_result_cm.norm_range_high AS "NORM_RANGE_HIGH",
    pmnlab_result_cm.norm_modifier_high AS "NORM_MODIFIER_HIGH",
    pmnlab_result_cm.abn_ind AS "ABN_IND",
    pmnlab_result_cm.raw_lab_name AS "RAW_LAB_NAME",
    pmnlab_result_cm.raw_lab_code AS "RAW_LAB_CODE",
    pmnlab_result_cm.raw_panel AS "RAW_PANEL",
    pmnlab_result_cm.raw_result AS "RAW_RESULT",
    pmnlab_result_cm.raw_unit AS "RAW_UNIT",
    pmnlab_result_cm.raw_order_dept AS "RAW_ORDER_DEPT",
    pmnlab_result_cm.raw_facility_code AS "RAW_FACILITY_CODE"
   FROM popmednet.pmnlab_result_cm;   


-------------------------------- HARVEST --------------------------------
   
-- DROP VIEW popmednet."HARVEST";
CREATE OR REPLACE VIEW popmednet."HARVEST" AS 
 SELECT pmnharvest.networkid AS "NETWORKID",
    pmnharvest.network_name AS "NETWORK_NAME",
    pmnharvest.datamartid AS "DATAMARTID",
    pmnharvest.datamart_name AS "DATAMART_NAME",
    pmnharvest.datamart_platform AS "DATAMART_PLATFORM",
    pmnharvest.cdm_version AS "CDM_VERSION",
    pmnharvest.datamart_claims AS "DATAMART_CLAIMS",
    pmnharvest.datamart_ehr AS "DATAMART_EHR",
    pmnharvest.birth_date_mgmt AS "BIRTH_DATE_MGMT",
    pmnharvest.enr_start_date_mgmt AS "ENR_START_DATE_MGMT",
    pmnharvest.enr_end_date_mgmt AS "ENR_END_DATE_MGMT",
    pmnharvest.admit_date_mgmt AS "ADMIT_DATE_MGMT",
    pmnharvest.discharge_date_mgmt AS "DISCHARGE_DATE_MGMT",
    pmnharvest.px_date_mgmt AS "PX_DATE_MGMT",
    pmnharvest.rx_order_date_mgmt AS "RX_ORDER_DATE_MGMT",
    pmnharvest.rx_start_date_mgmt AS "RX_START_DATE_MGMT",
    pmnharvest.rx_end_date_mgmt AS "RX_END_DATE_MGMT",
    pmnharvest.dispense_date_mgmt AS "DISPENSE_DATE_MGMT",
    pmnharvest.lab_order_date_mgmt AS "LAB_ORDER_DATE_MGMT",
    pmnharvest.specimen_date_mgmt AS "SPECIMEN_DATE_MGMT",
    pmnharvest.result_date_mgmt AS "RESULT_DATE_MGMT",
    pmnharvest.measure_date_mgmt AS "MEASURE_DATE_MGMT",
    pmnharvest.onset_date_mgmt AS "ONSET_DATE_MGMT",
    pmnharvest.report_date_mgmt AS "REPORT_DATE_MGMT",
    pmnharvest.resolve_date_mgmt AS "RESOLVE_DATE_MGMT",
    pmnharvest.pro_date_mgmt AS "PRO_DATE_MGMT",
    pmnharvest.refresh_demographic_date AS "REFRESH_DEMOGRAPHIC_DATE",
    pmnharvest.refresh_enrollment_date AS "REFRESH_ENROLLMENT_DATE",
    pmnharvest.refresh_encounter_date AS "REFRESH_ENCOUNTER_DATE",
    pmnharvest.refresh_diagnosis_date AS "REFRESH_DIAGNOSIS_DATE",
    pmnharvest.refresh_procedures_date AS "REFRESH_PROCEDURES_DATE",
    pmnharvest.refresh_vital_date AS "REFRESH_VITAL_DATE",
    pmnharvest.refresh_dispensing_date AS "REFRESH_DISPENSING_DATE",
    pmnharvest.refresh_lab_result_cm_date AS "REFRESH_LAB_RESULT_CM_DATE",
    pmnharvest.refresh_condition_date AS "REFRESH_CONDITION_DATE",
    pmnharvest.refresh_pro_cm_date AS "REFRESH_PRO_CM_DATE",
    pmnharvest.refresh_prescribing_date AS "REFRESH_PRESCRIBING_DATE",
    pmnharvest.refresh_pcornet_trial_date AS "REFRESH_PCORNET_TRIAL_DATE",
    pmnharvest.refresh_death_date AS "REFRESH_DEATH_DATE",
    pmnharvest.refresh_death_cause_date AS "REFRESH_DEATH_CAUSE_DATE"
   FROM popmednet.pmnharvest;

-------------------------------- PRO_CM --------------------------------

-- DROP VIEW popmednet."PRO_CM";
CREATE OR REPLACE VIEW popmednet."PRO_CM" AS 
 SELECT pmnpro_cm.pro_cm_id AS "PRO_CM_ID",
    pmnpro_cm.patid AS "PATID",
    pmnpro_cm.encounterid AS "ENCOUNTERID",
    pmnpro_cm.pro_item AS "PRO_ITEM",
    pmnpro_cm.pro_loinc AS "PRO_LOINC",
    pmnpro_cm.pro_date AS "PRO_DATE",
    pmnpro_cm.pro_time AS "PRO_TIME",
    pmnpro_cm.pro_response AS "PRO_RESPONSE",
    pmnpro_cm.pro_method AS "PRO_METHOD",
    pmnpro_cm.pro_mode AS "PRO_MODE",
    pmnpro_cm.pro_cat AS "PRO_CAT",
    pmnpro_cm.raw_pro_code AS "RAW_PRO_CODE",
    pmnpro_cm.raw_pro_response AS "RAW_PRO_RESPONSE"
   FROM popmednet.pmnpro_cm;   
   

-------------------------------- PCORNET_TRIAL --------------------------------
   
-- DROP VIEW popmednet."PCORNET_TRIAL";
CREATE OR REPLACE VIEW popmednet."PCORNET_TRIAL" AS 
 SELECT pmnpcornet_trial.patid AS "PATID",
    pmnpcornet_trial.trialid AS "TRIALID",
    pmnpcornet_trial.participantid AS "PARTICIPANTID",
    pmnpcornet_trial.trial_siteid AS "TRIAL_SITEID",
    pmnpcornet_trial.trial_enroll_date AS "TRIAL_ENROLL_DATE",
    pmnpcornet_trial.trial_end_date AS "TRIAL_END_DATE",
    pmnpcornet_trial.trial_withdraw_date AS "TRIAL_WITHDRAW_DATE",
    pmnpcornet_trial.trial_invite_code AS "TRIAL_INVITE_CODE"
   FROM popmednet.pmnpcornet_trial;
   

-------------------------------- CONDITION --------------------------------
   
-- DROP VIEW popmednet."CONDITION";
CREATE OR REPLACE VIEW popmednet."CONDITION" AS 
 SELECT pmncondition.conditionid AS "CONDITIONID",
    pmncondition.patid AS "PATID",
    pmncondition.encounterid AS "ENCOUNTERID",
    pmncondition.report_date AS "REPORT_DATE",
    pmncondition.resolve_date AS "RESOLVE_DATE",
    pmncondition.onset_date AS "ONSET_DATE",
    pmncondition.condition_status AS "CONDITION_STATUS",
    pmncondition.condition AS "CONDITION",
    pmncondition.condition_type AS "CONDITION_TYPE",
    pmncondition.condition_source AS "CONDITION_SOURCE",
    pmncondition.raw_condition_status AS "RAW_CONDITION_STATUS",
    pmncondition.raw_condition AS "RAW_CONDITION",
    pmncondition.raw_condition_type AS "RAW_CONDITION_TYPE",
    pmncondition.raw_condition_source AS "RAW_CONDITION_SOURCE"
   FROM popmednet.pmncondition;   
   

-------------------------------- DEATH --------------------------------
   
-- DROP VIEW popmednet."DEATH";
CREATE OR REPLACE VIEW popmednet."DEATH" AS 
 SELECT pmndeath.patid AS "PATID",
    pmndeath.death_date AS "DEATH_DATE",
    pmndeath.death_date_impute AS "DEATH_DATE_IMPUTE",
    pmndeath.death_source AS "DEATH_SOURCE",
    pmndeath.death_match_confidence AS "DEATH_MATCH_CONFIDENCE"
   FROM popmednet.pmndeath;   
   
-------------------------------- DEATH CONDITION --------------------------------
   
-- DROP VIEW popmednet."DEATH_CONDITION";
CREATE OR REPLACE VIEW popmednet."DEATH_CONDITION" AS 
 SELECT pmndeath_condition.patid AS "PATID",
    pmndeath_condition.death_cause AS "DEATH_CAUSE",
    pmndeath_condition.death_cause_code AS "DEATH_CAUSE_CODE",
    pmndeath_condition.death_cause_type AS "DEATH_CAUSE_TYPE",
    pmndeath_condition.death_cause_source AS "DEATH_CAUSE_SOURCE",
    pmndeath_condition.death_cause_confidence AS "DEATH_CAUSE_CONFIDENCE"
   FROM popmednet.pmndeath_condition;
   
   
-- End of Create synonyms for the pmn tables for use by the MENU DRIVEN QUERY TOOL 
----------------------------------------------------------------------------------------------------------------------
   
   
   
   
   
----------------------------------------------------------------------------------------------------------------------
-- Prep-to-transform code
-- Note: PostgreSQL version for the transform utilizes additional function, views and tables to enhance performance. 
-- These may not be present in the MSSQL or ORACLE versions of the script. 
-- Please edit this for your institution/datamart, as appropriate.

----------------------------------------------------------------------------------------------------------------------
-- Assumption: The following functions will be created under popmednet schema of popmednet database
----------------------------------------------------------------------------------------------------------------------
   
-- DROP FUNCTION popmednet.pcornet_parsecode(character varying, character varying, character varying, character varying);
CREATE OR REPLACE FUNCTION popmednet.pcornet_parsecode(
    codetype character varying,
    codestring character varying,
    basecode character varying,
    shortcode character varying)
  RETURNS void AS
$BODY$
declare
	onecode varchar :='';
	remaining varchar := codestring;
	nextcomma integer := 0;
begin
	while length(remaining) > 0 loop
		nextcomma := position(',' in remaining);
		
		if nextcomma = 0 then
			nextcomma := length(remaining);
		end if; 
		
		onecode = translate(left(remaining,nextcomma),''',','');
		remaining := substring(remaining from nextcomma+1);
		insert into popmednet.pcornet_codelist (codetype, code, pcori_basecode, pcori_shortcode) values (codetype,onecode, basecode, shortcode);
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;   
   

-- DROP FUNCTION popmednet.pcornet_popcodelist();
CREATE OR REPLACE FUNCTION popmednet.pcornet_popcodelist()
  RETURNS void AS
$BODY$
DECLARE 
	r RECORD;
BEGIN
	FOR r IN 
		SELECT case 
					when c_fullname like '\\PCORI\\DEMOGRAPHIC\\RACE\\%' then 'RACE'
					when c_fullname like '\\PCORI\\DEMOGRAPHIC\\SEX\\%' then 'SEX'
					when c_fullname like '\\PCORI\\DEMOGRAPHIC\\HISPANIC\\Y%' then 'HISPANIC'
				end as codetype
			 , c_dimcode 
			 , pcori_basecode 
			 , pcori_basecode as pcori_shortcode
		FROM fdw_i2b2metadata.pcornet_demo 
		where (c_fullname like '\\PCORI\\DEMOGRAPHIC\\RACE\\%'
		   OR c_fullname like '\\PCORI\\DEMOGRAPHIC\\SEX\\%'
		   OR c_fullname like '\\PCORI\\DEMOGRAPHIC\\HISPANIC\\Y%')
		  and c_dimcode !~~ '\\PCORI\\DEMOGRAPHIC\\%' 
		UNION ALL 
		SELECT case 
                    when c_fullname like '\\PCORI\\ENCOUNTER\\DISCHARGE_STATUS\\%' then 'DSTATUS'
					when c_fullname like '\\PCORI\\ENCOUNTER\\ADMITTING_SOURCE\\%' then 'ADMIT'
					when c_fullname like '\\PCORI\\ENCOUNTER\\DISCHARGE_DISPOSITION\\%' then 'DDISP'
					when c_fullname like '\\PCORI\\ENCOUNTER\\ENC_TYPE\\%' then 'ENCTYPE'
				end as codetype
			 , c_dimcode 
			 , pcori_basecode
			 , substring(pcori_basecode,1+position(':' in pcori_basecode)) as pcori_shortcode
			 FROM fdw_i2b2metadata.pcornet_enc
		where (c_fullname like '\\PCORI\\ENCOUNTER\\DISCHARGE_STATUS\\%'
		   OR c_fullname like '\\PCORI\\ENCOUNTER\\ADMITTING_SOURCE\\%'
		   OR c_fullname like '\\PCORI\\ENCOUNTER\\DISCHARGE_DISPOSITION\\%'
		   OR c_fullname like '\\PCORI\\ENCOUNTER\\ENC_TYPE\\%' )
		  and (c_dimcode !~~ '\\PCORI\\ENCOUNTER\\%' )
	LOOP
		perform popmednet.pcornet_parsecode(r.codetype, r.c_dimcode, r.pcori_basecode, r.pcori_shortcode);
	END LOOP;
END;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


-- DROP FUNCTION popmednet.getdatamartid();
CREATE OR REPLACE FUNCTION popmednet.getdatamartid()
  RETURNS character varying AS
$BODY$
BEGIN
    RETURN 'C1WU'; -- Change this to match your datamart id
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


-- DROP FUNCTION popmednet.getdatamartname();
CREATE OR REPLACE FUNCTION popmednet.getdatamartname()
  RETURNS character varying AS
$BODY$
BEGIN 
    RETURN 'Wash U BJC'; -- Change this to match your datamart name
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  
  
 
  
-- DROP FUNCTION popmednet.getdatamartplatform();
CREATE OR REPLACE FUNCTION popmednet.getdatamartplatform()
  RETURNS character varying AS
$BODY$
BEGIN 
    RETURN '03'; -- 01 is MSSQL, 02 is Oracle, 03 is PostgreSQL;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  
  

-- DROP FUNCTION popmednet.units_cm_to_in(double precision);
CREATE OR REPLACE FUNCTION popmednet.units_cm_to_in(v_original_value double precision)
  RETURNS double precision AS
$BODY$
    select v_original_value * 0.393701;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


-- DROP FUNCTION popmednet.units_in_to_cm(double precision);
CREATE OR REPLACE FUNCTION popmednet.units_in_to_cm(v_original_value double precision)
  RETURNS double precision AS
$BODY$
    select v_original_value * 2.54;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;  

  
-- DROP FUNCTION popmednet.units_kg_to_lbs(double precision);
CREATE OR REPLACE FUNCTION popmednet.units_kg_to_lbs(v_original_value double precision)
  RETURNS double precision AS
$BODY$
    select v_original_value * 2.20462;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;


-- DROP FUNCTION popmednet.units_lbs_to_kg(double precision);
CREATE OR REPLACE FUNCTION popmednet.units_lbs_to_kg(v_original_value double precision)
  RETURNS double precision AS
$BODY$
    select v_original_value * 0.453592;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;  
  
  
-- DROP FUNCTION popmednet.populate_pmn_labnormal();
CREATE OR REPLACE FUNCTION popmednet.populate_pmn_labnormal()
  RETURNS void AS
$BODY$
DECLARE
BEGIN
	
	INSERT INTO popmednet.pmn_labnormal(lab_name, NORM_RANGE_LOW, NORM_MODIFIER_LOW, NORM_RANGE_HIGH, NORM_MODIFIER_HIGH)
	  VALUES ('LAB_NAME:LDL'	, '0'	, 'EQ'	, '165'		, 'EQ')
		,('LAB_NAME:A1C'	, '3.5'	, 'EQ'	, '6.5'		, 'EQ')
		,('LAB_NAME:CK'		, '50'	, 'EQ'	, '236'		, 'EQ')
		,('LAB_NAME:CK_MB'	, ''	, 'NI'	, ''		, 'NI')
		,('LAB_NAME:CK_MBI'	, ''	, 'NI'	, ''		, 'NI')
		,('LAB_NAME:CREATININE'	, '0'	, 'EQ'	, '1.6'		, 'EQ')
		,('LAB_NAME:CREATININE'	, '0'	, 'EQ'	, '1.6'		, 'EQ')
		,('LAB_NAME:HGB'	, '12'	, 'EQ'	, '17.5'	, 'EQ')
		,('LAB_NAME:INR'	, '0.8'	, 'EQ'	, '1.3'		, 'EQ')
		,('LAB_NAME:TROP_I'	, '0'	, 'EQ'	, '0.49'	, 'EQ')
		,('LAB_NAME:TROP_T_QL'	, ''	, 'NI'	, ''		, 'NI')
		,('LAB_NAME:TROP_T_QN'	, '0'	, 'EQ'	, '0.09'	, 'EQ');

END;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;  


----------------------------------------------------------------------------------------------------------------------  
-- WU-specific additional functions, views and tables needed for performance enhancement start here.
-- Please use/edit these for your institution/datamart, as appropriate.

----------------------------------------------------------------------------------------------------------------------  
-- Assumption: The following views will be created under popmednet schema of popmednet database
----------------------------------------------------------------------------------------------------------------------   

-- DROP FUNCTION popmednet.exeucte_sql_stmt(character varying);
CREATE OR REPLACE FUNCTION popmednet.exeucte_sql_stmt(sqlstring character varying)
  RETURNS integer AS
$BODY$
DECLARE
    rc integer:=0;
BEGIN
    execute sqlstring;
    GET CURRENT DIAGNOSTICS  rc := ROW_COUNT;
    return rc;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
-- DROP FUNCTION popmednet.execute_sql_stmt_with_chunking_by_date(text, text, integer, integer);
CREATE OR REPLACE FUNCTION popmednet.execute_sql_stmt_with_chunking_by_date(
    sqlstring text,
    table_name text,
    my_date_step integer DEFAULT 90,
    encounter_steps integer DEFAULT 1)
  RETURNS void AS
$BODY$ 
DECLARE 
	my_cur_date timestamp default now();
	my_start_date timestamp default now();
	my_stop_date timestamp default now()::timestamp+my_date_step;
	my_low_enc varchar;
	my_high_enc varchar;
	my_enc_step integer;
	my_cur_low_enc varchar;
	my_cur_high_enc varchar;
	v_constr varchar;
	rc integer := 0;
begin
    if position('[PUT_START_DATE_HERE]' IN sqlstring) = 0 
    or position('[PUT_END_DATE_HERE]' IN sqlstring) = 0 
    or position('[PUT_START_ENC_HERE]' IN sqlstring) = 0 
    or position('[PUT_END_ENC_HERE]' IN sqlstring) = 0 
    or (position('where start_date between' IN sqlstring) =0 and position('false' in sqlstring)=0)
    then
        raise exception 'Required search string missing in sqlstring: %', sqlstring;
        -- expectation of where clause in passed sqlstring query where 'fact' points to observation fact or view pointing to observation_fact and including 'start_date':        
        -- '       where start_date between ''[PUT_START_DATE_HERE]''::timestamp without time zone and ''[PUT_END_DATE_HERE]''::timestamp without time zone - interval ''1 second'''|| chr(10);
        -- '         and fact.encounter_num between ''[PUT_START_ENC_HERE]''::integer and ''[PUT_END_ENC_HERE]''::integer'|| chr(10);
        -- '         and enc.encounterid between ''[PUT_START_ENC_HERE]'' and ''[PUT_END_ENC_HERE]'''|| chr(10);
    end if; 
  	v_constr := 'insertlog'||floor(100000*random())::text;


    perform extension_data.dblink_connect(v_constr,'dbname=[replace_with_popmednet_db_name] port=[replace_with_popmednet_db_port]'); -- provider db_name and db_port information here
    perform extension_data.dblink(v_constr,'delete from popmednet.pcornetchunking_log where tablename = '''||table_name||''';');
    PERFORM extension_data.dblink(v_constr,'COMMIT;');

    
    select min(admit_date)::date, max(admit_date+1)::date into my_start_date,  my_stop_date from popmednet.pmnencounter; -- this ensures capturing all facts for patients with ovservations through the end of the last admit date
    select min(encounterid), max(encounterid) into my_low_enc, my_high_enc from popmednet.pmnencounter;

    my_enc_step := (my_high_enc::integer - my_low_enc::integer)/encounter_steps;
    my_cur_low_enc := my_low_enc;
    my_cur_high_enc := ((my_cur_low_enc::integer)+my_enc_step)::varchar;

LOOP
    my_cur_date := my_start_date;
    EXIT WHEN my_cur_low_enc > my_high_enc;
    
    raise notice 'Entering loop at % with % and % of %; between % and % of %',clock_timestamp(),my_cur_date,(my_cur_date+my_date_step),my_stop_date, my_cur_low_enc, my_cur_high_enc, my_high_enc;
    --raise notice 'Entering loop at % with % and % of %',now(),my_start_date,(my_start_date+my_date_step),my_stop_date;
	--2016-4-8 DV: added loop to query by only one date at a time
	LOOP 
        EXIT WHEN my_cur_date >= my_stop_date;

        BEGIN 
            rc = popmednet.exeucte_sql_stmt(
                replace(replace(replace(replace(sqlstring
                                               , '[PUT_START_DATE_HERE]'
                                               , to_char(my_cur_date,'YYYY-MM-DD')
                                               )
                                       , '[PUT_END_DATE_HERE]'
                                       , to_char(my_cur_date+my_date_step,'YYYY-MM-DD')
                                       )
                                , '[PUT_START_ENC_HERE]'
                                , my_cur_low_enc::varchar
                                )
                       , '[PUT_END_ENC_HERE]'
                       , my_cur_high_enc::varchar
                       )
            ); 
            
            raise notice 'Inserted % rows into % at % with % and %',rc,table_name,clock_timestamp(),my_cur_date,(my_cur_date+my_date_step);

            PERFORM extension_data.dblink(v_constr,'insert into popmednet.pcornetchunking_log (ddate,tablename) values ('''||to_char(my_cur_date,'YYYY-MM-DD')||'''::timestamp,'''||table_name||''');');
            PERFORM extension_data.dblink(v_constr,'COMMIT;');
            --insert into popmednet.pcornetchunking_log (ddate,tablename) values (my_cur_date,table_name);
            
            my_cur_date := my_cur_date + my_date_step;-- this allows for what appears to be a one day overlap, but once we convert to timestamp it is only one second.  
						       -- We will account for the one second overlap in the query above.
          
        END;  
        
	end LOOP; 

    rc = popmednet.exeucte_sql_stmt(
        REPLACE(REPlaCE(replace(replace(replace(replace(sqlstring
                                                       , '[PUT_START_DATE_HERE]'
                                                       , to_char(my_start_date,'YYYY-MM-DD')
                                                       )
                                               , '[PUT_END_DATE_HERE]'
                                               , to_char(my_cur_date,'YYYY-MM-DD')
                                               )
                                        , '[PUT_START_ENC_HERE]'
                                        , my_cur_low_enc::varchar
                                        )
                               , '[PUT_END_ENC_HERE]'
                               , my_cur_high_enc::varchar
                               )
                       , 'where start_date between'
                       , 'where start_date NOT between'
                       )
              , 'false'
              , 'true'
              )
    ); 
    raise notice 'Inserted % rows into % at % with NOT % and %',rc,table_name,clock_timestamp(),my_start_date,(my_cur_date);

    my_cur_low_enc := ((my_cur_high_enc::integer)+1)::varchar; -- we already covered inclusively the my_cur_high_enc values, so add one to prevent duplicates
    my_cur_high_enc := ((my_cur_high_enc::integer)+my_enc_step)::varchar;

END LOOP;

    PERFORM extension_data.dblink_disconnect(v_constr); 

exception when others then 
    if length(v_constr) >0 then 
        PERFORM extension_data.dblink_disconnect(v_constr); 
    end if;
    raise exception using ERRCODE = SQLSTATE, MESSAGE = sqlstate || '/' || sqlerrm;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


----------------------------------------------------------------------------------------------------------------------  
-- Assumption: The following views will be created under i2b2demodata schema of i2b2 database
----------------------------------------------------------------------------------------------------------------------

-- DROP VIEW i2b2demodata.miniloyalty_patient_facts;
CREATE OR REPLACE VIEW i2b2demodata.miniloyalty_patient_facts AS 
 WITH allowed_facts AS (
         SELECT o.patient_num,
            count(*) AS num_facts
           FROM i2b2demodata.observation_fact o
             JOIN i2b2demodata.patient_dimension p_1 ON p_1.patient_num = o.patient_num
          WHERE (o.concept_cd::text IN ( SELECT concept_dimension.concept_cd
                   FROM i2b2demodata.concept_dimension
                  WHERE concept_dimension.concept_path::text ~~ '\\PCORI%'::text)) AND o.start_date >= '2010-01-01 00:00:00'::timestamp without time zone
          GROUP BY o.patient_num 
        )
 SELECT p.patient_num,
    p.birth_date,
    NULL::double precision AS age,
    p.sex_cd,
    p.race_cd,
    COALESCE(allowed_facts.num_facts, 0::bigint) AS num_facts,
    ntile(100) OVER (PARTITION BY p.sex_cd ORDER BY (COALESCE(allowed_facts.num_facts, 0::bigint)), p.patient_num) AS percentile
   FROM i2b2demodata.patient_dimension p
     LEFT JOIN allowed_facts ON p.patient_num = allowed_facts.patient_num;
	 
	 
-- DROP VIEW i2b2demodata.vw_pmndiagnosis_loader;
CREATE OR REPLACE VIEW i2b2demodata.vw_pmndiagnosis_loader AS 
 SELECT factline.patient_num,
    factline.encounter_num,
    factline.start_date,
    factline.provider_id,
    diag.pcori_basecode AS diag_pcori_basecode,
    diag.c_fullname AS diag_fullname,
    sourcefact.pcori_basecode AS sourcefact_pcori_basecode,
    pdxfact.pcori_basecode AS pdxfact_pcori_basecode
   FROM i2b2demodata.observation_fact factline
     JOIN i2b2metadata.pcornet_diag diag ON factline.concept_cd::text = diag.c_basecode::text
     LEFT JOIN i2b2metadata.pcornet_diag sourcefact ON factline.modifier_cd::text = sourcefact.c_basecode::text AND sourcefact.c_fullname::text ~~ '\\PCORI_MOD\\CONDITION_OR_DX\\DX_SOURCE\\%'::text
     LEFT JOIN i2b2metadata.pcornet_diag pdxfact ON factline.modifier_cd::text = pdxfact.c_basecode::text AND pdxfact.c_fullname::text ~~ '\\PCORI_MOD\\PDX\\%'::text
  WHERE (diag.c_fullname::text !~~ '\\PCORI\\DIAGNOSIS\\10\\%'::text OR NOT (diag.pcori_basecode::text ~~ 'V%'::text AND diag.c_fullname::text !~~ '\\PCORI\\DIAGNOSIS\\10\\(V%\\(V%\\(V%'::text) AND NOT (diag.pcori_basecode::text ~~ 'E%'::text AND diag.c_fullname::text !~~ '\\PCORI\\DIAGNOSIS\\10\\(E%\\(E%\\(E%'::text) AND NOT (diag.c_fullname::text ~~ '\\PCORI\\DIAGNOSIS\\10\\%'::text AND diag.pcori_basecode::text ~ '^[0-9]'::text)) AND diag.c_fullname::text ~~ '\\PCORI\\DIAGNOSIS\\%'::text;


  
-- DROP VIEW i2b2demodata.vw_pmnprocedure_loader;
CREATE OR REPLACE VIEW i2b2demodata.vw_pmnprocedure_loader AS 
 SELECT obs.patient_num,
    obs.encounter_num,
    obs.provider_id,
    obs.start_date,
    pr.pcori_basecode,
    pr.c_fullname,
    pr.c_basecode
   FROM i2b2demodata.observation_fact obs
     JOIN i2b2metadata.pcornet_proc pr ON pr.c_basecode::text = obs.concept_cd::text AND pr.c_fullname::text ~~ '\\PCORI\\PROCEDURE\\%'::text;  
	 
	 
-- DROP VIEW i2b2demodata.vw_pmnprescribing_loader;
CREATE OR REPLACE VIEW i2b2demodata.vw_pmnprescribing_loader AS 
 SELECT fact.patient_num,
    fact.encounter_num,
    fact.provider_id,
    fact.start_date,
    fact.end_date,
    mo.pcori_cui,
    fact.concept_cd,
    fact.instance_num,
    max(
        CASE
            WHEN basis.c_basecode IS NULL THEN NULL::text::character varying
            ELSE basis.pcori_basecode
        END::text) AS basis_basecode,
    max(
        CASE
            WHEN freq.c_basecode IS NULL THEN NULL::text::character varying
            ELSE freq.pcori_basecode
        END::text) AS frequency_basecode,
    max(
        CASE
            WHEN quantity.c_basecode IS NULL THEN NULL::numeric
            ELSE fact.nval_num
        END) AS quantity_nval,
    max(
        CASE
            WHEN refills.c_basecode IS NULL THEN NULL::numeric
            ELSE fact.nval_num
        END) AS refills_nval,
    max(
        CASE
            WHEN supply.c_basecode IS NULL THEN NULL::numeric
            ELSE fact.nval_num
        END) AS supply_nval,
    max(
        CASE
            WHEN quantity_unit.c_basecode IS NULL THEN NULL::text::character varying
            ELSE fact.units_cd
        END::text) AS quantity_unit,
    "substring"(mo.c_name::text, 0, 50) AS raw_rx_med_name
   FROM i2b2metadata.pcornet_med mo
     JOIN i2b2demodata.observation_fact fact ON fact.concept_cd::text = mo.c_basecode::text
     LEFT JOIN i2b2metadata.pcornet_med basis ON fact.modifier_cd::text = basis.c_basecode::text AND basis.c_fullname::text ~~ '\\PCORI_MOD\\RX_BASIS\\PR%'::text
     LEFT JOIN i2b2metadata.pcornet_med freq ON fact.modifier_cd::text = freq.c_basecode::text AND freq.c_fullname::text ~~ '\\PCORI_MOD\\RX_FREQUENCY%'::text
     LEFT JOIN i2b2metadata.pcornet_med quantity ON fact.modifier_cd::text = quantity.c_basecode::text AND quantity.c_fullname::text ~~ '\\PCORI_MOD\\RX_QUANTITY%'::text
     LEFT JOIN i2b2metadata.pcornet_med refills ON fact.modifier_cd::text = refills.c_basecode::text AND refills.c_fullname::text ~~ '\\PCORI_MOD\\RX_REFILLS%'::text
     LEFT JOIN i2b2metadata.pcornet_med supply ON fact.modifier_cd::text = supply.c_basecode::text AND supply.c_fullname::text ~~ '\\PCORI_MOD\\RX_DAYS_SUPPLY%'::text
     LEFT JOIN i2b2metadata.pcornet_med quantity_unit ON fact.units_cd::text = quantity_unit.c_basecode::text AND quantity_unit.c_fullname::text ~~ '\\PCORI_MOD\\RX_QUANTITY_UNIT\\%'::text
  GROUP BY fact.patient_num, fact.encounter_num, fact.provider_id, fact.start_date, fact.end_date, mo.pcori_cui, fact.concept_cd, fact.instance_num, ("substring"(mo.c_name::text, 0, 50));	 
  
  
  
-- DROP VIEW i2b2demodata.vw_pmnvitals_loader;
CREATE OR REPLACE VIEW i2b2demodata.vw_pmnvitals_loader AS 
 SELECT obs.patient_num::text AS patid,
    obs.encounter_num::text AS encounterid,
    obs.patient_num,
    obs.encounter_num,
    to_char(obs.start_date, 'YYYY-MM-DD'::text)::timestamp without time zone AS measure_date,
    to_char(obs.start_date, 'HH24:MI'::text) AS measure_time,
    obs.start_date,
    COALESCE(max(
        CASE
            WHEN vs.c_fullname::text ~~ '\\PCORI_MOD\\VITAL_SOURCE\\%'::text THEN vs.c_symbol
            ELSE NULL::character varying
        END::text), 'HC'::text) AS vital_source,
    max(
        CASE
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\HT%'::text THEN obs.nval_num
            ELSE NULL::numeric
        END) AS ht,
    max(
        CASE
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\WT%'::text THEN obs.nval_num
            ELSE NULL::numeric
        END) AS wt,
    max(
        CASE
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\BP\\DIASTOLIC%'::text THEN obs.nval_num
            ELSE NULL::numeric
        END) AS diastolic,
    max(
        CASE
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\BP\\SYSTOLIC%'::text THEN obs.nval_num
            ELSE NULL::numeric
        END) AS systolic,
    max(
        CASE
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\ORIGINAL_BMI%'::text THEN obs.nval_num
            ELSE NULL::numeric
        END) AS original_bmi,
    COALESCE(max(
        CASE
            WHEN bpp.c_fullname::text ~~ '\\PCORI_MOD\\BP_POSITION\\%'::text THEN "substring"(bpp.pcori_basecode::text, "position"(bpp.pcori_basecode::text, ':'::text) + 1, 2)
            ELSE NULL::text
        END), 'NI'::text) AS bp_position,
    COALESCE(max(
        CASE
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\TOBACCO\\SMOKING\\%'::text THEN vitals.pcori_basecode
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\TOBACCO\\__\\%'::text THEN vitals.pcori_basecode
            ELSE NULL::character varying
        END::text), 'NI'::text) AS smoking,
    COALESCE(max(
        CASE
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\TOBACCO\\02\\%'::text THEN vitals.pcori_basecode
            WHEN vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\TOBACCO\\__\\%'::text THEN vitals.pcori_basecode
            ELSE NULL::character varying
        END::text), 'NI'::text) AS tobacco
   FROM i2b2demodata.observation_fact obs
     JOIN i2b2metadata.pcornet_vital vitals ON obs.concept_cd::text = vitals.c_basecode::text AND (obs.nval_num <= 10000000::numeric OR obs.nval_num IS NULL)
     LEFT JOIN i2b2metadata.pcornet_vital bpp ON obs.modifier_cd::text = bpp.c_basecode::text AND bpp.c_fullname::text ~~ '\\PCORI_MOD\\BP_POSITION\\%'::text
     LEFT JOIN i2b2metadata.pcornet_vital vs ON obs.modifier_cd::text = vs.c_basecode::text AND vs.c_fullname::text ~~ '\\PCORI_MOD\\VITAL_SOURCE\\%'::text
  WHERE vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\BP\\DIASTOLIC\\%'::text OR vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\BP\\SYSTOLIC\\%'::text OR vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\HT\\%'::text OR vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\WT\\%'::text OR vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\ORIGINAL_BMI\\%'::text OR vitals.c_fullname::text ~~ '\\PCORI\\VITAL\\TOBACCO\\%'::text
  GROUP BY (obs.patient_num::text), (obs.encounter_num::text), obs.patient_num, obs.encounter_num, (to_char(obs.start_date, 'YYYY-MM-DD'::text)::timestamp without time zone), (to_char(obs.start_date, 'HH24:MI'::text)), obs.start_date;


-- DROP VIEW i2b2demodata.vw_pmnlabresults_cm_loader;
CREATE OR REPLACE VIEW i2b2demodata.vw_pmnlabresults_cm_loader AS 
 SELECT obs.patient_num,
    obs.valtype_cd,
    obs.encounter_num,
    obs.modifier_cd,
    obs.start_date,
    obs.end_date,
    obs.tval_char,
    obs.nval_num,
    obs.units_cd,
    obs.valueflag_cd,
    lab.pcori_specimen_source,
    lab.pcori_basecode,
    ont_parent.c_basecode AS c_ont_parent_basecode
   FROM i2b2demodata.observation_fact obs
     JOIN i2b2metadata.pcornet_lab lab ON lab.c_basecode::text = obs.concept_cd::text AND lab.c_fullname::text ~~ '\\PCORI\\LAB_RESULT_CM\\%'::text
     JOIN i2b2metadata.pcornet_lab ont_loinc ON lab.pcori_basecode::text = ont_loinc.pcori_basecode::text AND ont_loinc.c_basecode::text ~~ 'LOINC:%'::text
     JOIN i2b2metadata.pcornet_lab ont_parent ON ont_loinc.c_path::text = ont_parent.c_fullname::text;


	 
  
----------------------------------------------------------------------------------------------------------------------  
-- Assumption: The following table will be created under popmednet schema of popmednet database
----------------------------------------------------------------------------------------------------------------------
	 
CREATE TABLE popmednet.pcornetchunking_log
(
  ddate timestamp without time zone,
  tablename character varying(50)
)
WITH (
  OIDS=FALSE
);	 

-- End of WU-specific functions, views and tables needed for performance enhancement.	 
----------------------------------------------------------------------------------------------------------------------   
	 
	 
-- End of Prep-to-transform code	 
----------------------------------------------------------------------------------------------------------------------   	 





	 
----------------------------------------------------------------------------------------------------------------------
-- Load the procedures	
-- Note: PostgreSQL version for the transform utilizes additional functions, views and tables created previously to enhance performance.
-- Please edit this for your institution/datamart, as appropriate.

  
----------------------------------------------------------------------------------------------------------------------  
-- Assumption: The following functions will be created under popmednet schema of popmednet database
----------------------------------------------------------------------------------------------------------------------

-- DROP FUNCTION popmednet.pcornetclear();
CREATE OR REPLACE FUNCTION popmednet.pcornetclear()
  RETURNS void AS
$BODY$ 
DECLARE 
BEGIN
    truncate table popmednet.pcornet_codelist;
    truncate table popmednet.pmn_labnormal;
    truncate table popmednet.pmnprescribing cascade;
    truncate table popmednet.pmndispensing cascade;
    truncate table popmednet.pmnprocedures cascade;
    truncate table popmednet.pmndiagnosis cascade;
    truncate table popmednet.pmncondition cascade;
    truncate table popmednet.pmnvital cascade;
    truncate table popmednet.pmnenrollment cascade;
    truncate table popmednet.pmnlab_result_cm cascade;
    truncate table popmednet.pmnencounter cascade;
    truncate table popmednet.pmndemographic cascade;
    truncate table popmednet.pmnharvest cascade;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


-- DROP FUNCTION popmednet.pcornetharvest();

CREATE OR REPLACE FUNCTION popmednet.pcornetharvest()
  RETURNS void AS
$BODY$ 

DECLARE sqltext character varying(4000);
begin
INSERT INTO popmednet.pmnharvest(
	NETWORKID,
	 NETWORK_NAME,
	 DATAMARTID,
	 DATAMART_NAME,
	 DATAMART_PLATFORM,
	 CDM_VERSION,
	 DATAMART_CLAIMS,
	 DATAMART_EHR,
	 BIRTH_DATE_MGMT,
	 ENR_START_DATE_MGMT,
	 ENR_END_DATE_MGMT,
	 ADMIT_DATE_MGMT,
	 DISCHARGE_DATE_MGMT,
	 PX_DATE_MGMT,
	 RX_ORDER_DATE_MGMT,
	 RX_START_DATE_MGMT,
	 RX_END_DATE_MGMT,
	 DISPENSE_DATE_MGMT,
	 LAB_ORDER_DATE_MGMT,
	 SPECIMEN_DATE_MGMT,
	 RESULT_DATE_MGMT,
	 MEASURE_DATE_MGMT,
	 ONSET_DATE_MGMT,
	 REPORT_DATE_MGMT,
	 RESOLVE_DATE_MGMT,
	 PRO_DATE_MGMT, 
	 REFRESH_DEMOGRAPHIC_DATE, 
	 REFRESH_ENROLLMENT_DATE, 
	 REFRESH_ENCOUNTER_DATE, 
	 REFRESH_DIAGNOSIS_DATE, 
	 REFRESH_PROCEDURES_DATE, 
	 REFRESH_VITAL_DATE, 
	 REFRESH_DISPENSING_DATE, 
	 REFRESH_LAB_RESULT_CM_DATE, 
	 REFRESH_CONDITION_DATE, 
	 REFRESH_PRO_CM_DATE, 
	 REFRESH_PRESCRIBING_DATE, 
	 REFRESH_PCORNET_TRIAL_DATE, 
	 REFRESH_DEATH_DATE, 
	 REFRESH_DEATH_CAUSE_DATE) 
VALUES (
	'C1', 
	'SCILHS', 
	popmednet.getDataMartID(), 
	popmednet.getDataMartName(), 
	popmednet.getDataMartPlatform(), 
	3.1, '01', '02', '01','01','02','01','01','01','01' -- Change this to match your datamart  
	,'01','01','01','01','01','01','01','01','01','01','01', -- Change this to match your datamart  
	NOW(),
	NOW(),
	NOW(),
	NOW(),
	NOW(),
	NOW(),
	NOW(),
	NOW(),
	NOW(),
	null,
	NOW(),
	null,
	null,
	null);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


  
  
-- DROP FUNCTION popmednet.pcornetdemographics(timestamp without time zone, timestamp without time zone, integer);
CREATE OR REPLACE FUNCTION popmednet.pcornetdemographics(
    min_birth_date timestamp without time zone DEFAULT '1800-01-01 00:00:00'::timestamp without time zone, -- change the default value to match your datamart filters
    max_birth_date timestamp without time zone DEFAULT ((now())::date - '18 years'::interval), -- change the default value to match your datamart filters; WU only includes patients/patient events with age >= 18 in popmednet.
    min_percentile_setting integer DEFAULT 23) -- change the default value to the appropriate percentile/k-value applicable for your datamart 
  RETURNS void AS
$BODY$ 
DECLARE 
BEGIN
    /* this view is required to be setup in the i2b2 database
      CREATE OR REPLACE VIEW i2b2demodata.miniloyalty_patient_facts AS 
         WITH allowed_facts AS (
                 SELECT o.patient_num,
                    count(*) AS num_facts
                   FROM i2b2demodata.observation_fact o
                     JOIN i2b2demodata.patient_dimension p_1 ON p_1.patient_num = o.patient_num
                  WHERE (o.concept_cd::text IN ( SELECT concept_dimension.concept_cd
                           FROM i2b2demodata.concept_dimension
                          WHERE concept_dimension.concept_path::text ~~ '\\PCORI%'::text)) AND o.start_date >= '2010-01-01 00:00:00'::timestamp without time zone
                  GROUP BY o.patient_num
                )
         SELECT p.patient_num,
            p.birth_date,
            NULL::double precision AS age,
            p.sex_cd,
            p.race_cd,
            COALESCE(allowed_facts.num_facts, 0::bigint) AS num_facts,
            ntile(100) OVER (PARTITION BY p.sex_cd ORDER BY (COALESCE(allowed_facts.num_facts, 0::bigint)), p.patient_num) AS percentile
           FROM i2b2demodata.patient_dimension p
             LEFT JOIN allowed_facts ON p.patient_num = allowed_facts.patient_num;    

       -- this foreign data wrapper is then needed in the popmednet database.
       create foreign table fdw_i2b2demodata.miniloyalty_patient_facts
         ( patient_num integer
         , birth_date timestamp
         , age double precision
         , sex_cd varchar(50)
         , race_cd varchar(50)
         , num_facts bigint
         , percentile integer
         ) server i2b2
         options (schema_name 'i2b2demodata', table_name 'miniloyalty_patient_facts');
     */

    raise info 'PERCENTILE VALUE = %', min_percentile_setting;

    -- assumption: for pcornet_demo when code type in ('RACE','SEX','HISPANIC') the values of pcori_basecode and pcori_shortcode are identical
    insert into popmednet.pmndemographic(raw_sex,PATID, BIRTH_DATE, BIRTH_TIME,SEX, HISPANIC, RACE, SEXUAL_ORIENTATION, GENDER_IDENTITY)
     select '0' as raw_sex
         , patient_num
         , birth_date
         , to_char(birth_date,'HH24:MI') as birth_time 
         , coalesce(sex.pcori_basecode, 'NI') as sex
         , case 
            when hisp.pcori_basecode is not null then hisp.pcori_basecode
            when hisp.pcori_basecode is null and race.pcori_basecode is null then 'NI'
            else 'N'
            end as hispanic
         , coalesce(race.pcori_basecode,'NI') as race
		 , 'NI' as SEXUAL_ORIENTATION
		 , 'NI' as GENDER_IDENTITY
         from (( fdw_i2b2demodata.miniloyalty_patient_facts p
           left outer join popmednet.pcornet_codelist sex on p.sex_cd = sex.code and sex.codetype = 'SEX')
           left outer join popmednet.pcornet_codelist race on p.race_cd = race.code and race.codetype = 'RACE')
           left outer join popmednet.pcornet_codelist hisp on p.race_cd = hisp.code and hisp.codetype = 'HISPANIC'
        where p.percentile >= min_percentile_setting -- percentile/K-value filter to eliminate low-fact patients 
          and p.birth_date between min_birth_date and max_birth_date; -- change this to match your datamart filters; WU only includes patients/patient events with age >= 18 in popmednet.
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


-- DROP FUNCTION popmednet.pcornetencounter();
CREATE OR REPLACE FUNCTION popmednet.pcornetencounter()
  RETURNS void AS
$BODY$
DECLARE 
    drg_code_length integer := 3;
    pcori_en_length integer := 2;
begin

    insert into popmednet.pmnencounter(PATID,ENCOUNTERID,admit_date ,ADMIT_TIME , 
         DISCHARGE_DATE ,DISCHARGE_TIME ,PROVIDERID ,FACILITY_LOCATION  
		,ENC_TYPE ,FACILITYID ,DISCHARGE_DISPOSITION , 
		DISCHARGE_STATUS ,DRG ,DRG_TYPE ,ADMITTING_SOURCE) 
    select distinct v.patient_num::varchar as PATID
        , v.encounter_num::varchar as ENCOUNTERID
        , start_Date as admit_date
        , to_char(start_Date,'HH24:MI') as ADMIT_TIME
        , end_Date as DISCHARGE_DATE
        , to_char(end_Date,'HH24:MI') as DISCHARGE_TIME
        , v.provider_id as PROVIDERID
        , null as FACILITY_LOCATION
        , coalesce(enctype.pcori_shortcode,'UN') as enc_type  
        , v.facility_id as facilityid
        , CASE 
            WHEN enctype.pcori_shortcode='AV' THEN 'NI' 
            ELSE disptype.pcori_shortcode
            END as discharge_disposition 
        , CASE 
            WHEN enctype.pcori_shortcode='AV' THEN 'NI' 
            ELSE statustype.pcori_shortcode
          END as discharge_status 
        , drg.drg_code as DRG
        , drg_type 
        , CASE 
            WHEN admitting_source IS NULL THEN 'NI' 
            WHEN admitting_source = 'Not recorded' THEN 'NI'
            ELSE admittype.pcori_shortcode 
          END as admitting_source 
    from (fdw_i2b2demodata.visit_dimension v 
    inner join popmednet.pmndemographic d on v.patient_num=d.patid::integer)
    left outer join  
       (select * from
       (select *,row_number() over (partition by  patient_num, encounter_num order by drg_type desc) AS rn from 
       (select f.patient_num,encounter_num,substring(drgfull.c_fullname,22,pcori_en_length) as drg_type
         , max(substring(drgfull.pcori_basecode,1+position(':' in drgfull.pcori_basecode),drg_code_length)) as drg_code 
         from fdw_i2b2demodata.observation_fact f 
         inner join popmednet.pmndemographic d on f.patient_num=d.patid::integer
         inner join fdw_i2b2metadata.pcornet_enc as drgfull on drgfull.pcori_basecode = f.concept_cd 
         and drgfull.c_fullname like '\\PCORI\\ENCOUNTER\\DRG\\%' 
         group by patient_num,encounter_num,drg_type)) drg
         where rn=1) drg -- This section is bugfixed to only include 1 drg if multiple DRG types exist in a single encounter...
      on drg.patient_num=v.patient_num and drg.encounter_num=v.encounter_num
    left outer join popmednet.pcornet_codelist enctype 
        on v.inout_cd = enctype.code and enctype.codetype = 'ENCTYPE'  
    left outer join popmednet.pcornet_codelist disptype 
        on v.discharge_disposition = disptype.code and disptype.codetype = 'DDISP'
    left outer join popmednet.pcornet_codelist statustype 
        on v.discharge_status = statustype.code and statustype.codetype = 'DSTATUS'
    left outer join popmednet.pcornet_codelist admittype 
        on v.admitting_source = admittype.code and admittype.codetype = 'ADMIT'
    where extract(year from age(start_Date, birth_date)) >= 18; -- change this to match your datamart filters; WU only includes patients/patient events with age >= 18 in popmednet.

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100; 



-- DROP FUNCTION popmednet.pcornetenrollment();
CREATE OR REPLACE FUNCTION popmednet.pcornetenrollment()
  RETURNS void AS
$BODY$
DECLARE 
    
BEGIN
    -- this is a place holder until loyalty cohort is implemented.  It should be removed once that table exits.
    CREATE TEMP TABLE i2b2loyalty_patients AS 
        Select null::varchar as patient_num
             , null::timestamp as period_start 
             , null::timestamp as period_end;

    INSERT INTO popmednet.pmnENROLLMENT
        ( PATID
        , ENR_START_DATE
        , ENR_END_DATE
        , CHART
        , ENR_BASIS
        ) 
    SELECT x.patient_num patid
        , case 
            when l.patient_num is not null then l.period_start 
            else enr_start 
          end enr_start_date
        , case 
            when l.patient_num is not null then l.period_end 
            when enr_end_end > enr_end then enr_end_end 
            else enr_end 
          end enr_end_date 
        , 'Y' chart
        , case 
            when l.patient_num is not null then 'A' 
            else 'E' 
          end enr_basis 
  from (
        select visit.patient_num::varchar
            , min(visit.start_date) enr_start
            , max(visit.start_date) enr_end
            , max(case 
                    when visit.end_date > (now()::timestamp without time zone) then (now()::timestamp without time zone) 
                    else visit.end_date
                  end ) enr_end_end 
        from fdw_i2b2demodata.visit_dimension visit
        inner join popmednet.pmndemographic demo
        on visit.patient_num = demo.patid::integer
        where extract(year from age(visit.start_Date, demo.birth_date)) >= 18
        group by patient_num::varchar
       ) x
       left outer join i2b2loyalty_patients l 
       on l.patient_num=x.patient_num;

    DISCARD TEMP;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
  
  
-- DROP FUNCTION popmednet.pcornetdiagnosis();
CREATE OR REPLACE FUNCTION popmednet.pcornetdiagnosis()
  RETURNS void AS
$BODY$ 
DECLARE 
    sqlstring text := '';
	
    /* this view is required to be setup in the i2b2 database
    CREATE OR REPLACE VIEW i2b2demodata.vw_pmndiagnosis_loader AS 
     SELECT factline.patient_num,
        factline.encounter_num,
        factline.start_date,
        factline.provider_id,
        diag.pcori_basecode AS diag_pcori_basecode,
        diag.c_fullname AS diag_fullname,
        sourcefact.pcori_basecode AS sourcefact_pcori_basecode,
        pdxfact.pcori_basecode AS pdxfact_pcori_basecode
       FROM (i2b2demodata.observation_fact factline
      INNER JOIN i2b2metadata.pcornet_diag diag 
         ON factline.concept_cd::text = diag.c_basecode::text )
       LEFT JOIN i2b2metadata.pcornet_diag sourcefact 
         ON factline.modifier_cd::text = sourcefact.c_basecode::text 
        AND sourcefact.c_fullname::text ~~ '\\PCORI_MOD\\CONDITION_OR_DX\\DX_SOURCE\\%'::text
       LEFT JOIN i2b2metadata.pcornet_diag pdxfact 
         ON factline.modifier_cd::text = pdxfact.c_basecode::text 
        AND pdxfact.c_fullname::text ~~ '\\PCORI_MOD\\PDX\\%'::text
      WHERE (  diag.c_fullname not like '\\PCORI\DIAGNOSIS\\10\\%' 
              or (    not (   diag.pcori_basecode like 'V%' 
                          and diag.c_fullname not like '\\PCORI\\DIAGNOSIS\\10\\(V%\\(V%\\(V%' 
                          )
                 and  not (   diag.pcori_basecode like '[E]%' 
                          and diag.c_fullname not like '\\PCORI\\DIAGNOSIS\\10\\(E%\\(E%\\(E%' 
                          ) 
                 and  not (   diag.c_fullname like '\\PCORI\\DIAGNOSIS\\10\\%' 
                          and diag.pcori_basecode ~ '^[0-9]'
                          ) 
                 )
              ) 
          and diag.c_fullname like '\\PCORI\\DIAGNOSIS\\%';

       -- this foreign data wrapper is then needed in the popmednet database.
		  CREATE FOREIGN TABLE fdw_i2b2demodata.vw_pmndiagnosis_loader  
        ( patient_num integer
        , encounter_num integer 
        , start_date timestamp without time zone
        , provider_id varchar(50)
        , diag_pcori_basecode varchar(50)
        , diag_fullname varchar(700) -- dxtype
        , sourcefact_pcori_basecode varchar(50) --dxsource
        , pdxfact_pcori_basecode varchar(50) --pdxsource
        ) SERVER i2b2 
        OPTIONS (schema_name 'i2b2demodata', table_name 'vw_pmndiagnosis_loader');
    */

begin
    sqlstring := '';
    sqlstring := sqlstring || '	insert into popmednet.pmndiagnosis ' || chr(10);
    sqlstring := sqlstring || '	        ( patid ' || chr(10);
    sqlstring := sqlstring || '	        , encounterid ' || chr(10);
    sqlstring := sqlstring || '	        , enc_type ' || chr(10);
    sqlstring := sqlstring || '	        , admit_date ' || chr(10);
    sqlstring := sqlstring || '	        , providerid ' || chr(10);
    sqlstring := sqlstring || '	        , dx ' || chr(10);
    sqlstring := sqlstring || '	        , dx_type ' || chr(10);
    sqlstring := sqlstring || '	        , dx_source ' || chr(10);
    sqlstring := sqlstring || '	        , pdx ' || chr(10);
	sqlstring := sqlstring || '	        , DX_ORIGIN ' || chr(10);
    sqlstring := sqlstring || '	        ) ' || chr(10);
    sqlstring := sqlstring || '	    select enc.patid ' || chr(10);
    sqlstring := sqlstring || '	        , enc.encounterid ' || chr(10);
    sqlstring := sqlstring || '	        , enc.enc_type ' || chr(10);
    sqlstring := sqlstring || '	        , enc.admit_date ' || chr(10);
    sqlstring := sqlstring || '	        , enc.providerid ' || chr(10);
    sqlstring := sqlstring || '	        , substring(factline.diag_pcori_basecode,position('':'' in factline.diag_pcori_basecode)+1,10) as dx ' || chr(10);
    sqlstring := sqlstring || '	        , substring(factline.diag_fullname,18,2) as dx_type ' || chr(10);
    sqlstring := sqlstring || '	        , coalesce(max(CASE  ' || chr(10);
    sqlstring := sqlstring || '	                WHEN enc_type=''AV'' THEN ''FI'' ' || chr(10);
    sqlstring := sqlstring || '	                ELSE substring(factline.sourcefact_pcori_basecode,position('':'' in factline.sourcefact_pcori_basecode)+1,2) ' || chr(10);
    sqlstring := sqlstring || '	              END ),''NI'') as dx_source ' || chr(10);
    sqlstring := sqlstring || '	        , coalesce(max(CASE enc_type ' || chr(10);
    sqlstring := sqlstring || '	                         when ''ED'' then ''X''' || chr(10);
    sqlstring := sqlstring || '	                         when ''AV'' then ''X''' || chr(10);
    sqlstring := sqlstring || '	                         when ''OA'' then ''X''' || chr(10);
    sqlstring := sqlstring || '	                         else translate(translate( ' || chr(10);
    sqlstring := sqlstring || '	                                substring(factline.pdxfact_pcori_basecode,position('':'' in factline.pdxfact_pcori_basecode)+1,2) ' || chr(10);
    sqlstring := sqlstring || '	                              ,''2'',''S''),''1'',''P'') ' || chr(10);
    sqlstring := sqlstring || '	                       end ),''NI'') as pdx ' || chr(10);
	sqlstring := sqlstring || '	        ,''BI'' as DX_ORIGIN ' || chr(10);
    sqlstring := sqlstring || '	    from fdw_i2b2demodata.vw_pmndiagnosis_loader factline ' || chr(10);
    sqlstring := sqlstring || '	    inner join popmednet.pmnENCOUNTER enc  ' || chr(10);
    sqlstring := sqlstring || '	        on enc.patid::integer = factline.patient_num  ' || chr(10);
    sqlstring := sqlstring || '	        and enc.encounterid::integer = factline.encounter_Num ' || chr(10);
    sqlstring := sqlstring || '       where start_date between ''[PUT_START_DATE_HERE]''::timestamp without time zone and ''[PUT_END_DATE_HERE]''::timestamp without time zone - interval ''1 second'''|| chr(10);
    sqlstring := sqlstring || '         and factline.encounter_num between ''[PUT_START_ENC_HERE]''::integer and ''[PUT_END_ENC_HERE]''::integer'|| chr(10);
    sqlstring := sqlstring || '         and enc.encounterid between ''[PUT_START_ENC_HERE]'' and ''[PUT_END_ENC_HERE]'''|| chr(10);
    sqlstring := sqlstring || '	    group by enc.patid ' || chr(10);
    sqlstring := sqlstring || '	        , enc.encounterid ' || chr(10);
    sqlstring := sqlstring || '	        , enc.enc_type ' || chr(10);
    sqlstring := sqlstring || '	        , factline.start_date ' || chr(10);
    sqlstring := sqlstring || '	        , factline.provider_id ' || chr(10);
    sqlstring := sqlstring || '	        , factline.diag_pcori_basecode ' || chr(10);
    sqlstring := sqlstring || '	        , substring(factline.diag_fullname,18,2); ' || chr(10);

    perform popmednet.execute_sql_stmt_with_chunking_by_date(sqlstring, 'pmndiagnosis', 180,1);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  
  
  
  
-- DROP FUNCTION popmednet.pcornetprocedure();
CREATE OR REPLACE FUNCTION popmednet.pcornetprocedure()
  RETURNS void AS
$BODY$
DECLARE 
BEGIN
    insert into popmednet.pmnprocedures
        ( patid
        , encounterid
        , enc_type
        , admit_date
        , providerid
        , px_date
        , px
        , px_type 
		-- px_source is populated with 'BI' as a default value in the table definition for WU; add this column if procedure data is populated from a different source 
        ) 
    select distinct fact.patient_num
        , enc.encounterid
        , enc.enc_type
        , enc.admit_date
        , enc.providerid
        , fact.start_date
        , substring(pr.pcori_basecode,position(':' in pr.pcori_basecode)+1,11) as px
        , substring(pr.c_fullname,18,2) as pxtype 
    from fdw_i2b2demodata.observation_fact fact
        inner join popmednet.pmnENCOUNTER enc 
            on enc.patid::integer = fact.patient_num 
            and enc.encounterid::integer = fact.encounter_Num
        inner join fdw_i2b2metadata.pcornet_proc pr 
            on pr.c_basecode = fact.concept_cd   
    where pr.c_fullname like '\\PCORI\\PROCEDURE\\%';
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100; 



-- DROP FUNCTION popmednet.pcornetprescribing();

CREATE OR REPLACE FUNCTION popmednet.pcornetprescribing()
  RETURNS void AS
$BODY$ 
DECLARE 
	sqlstring text := '';
begin
    /* this view is required to be setup in the i2b2 database
    CREATE OR REPLACE VIEW i2b2demodata.vw_pmnprescribing_loader AS 
     SELECT fact.patient_num,
        fact.encounter_num,
        fact.provider_id,
        fact.start_date,
        fact.end_date,
        mo.pcori_cui,
        fact.concept_cd,
        fact.instance_num, 
        max(case when basis.c_basecode is null then null::text else basis.pcori_basecode end) as basis_basecode,
        max(case when freq.c_basecode is null then null::text else freq.pcori_basecode end) as frequency_basecode,
        max(case when quantity.c_basecode is null then null::numeric else fact.nval_num end) as quantity_nval,
        max(case when refills.c_basecode is null then null::numeric else fact.nval_num end) as refills_nval,
        max(case when supply.c_basecode is null then null::numeric else fact.nval_num end) as supply_nval,
		max(case when quantity_unit.c_basecode is null then null::text else fact.units_cd end) as quantity_unit,
	substring(mo.c_name,0,50) as raw_rx_med_name
       FROM i2b2metadata.pcornet_med mo
         JOIN i2b2demodata.observation_fact fact ON fact.concept_cd::text = mo.c_basecode::text
         LEFT JOIN i2b2metadata.pcornet_med basis ON fact.modifier_cd::text = basis.c_basecode::text AND basis.c_fullname::text ~~ '\\PCORI_MOD\\RX_BASIS\\PR%'::text
         LEFT JOIN i2b2metadata.pcornet_med freq ON fact.modifier_cd::text = freq.c_basecode::text AND freq.c_fullname::text ~~ '\\PCORI_MOD\\RX_FREQUENCY%'::text
         LEFT JOIN i2b2metadata.pcornet_med quantity ON fact.modifier_cd::text = quantity.c_basecode::text AND quantity.c_fullname::text ~~ '\\PCORI_MOD\\RX_QUANTITY%'::text
         LEFT JOIN i2b2metadata.pcornet_med refills ON fact.modifier_cd::text = refills.c_basecode::text AND refills.c_fullname::text ~~ '\\PCORI_MOD\\RX_REFILLS%'::text
         LEFT JOIN i2b2metadata.pcornet_med supply ON fact.modifier_cd::text = supply.c_basecode::text AND supply.c_fullname::text ~~ '\\PCORI_MOD\\RX_DAYS_SUPPLY%'::text
	     LEFT JOIN i2b2metadata.pcornet_med quantity_unit ON fact.units_cd::text = quantity_unit.c_basecode::text AND quantity_unit.c_fullname::text ~~ '\\PCORI_MOD\\RX_QUANTITY_UNIT\\%'::text
		 group by fact.patient_num,
        fact.encounter_num,
        fact.provider_id,
        fact.start_date,
        fact.end_date,
        mo.pcori_cui,
        fact.concept_cd,
        fact.instance_num
	substring(mo.c_name,0,50);
	
	-- this foreign data wrapper is then needed in the popmednet database.
	CREATE FOREIGN TABLE fdw_i2b2demodata.vw_pmnprescribing_loader
		(patient_num integer ,
		encounter_num integer ,
		provider_id character varying(50) ,
		start_date timestamp without time zone ,
		end_date timestamp without time zone ,
		pcori_cui character varying(10) ,
		concept_cd character varying(50) ,
		frequency_basecode character varying(50) ,
		basis_basecode character varying(50) ,
		instance_num integer ,
		quantity_nval numeric ,
		refills_nval numeric ,
		supply_nval numeric ,
		raw_rx_med_name character varying(50) ,
		quantity_unit text 
		) SERVER i2b2
		OPTIONS (schema_name 'i2b2demodata', table_name 'vw_pmnprescribing_loader');	
    */

    sqlstring := '';
    sqlstring := sqlstring || '	insert into popmednet.pmnprescribing ' || chr(10);
    sqlstring := sqlstring || '		(PATID '|| chr(10);
    sqlstring := sqlstring || '		,encounterid '|| chr(10);
    sqlstring := sqlstring || '		,RX_PROVIDERID '|| chr(10);
    sqlstring := sqlstring || '		,RX_ORDER_DATE '|| chr(10); -- using start_date from i2b2
    sqlstring := sqlstring || '		,RX_ORDER_TIME '|| chr(10);  -- using time start_date from i2b2
    sqlstring := sqlstring || '		,RX_START_DATE '|| chr(10);
    sqlstring := sqlstring || '		,RX_END_DATE '|| chr(10); 
    sqlstring := sqlstring || '		,RXNORM_CUI '|| chr(10); --using i2b2metadata.pcornet_med pcori_cui
    sqlstring := sqlstring || '		,RX_QUANTITY '|| chr(10); ---- modifier nval_num
    sqlstring := sqlstring || '		,RX_REFILLS '|| chr(10);  -- modifier nval_num
    sqlstring := sqlstring || '		,RX_DAYS_SUPPLY '|| chr(10); -- modifier nval_num
    sqlstring := sqlstring || '		,RX_FREQUENCY '|| chr(10); --modifier with basecode lookup
    sqlstring := sqlstring || '		,RX_BASIS '|| chr(10); --modifier with basecode lookup
    sqlstring := sqlstring || '         ,RAW_RX_MED_NAME '|| chr(10); 
    sqlstring := sqlstring || '         ,RX_QUANTITY_UNIT '|| chr(10); 	
    sqlstring := sqlstring || '	--    ,RAW_RX_FREQUENCY '|| chr(10);  --not filling these right now
    sqlstring := sqlstring || '	--    ,RAW_RXNORM_CUI '|| chr(10);  --not filling these right now
    sqlstring := sqlstring || '	) '|| chr(10);
    sqlstring := sqlstring || 'SELECT distinct fact.patient_num::varchar as PATID'|| chr(10);
    sqlstring := sqlstring || '           , fact.encounter_num::varchar as encounterid'|| chr(10);
    sqlstring := sqlstring || '           , fact.provider_id as RX_PROVIDERID'|| chr(10);
    sqlstring := sqlstring || '           , fact.start_date as RX_ORDER_DATE'|| chr(10);
    sqlstring := sqlstring || '           , to_char(fact.start_date,''HH24:MI'') as RX_ORDER_TIME'|| chr(10);
    sqlstring := sqlstring || '           , fact.start_date as RX_start_date'|| chr(10);
    sqlstring := sqlstring || '           , fact.end_date as RX_END_DATE'|| chr(10);
    sqlstring := sqlstring || '           , fact.pcori_cui::integer as RXNORM_CUI'|| chr(10);
    sqlstring := sqlstring || '           , fact.quantity_nval as RX_QUANTITY'|| chr(10);
    sqlstring := sqlstring || '           , fact.refills_nval as RX_REFILLS'|| chr(10); -- WU currently does not populate refill count or supply count. 
    sqlstring := sqlstring || '           , fact.supply_nval as RX_DAYS_SUPPLY '|| chr(10);
    sqlstring := sqlstring || '           , substring(fact.frequency_basecode,1+position('':'' in fact.frequency_basecode)) as RX_FREQUENCY'|| chr(10);
    sqlstring := sqlstring || '           , substring(fact.basis_basecode,1+position('':'' in fact.basis_basecode)) as RX_BASIS'|| chr(10);
    sqlstring := sqlstring || '           , fact.RAW_RX_MED_NAME'|| chr(10);
    sqlstring := sqlstring || '           , fact.quantity_unit as RX_QUANTITY_UNIT'|| chr(10);	
    sqlstring := sqlstring || '       from popmednet.pmnencounter enc '|| chr(10);
    sqlstring := sqlstring || '           inner join fdw_i2b2demodata.vw_pmnprescribing_loader fact'|| chr(10);
    sqlstring := sqlstring || '               on enc.patid::integer = fact.patient_num '|| chr(10);
    sqlstring := sqlstring || '               and enc.encounterid::integer= fact.encounter_Num'|| chr(10);
    sqlstring := sqlstring || '       where start_date between ''[PUT_START_DATE_HERE]''::timestamp without time zone and ''[PUT_END_DATE_HERE]''::timestamp without time zone - interval ''1 second'''|| chr(10);
    sqlstring := sqlstring || '         and fact.encounter_num between ''[PUT_START_ENC_HERE]''::integer and ''[PUT_END_ENC_HERE]''::integer'|| chr(10);
    sqlstring := sqlstring || '         and enc.encounterid between ''[PUT_START_ENC_HERE]'' and ''[PUT_END_ENC_HERE]'''|| chr(10);

    perform popmednet.execute_sql_stmt_with_chunking_by_date(sqlstring, 'pmnprescribing');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  
  
  
  
-- DROP FUNCTION popmednet.pcornetvital();

CREATE OR REPLACE FUNCTION popmednet.pcornetvital()
  RETURNS void AS
$BODY$ 
DECLARE 
	sqlstring text := '';
begin
    /* this view is required to be setup in the i2b2 database
	create or replace view i2b2demodata.vw_pmnvitals_loader AS (
           select obs.patient_num::text as patid
               , obs.encounter_num::text as encounterid
               , obs.patient_num
               , obs.encounter_num
               , to_char(obs.start_Date,'YYYY-MM-DD')::timestamp without time zone as measure_date 
               , to_char(obs.start_Date,'HH24:MI') as measure_time 
               , obs.start_date 
               , coalesce(MAX(case when vs.c_fullname like '\\PCORI_MOD\\VITAL_SOURCE\\%' then vs.c_symbol else null end),'HC') vital_source 
               , max(case when vitals.c_fullname like '\\PCORI\\VITAL\\HT%' then obs.nval_num else null end) ht 
               , max(case when vitals.c_fullname like '\\PCORI\\VITAL\\WT%' then obs.nval_num else null end) wt 
               , MAX(case when vitals.c_fullname like '\\PCORI\\VITAL\\BP\\DIASTOLIC%' then obs.nval_num else null end) diastolic 
               , MAX(case when vitals.c_fullname like '\\PCORI\\VITAL\\BP\\SYSTOLIC%' then obs.nval_num else null end) systolic 
               , MAX(case when vitals.c_fullname like '\\PCORI\\VITAL\\ORIGINAL_BMI%' then obs.nval_num else null end) original_bmi 
               , coalesce(MAX(case  
                   when bpp.c_fullname like '\\PCORI_MOD\\BP_POSITION\\%' then substring(bpp.pcori_basecode,position(':' in bpp.pcori_basecode)+1,2)  
                   else null  
                 end),'NI') as bp_position 
               , coalesce(MAX(case  
                   when vitals.c_fullname like '\\PCORI\\VITAL\\TOBACCO\\SMOKING\\%' then vitals.pcori_basecode 
                   when vitals.c_fullname like '\\PCORI\\VITAL\\TOBACCO\\__\\%' then vitals.pcori_basecode  
                   else null 
                 end),'NI') as smoking  
               , coalesce(MAX(case  
                   when vitals.c_fullname like '\\PCORI\\VITAL\\TOBACCO\\02\\%' then vitals.pcori_basecode 
                   when vitals.c_fullname like '\\PCORI\\VITAL\\TOBACCO\\__\\%' then vitals.pcori_basecode 
                   else null  
                 end),'NI') as tobacco 
           from ((((i2b2demodata.observation_fact obs 
           inner join i2b2metadata.pcornet_vital vitals on obs.concept_cd = vitals.c_basecode and (obs.nval_num <= 10000000::numeric or obs.nval_num is null)) 
           left join i2b2metadata.pcornet_vital bpp on obs.modifier_cd = bpp.c_basecode and bpp.c_fullname like '\\PCORI_MOD\\BP_POSITION\\%' ) 
           left join i2b2metadata.pcornet_vital vs on obs.modifier_cd = vs.c_basecode and vs.c_fullname like '\\PCORI_MOD\\VITAL_SOURCE\\%' ) 
           ) 
           where (vitals.c_fullname like '\\PCORI\\VITAL\\BP\\DIASTOLIC\\%'  
               or vitals.c_fullname like '\\PCORI\\VITAL\\BP\\SYSTOLIC\\%'  
               or vitals.c_fullname like '\\PCORI\\VITAL\\HT\\%'  
               or vitals.c_fullname like '\\PCORI\\VITAL\\WT\\%'  
               or vitals.c_fullname like '\\PCORI\\VITAL\\ORIGINAL_BMI\\%'  
               or vitals.c_fullname like '\\PCORI\\VITAL\\TOBACCO\\%') 
            group by obs.patient_num::text
                , obs.encounter_num::text
                , obs.patient_num
                , obs.encounter_num
                , to_char(obs.start_Date,'YYYY-MM-DD')::timestamp without time zone
                , to_char(obs.start_Date,'HH24:MI') 
                , obs.start_date
       );
	   
	   
	-- this foreign data wrapper is then needed in the popmednet database.
    CREATE FOREIGN TABLE fdw_i2b2demodata.vw_pmnvitals_loader
        ( patid text
        , encounterid text
        , patient_num integer
        , encounter_num integer
        , measure_date timestamp
        , measure_time text
        , start_date timestamp
        , vital_source text
        , ht numeric
        , wt numeric
        , diastolic numeric
        , systolic numeric
        , original_bmi numeric
        , bp_position text
        , smoking text
        , tobacco text 
        ) SERVER i2b2
       OPTIONS (schema_name 'i2b2demodata', table_name 'vw_pmnvitals_loader');
    */


    sqlstring := 'insert into popmednet.pmnVITAL
                            ( patid
                            , encounterid
                            , measure_date
                            , measure_time
                            , vital_source
                            , ht
                            , wt
                            , diastolic
                            , systolic
                            , original_bmi
                            , bp_position
                            , smoking
                            , tobacco
                            , tobacco_type
                            ) 
                    select distinct y.patid,  
                           y.encounterid,  
                           y.measure_date::timestamp without time zone,  
                           y.measure_time, 
                           y.vital_source, 
                           y.ht,  
                           y.wt,  
                           y.diastolic,  
                           y.systolic,  
                           y.original_bmi,  
                           y.bp_position, 
                           y.smoking, 
                           y.tobacco, 
                           case  
                               when tobacco in (''02'',''03'',''04'') then  
                                   case when smoking in (''03'',''04'') then ''04'' 
                                       when smoking in (''01'',''02'',''07'',''08'') then ''01'' 
                                       else ''NI''  
                                   end 
                                when tobacco=''01'' then 
                                   case when smoking in (''03'',''04'') then ''02'' 
                                       when smoking in (''01'',''02'',''07'',''08'') then ''03'' 
                                       else ''OT''  
                                   end 
                               when tobacco in (''NI'',''OT'',''UN'') and smoking in (''01'',''02'',''07'',''08'') then  
                                   ''05''  
                               else ''NI''  
                           end tobacco_type  
                   from (
                        select obs.patid
                             , obs.encounterid
                             , obs.measure_date 
                             , obs.measure_time 
                             , coalesce(MAX(vital_source),''HC'') vital_source 
                             , max(ht) ht 
                             , max(wt) wt 
                             , MAX(diastolic) diastolic 
                             , MAX(systolic) systolic 
                             , MAX(original_bmi) original_bmi 
                             , coalesce(MAX(bp_position),''NI'') as bp_position 
                             , coalesce(MAX(smoking),''NI'') as smoking  
                             , coalesce(MAX(tobacco),''NI'') as tobacco 
                       FROM fdw_i2b2demodata.vw_pmnvitals_loader obs 
                       inner join popmednet.pmnencounter enc 
                          on obs.patient_num = enc.patid::integer and obs.encounter_num = enc.encounterid::integer 
                       where start_date between ''[PUT_START_DATE_HERE]''::timestamp without time zone 
                                            and ''[PUT_END_DATE_HERE]''::timestamp without time zone - interval ''1 second'' 
                         and obs.encounter_num between ''[PUT_START_ENC_HERE]''::integer and ''[PUT_END_ENC_HERE]''::integer 
                         and enc.encounterid between ''[PUT_START_ENC_HERE]'' and ''[PUT_END_ENC_HERE]''  
                       group by obs.patid
                             , obs.encounterid
                             , obs.measure_date 
                             , obs.measure_time 
                    ) y' ;

    perform popmednet.execute_sql_stmt_with_chunking_by_date(sqlstring, 'pmnvital',270,1);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  
  
  

-- DROP FUNCTION popmednet.pcornetlabresultcm();

CREATE OR REPLACE FUNCTION popmednet.pcornetlabresultcm()
  RETURNS void AS
$BODY$
DECLARE
    sqlstring text := '';
	
    /* this view is required to be setup in the i2b2 database
    CREATE OR REPLACE VIEW i2b2demodata.vw_pmnlabresults_cm_loader AS 
	SELECT obs.patient_num,
    obs.valtype_cd,
    obs.encounter_num,
    obs.modifier_cd,
    obs.start_date,
    obs.end_date,
    obs.tval_char,
    obs.nval_num,
    obs.units_cd,
    obs.valueflag_cd,
    lab.pcori_specimen_source,
    lab.pcori_basecode,
    ont_parent.c_basecode AS c_ont_parent_basecode
	FROM i2b2demodata.observation_fact obs
     JOIN i2b2metadata.pcornet_lab lab ON lab.c_basecode::text = obs.concept_cd::text AND lab.c_fullname::text ~~ '\\PCORI\\LAB_RESULT_CM\\%'::text
     JOIN i2b2metadata.pcornet_lab ont_loinc on lab.pcori_basecode = ont_loinc.pcori_basecode and ont_loinc.c_basecode like 'LOINC:%'::text
     JOIN i2b2metadata.pcornet_lab ont_parent ON ont_loinc.c_path::text = ont_parent.c_fullname::text;

	-- this foreign data wrapper is then needed in the popmednet database.
    create foreign table fdw_i2b2demodata.vw_pmnlabresults_cm_loader
            ( patient_num integer
            , valtype_cd varchar(50)
            , encounter_num integer
            , modifier_cd varchar(100)
            , start_date timestamp without time zone
            , end_date timestamp without time zone
            , tval_char varchar(2000)
            , nval_num numeric(18,5)
            , units_cd varchar(50)
            , valueflag_cd varchar(50)
            , pcori_specimen_source varchar(50)
            , pcori_basecode varchar(50)
            , c_ont_parent_basecode varchar(50)
            ) 
        SERVER i2b2
        OPTIONS (schema_name 'i2b2demodata', table_name 'vw_pmnlabresults_cm_loader');
    */

    -- Optimized to use temp tables; also, removed "distinct" - much faster and seems unnecessary - 12/9/15

    /* WUSTL/BJC source data does not include PRIORITY data 
    priority CURSOR FOR  
        SELECT patient_num 
               ,encounter_num 
               ,provider_id 
               ,concept_cd 
               ,start_date 
               ,lsource.pcori_basecode PRIORITY 
        FROM   i2b2fact 
               INNER JOIN popmednet.pmnencounter enc 
                       ON enc.patid = i2b2fact.patient_num 
                          AND enc.encounterid = i2b2fact.encounter_num 
               INNER JOIN fdw_i2b2metadata.pcornet_lab lsource 
                       ON i2b2fact.modifier_cd = lsource.c_basecode 
        WHERE  c_fullname LIKE '\\PCORI_MOD\\PRIORITY\\%' 
    */
    
    /* WUSTL/BJC source data does not include LOCATION data 
    SELECT patient_num 
           ,encounter_num 
           ,provider_id 
           ,concept_cd 
           ,start_date 
           ,lsource.pcori_basecode RESULT_LOC 
    INTO   #location 
    FROM   i2b2fact 
           INNER JOIN popmednet.pmnencounter enc 
                   ON enc.patid = i2b2fact.patient_num 
                      AND enc.encounterid = i2b2fact.encounter_num 
           INNER JOIN fdw_i2b2metadata.pcornet_lab lsource 
                   ON i2b2fact.modifier_cd = lsource.c_basecode 
    WHERE  c_fullname LIKE '\\PCORI_MOD\\RESULT_LOC\\%' 
    */
BEGIN
    sqlstring := '';
    sqlstring := sqlstring || '	INSERT INTO popmednet.pmnlab_result_cm ' || chr(10);
    sqlstring := sqlstring || '                 ( patid  ' || chr(10);
    sqlstring := sqlstring || '                 , encounterid  ' || chr(10);
    sqlstring := sqlstring || '                 , lab_name  ' || chr(10);
    sqlstring := sqlstring || '                 , specimen_source  ' || chr(10);
    sqlstring := sqlstring || '                 , lab_loinc  ' || chr(10);
    sqlstring := sqlstring || '                 , priority  ' || chr(10);
    sqlstring := sqlstring || '                 , result_loc  ' || chr(10);
    sqlstring := sqlstring || '                 , lab_px  ' || chr(10);
    sqlstring := sqlstring || '                 , lab_px_type  ' || chr(10);
    sqlstring := sqlstring || '                 , lab_order_date  ' || chr(10);
    sqlstring := sqlstring || '                 , specimen_date  ' || chr(10);
    sqlstring := sqlstring || '                 , specimen_time  ' || chr(10);
    sqlstring := sqlstring || '                 , result_date  ' || chr(10);
    sqlstring := sqlstring || '                 , result_time  ' || chr(10);
    sqlstring := sqlstring || '                 , result_qual  ' || chr(10);
    sqlstring := sqlstring || '                 , result_num  ' || chr(10);
    sqlstring := sqlstring || '                 , result_modifier  ' || chr(10);
    sqlstring := sqlstring || '                 , result_unit  ' || chr(10);
    sqlstring := sqlstring || '                 , norm_range_low  ' || chr(10);
    sqlstring := sqlstring || '                 , norm_modifier_low  ' || chr(10);
    sqlstring := sqlstring || '                 , norm_range_high  ' || chr(10);
    sqlstring := sqlstring || '                 , norm_modifier_high  ' || chr(10);
    sqlstring := sqlstring || '                 , abn_ind  ' || chr(10);
    --sqlstring := sqlstring || '                 --, raw_lab_name ' || chr(10); -- table definition will populate NULL for WU 
    --sqlstring := sqlstring || '                 --, raw_lab_code ' || chr(10); -- table definition will populate NULL for WU 
    --sqlstring := sqlstring || '                 --, raw_panel ' || chr(10); -- table definition will populate NULL for WU 
    sqlstring := sqlstring || '                 , raw_result ' || chr(10);
    --sqlstring := sqlstring || '                 , raw_unit   ' || chr(10); -- table definition will populate NULL for WU 
    --sqlstring := sqlstring || '                 , raw_order_dept   ' || chr(10); -- table definition will populate NULL for WU 
    --sqlstring := sqlstring || '                 , raw_facility_code   ' || chr(10); -- table definition will populate NULL for WU
    sqlstring := sqlstring || '                 )  ' || chr(10);
    sqlstring := sqlstring || '    SELECT DISTINCT enc.patid ' || chr(10);
    sqlstring := sqlstring || '            , enc.encounterid  ' || chr(10);
    sqlstring := sqlstring || '            , CASE  ' || chr(10);
    sqlstring := sqlstring || '               WHEN obs.c_ont_parent_basecode LIKE ''LAB_NAME%'' THEN Substring(obs.c_ont_parent_basecode, 10, 10)  ' || chr(10);
    sqlstring := sqlstring || '               ELSE ''UN''  ' || chr(10);
    sqlstring := sqlstring || '              END as LAB_NAME  ' || chr(10);
    sqlstring := sqlstring || '            , CASE  ' || chr(10);
    sqlstring := sqlstring || '               WHEN obs.pcori_specimen_source LIKE ''%or SR_PLS'' THEN ''SR_PLS''  ' || chr(10);
    sqlstring := sqlstring || '               ELSE coalesce(obs.pcori_specimen_source, ''NI'') ' || chr(10);
    sqlstring := sqlstring || '              END as specimen_source  ' || chr(10);
    sqlstring := sqlstring || '            , coalesce(obs.pcori_basecode, ''NI'') as LAB_LOINC ' || chr(10);  
    sqlstring := sqlstring || '            , ''NI''  as PRIORITY  ' || chr(10); --coalesce(p.priority, ''NI'')
    sqlstring := sqlstring || '            , ''NI''  as RESULT_LOC  ' || chr(10); --coalesce(l.result_loc, ''NI'')
    sqlstring := sqlstring || '            , coalesce(obs.pcori_basecode, ''NI'') as LAB_PX  ' || chr(10);
    sqlstring := sqlstring || '            , ''LC'' as LAB_PX_TYPE  ' || chr(10);
    sqlstring := sqlstring || '            , obs.start_date as LAB_ORDER_DATE  ' || chr(10);
    sqlstring := sqlstring || '            , obs.start_date as SPECIMEN_DATE  ' || chr(10);
    sqlstring := sqlstring || '            , to_char(obs.start_date, ''HH24:MI'') as SPECIMEN_TIME  ' || chr(10);
    sqlstring := sqlstring || '            , coalesce(obs.end_date, obs.start_date) as RESULT_DATE  ' || chr(10);
    sqlstring := sqlstring || '            , to_char(obs.end_date, ''HH24:MI'') as RESULT_TIME  ' || chr(10);
    sqlstring := sqlstring || '            , CASE WHEN obs.ValType_Cd=''T'' THEN CASE WHEN obs.Tval_Char IS NOT NULL THEN ''OT'' ELSE ''NI'' END END RESULT_QUAL  ' || chr(10); -- TODO: Should be a standardized value
    sqlstring := sqlstring || '            , CASE   ' || chr(10);
    sqlstring := sqlstring || '                WHEN obs.valtype_cd = ''N'' THEN obs.nval_num  ' || chr(10);
    sqlstring := sqlstring || '                ELSE NULL::integer ' || chr(10);
    sqlstring := sqlstring || '              END as RESULT_NUM  ' || chr(10);
    sqlstring := sqlstring || '            ,CASE  ' || chr(10);
    sqlstring := sqlstring || '               WHEN obs.valtype_cd = ''N'' THEN (  ' || chr(10);
    sqlstring := sqlstring || '                    CASE coalesce(NULLIF(obs.tval_char, ''''), ''NI'')  ' || chr(10);
    sqlstring := sqlstring || '                        WHEN ''E'' THEN ''EQ''  ' || chr(10);
    sqlstring := sqlstring || '                        WHEN ''NE'' THEN ''OT''  ' || chr(10);
    sqlstring := sqlstring || '                        WHEN ''L'' THEN ''LT''  ' || chr(10);
    sqlstring := sqlstring || '                        WHEN ''LE'' THEN ''LE''  ' || chr(10);
    sqlstring := sqlstring || '                        WHEN ''G'' THEN ''GT''  ' || chr(10);
    sqlstring := sqlstring || '                        WHEN ''GE'' THEN ''GE''  ' || chr(10);
    sqlstring := sqlstring || '                        ELSE ''NI''  ' || chr(10);
    sqlstring := sqlstring || '                      END  ' || chr(10);
    sqlstring := sqlstring || '                    )  ' || chr(10);
    sqlstring := sqlstring || '               ELSE ''TX''  ' || chr(10);
    sqlstring := sqlstring || '             END as RESULT_MODIFIER  ' || chr(10);
    sqlstring := sqlstring || '            , coalesce(obs.units_cd, ''NI'') as RESULT_UNIT  ' || chr(10); -- TODO: Should be a standardized unit
    sqlstring := sqlstring || '            , NULLIF(norm.norm_range_low, '''') as NORM_RANGE_LOW ' || chr(10); 
    sqlstring := sqlstring || '            , coalesce(norm.norm_modifier_low, ''UN'') as norm_modifier_low  ' || chr(10);
    sqlstring := sqlstring || '            , NULLIF(norm.norm_range_high, '''') as NORM_RANGE_HIGH  ' || chr(10);
    sqlstring := sqlstring || '            , coalesce(norm.norm_modifier_high, ''UN'') as norm_modifier_high  ' || chr(10);
    sqlstring := sqlstring || '            ,CASE coalesce(NULLIF(obs.valueflag_cd, ''''), ''NI'')  ' || chr(10);
    sqlstring := sqlstring || '               WHEN ''H'' THEN ''AH''  ' || chr(10);
    sqlstring := sqlstring || '               WHEN ''L'' THEN ''AL''  ' || chr(10);
    sqlstring := sqlstring || '               WHEN ''A'' THEN ''AB''  ' || chr(10);
    sqlstring := sqlstring || '               ELSE ''NI''  ' || chr(10);
    sqlstring := sqlstring || '             END as ABN_IND  ' || chr(10);
    sqlstring := sqlstring || '            ,CASE  ' || chr(10);
    sqlstring := sqlstring || '               WHEN obs.valtype_cd = ''T'' THEN left(obs.tval_char,50) ' || chr(10); -- raw_result can only fit 50 characters. 
    sqlstring := sqlstring || '               ELSE left(Cast(obs.nval_num AS VARCHAR),50)  ' || chr(10);
    sqlstring := sqlstring || '             END as RAW_RESULT  ' || chr(10);    
    sqlstring := sqlstring || '    FROM fdw_i2b2demodata.vw_pmnlabresults_cm_loader obs ' || chr(10);
    sqlstring := sqlstring || '           INNER JOIN popmednet.pmnencounter enc  ' || chr(10);
    sqlstring := sqlstring || '                   ON enc.patid::integer = obs.patient_num  ' || chr(10);
    sqlstring := sqlstring || '                  AND enc.encounterid::integer = obs.encounter_num  ' || chr(10);
    sqlstring := sqlstring || '           LEFT OUTER JOIN popmednet.pmn_labnormal norm  ' || chr(10);
    sqlstring := sqlstring || '                   ON obs.c_ont_parent_basecode = norm.lab_name  ' || chr(10);	
               /* WUSTL/BJC does not need these two join statements. 
    sqlstring := sqlstring || '           LEFT OUTER JOIN priority p  ' || chr(10);
    sqlstring := sqlstring || '                    ON obs.patient_num = p.patient_num  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.encounter_num = p.encounter_num  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.provider_id = p.provider_id  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.concept_cd = p.concept_cd  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.start_date = p.start_date  ' || chr(10);
    sqlstring := sqlstring || '           LEFT OUTER JOIN location l  ' || chr(10);
    sqlstring := sqlstring || '                    ON obs.patient_num = l.patient_num  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.encounter_num = l.encounter_num  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.provider_id = l.provider_id  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.concept_cd = l.concept_cd  ' || chr(10);
    sqlstring := sqlstring || '                   AND obs.start_date = l.start_date  ' || chr(10);
              */ 
    sqlstring := sqlstring || '   where start_date between ''[PUT_START_DATE_HERE]''::timestamp without time zone and ''[PUT_END_DATE_HERE]''::timestamp without time zone - interval ''1 second'''|| chr(10);
    sqlstring := sqlstring || '     and obs.encounter_num between ''[PUT_START_ENC_HERE]''::integer and ''[PUT_END_ENC_HERE]''::integer'|| chr(10);
    sqlstring := sqlstring || '     and enc.encounterid between ''[PUT_START_ENC_HERE]'' and ''[PUT_END_ENC_HERE]'''|| chr(10);
    sqlstring := sqlstring || '     and obs.valtype_cd IN ( ''N'', ''T'' )  ' || chr(10);
    sqlstring := sqlstring || '     AND obs.c_ont_parent_basecode LIKE ''LAB_NAME%''  ' || chr(10); -- Excludes non-pcori labs for WU
    sqlstring := sqlstring || '     AND obs.modifier_cd = ''@'' ' ; 

raise info '%', sqlstring;

    perform popmednet.execute_sql_stmt_with_chunking_by_date(sqlstring, 'pmnlab_result_cm');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  
  
  

-- DROP FUNCTION popmednet.pcornetreport();

CREATE OR REPLACE FUNCTION popmednet.pcornetreport()
  RETURNS void AS
$BODY$ 
declare 
begin
    create sequence if not exists popmednet.seq_i2preport_runid increment 1 start with 1;

    perform nextval('popmednet.seq_i2preport_runid');

    execute popmednet.add_row_to_i2pReport('Pats',        'popmednet.pmndemographic',   'fdw_i2b2demodata.patient_dimension');
    execute popmednet.add_row_to_i2pReport('Enrollment',  'popmednet.pmnenrollment',    'fdw_i2b2demodata.patient_dimension');
    execute popmednet.add_row_to_i2pReport('Encounters',  'popmednet.pmnencounter',     'fdw_i2b2demodata.visit_dimension v inner join popmednet.pmndemographic d on v.patient_num=d.patid::integer');
    execute popmednet.add_row_to_i2pReport('DX',          'popmednet.pmndiagnosis',     'fdw_i2b2demodata.observation_fact o inner join fdw_i2b2metadata.pcornet_diag p on o.concept_cd = p.c_basecode and p.c_fullname like ''\\PCORI\\DIAGNOSIS%'' ');
    execute popmednet.add_row_to_i2pReport('PX',          'popmednet.pmnprocedures',     'fdw_i2b2demodata.observation_fact o inner join fdw_i2b2metadata.pcornet_proc p on o.concept_cd = p.c_basecode and p.c_fullname like ''\\PCORI\\PROCEDURE%'' ');
    execute popmednet.add_row_to_i2pReport('Condition',   'popmednet.pmncondition');
    execute popmednet.add_row_to_i2pReport('Vital',       'popmednet.pmnvital',         'fdw_i2b2demodata.observation_fact o where concept_cd like ''VITAL:%'' ');
    execute popmednet.add_row_to_i2pReport('Labs',        'popmednet.pmnlab_result_cm', 'fdw_i2b2demodata.observation_fact o where concept_cd like ''LABS:%'' ');
    execute popmednet.add_row_to_i2pReport('Prescribing', 'popmednet.pmnprescribing',   'fdw_i2b2demodata.observation_fact o where concept_cd like ''NDC:%'' ');
    execute popmednet.add_row_to_i2pReport('Dispensing',  'popmednet.pmndispensing');

    --select concept 'Data Type',sourceval 'From i2b2',destval 'In PopMedNet', diff 'Difference' from popmednet.i2pReport where runidvar=runid;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  

  
-- DROP FUNCTION popmednet.add_row_to_i2preport(character varying, character varying, character varying);
CREATE OR REPLACE FUNCTION popmednet.add_row_to_i2preport(
    concept character varying,
    table1 character varying,
    table2 character varying DEFAULT NULL::character varying)
  RETURNS void AS
$BODY$
DECLARE
    sqlstring varchar;
    my_count1 integer;
    my_count1dist integer;
    my_count2 integer;
    my_count2dist integer;
BEGIN
    sqlstring = 'select count(*), count(distinct patid) from '||table1||';';
    execute sqlstring into my_count1, my_count1dist;
    if nullif(table2,'') is null then 
        insert into popmednet.i2pReport(runid, rundate, concept, destval, destdistinct) 
            values (currval('popmednet.seq_i2preport_runid'), now(), concept, my_count1, my_count1dist);
    else 
        sqlstring = 'select count(*), count(distinct patient_num) from '||table2||';';
        execute sqlstring into my_count2, my_count2dist;
    
        insert into popmednet.i2pReport(runid, rundate, concept, sourceval, destval, diff, sourcedistinct, destdistinct, diffdistinct) 
            values (currval('popmednet.seq_i2preport_runid'), now(), concept, my_count2, my_count1, my_count2-my_count1, my_count2dist, my_count1dist, my_count2dist-my_count1dist);
    end if;
    raise info 'Reporting on % rows from %',my_count1, table1;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  

-- End of Load the Procedures  
----------------------------------------------------------------------------------------------------------------------  