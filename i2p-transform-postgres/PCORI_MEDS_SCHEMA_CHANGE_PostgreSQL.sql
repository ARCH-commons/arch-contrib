--------------------------------------------------------------------------------------------------
-- i2b2-to-PCORNet Loader - PCORNET_MED Patch - PostgreSQL
---------------------------------------------------------------------------------------------------
-- PCORI_MEDS_SCHEMA_CHANGE Script
-- This is a PostgreSQL version script to fix a bug where null sourcesystem_cd not being transferred to pcori_ndc/rxnorm. See MSSQL version for reference.
-- Orignal MSSQL version 1.1 authored by: Jeff Klann, PhD; Aaron Abend 09/21/2016
-- PostgreSQL version authored by: Dan Vianello (Washington University in St Louis), 11/30/2016

-- Note:
-- This script alters data structures - it should be carefully reviewed before using and it is best if each statement is run separately
-- If you added local children to the ontology and did not use the Mapper/integration tool, update the sourcesystem_cd in the procedures below.
-- Run this on the database that contains your PCORnet_med ontology; it will add NDC and CUI columns.
-- Please contact WU team at help@bmi.wustl.edu for questions or feedback regarding this script.

----------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE i2b2metadata.pcornet_med ADD COLUMN pcori_cui character varying(10);
ALTER TABLE i2b2metadata.pcornet_med ADD COLUMN pcori_cui pcori_ndc character varying(12);

-- Update the NDC codes for non-integration rows
update i2b2metadata.pcornet_med set pcori_ndc=pcori_basecode where char_length(pcori_basecode)=11
and c_hlevel>2 and (sourcesystem_cd is null or sourcesystem_cd not in ('integration_tool')) and pcori_basecode not like 'N%';

-- Update RxNorm NDC codes for non-integration and non-RxNorm rows
update i2b2metadata.pcornet_med set pcori_cui=pcori_basecode where char_length(pcori_basecode)<11 
and c_hlevel>2 and (sourcesystem_cd is null or sourcesystem_cd not in ('integration_tool')) and pcori_basecode not like 'N%' and m_applied_path='@' and c_basecode not like 'NDFRT%';

-- Update integration and NDC rows for RxNorm 
with recursive cui as 
(select c_fullname,pcori_cui,c_hlevel 
from i2b2metadata.pcornet_med 
where pcori_cui is not null
   union all
select m.c_fullname,cui.pcori_cui,m.c_hlevel 
from i2b2metadata.pcornet_med m
    inner join cui on cui.c_fullname=m.c_path 
	where m.pcori_cui is null), 
cuid as ( 
select c_fullname,pcori_cui, row_number() over (partition by C_FULLNAME order by c_hlevel desc) as row from cui)
update i2b2metadata.pcornet_med med set pcori_cui=cuid.pcori_cui 
from cuid 
where cuid.c_fullname=med.c_fullname
and cuid.row=1 
and med.pcori_cui is null;

-- Update integration rows for NDC 
with recursive ndc as 
(select c_fullname,pcori_ndc,c_hlevel 
from i2b2metadata.pcornet_med 
where pcori_ndc is not null
	union all
select m.c_fullname,ndc.pcori_ndc,m.c_hlevel 
from i2b2metadata.pcornet_med m
    inner join ndc on ndc.c_fullname=m.c_path 
	where m.pcori_ndc is null), 
ndcd as ( 
select c_fullname,pcori_ndc, row_number() over (partition by C_FULLNAME order by c_hlevel desc) as row from ndc)
update i2b2metadata.pcornet_med med set pcori_ndc=ndcd.pcori_ndc 
from ndcd 
where ndcd.c_fullname=med.c_fullname
and ndcd.row=1 
and med.pcori_ndc is null;