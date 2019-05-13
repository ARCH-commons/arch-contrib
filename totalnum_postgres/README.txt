Totalnum functions have been adapted for PostgreSQL by 
Dan Vianello, Center for Biomedical Informatics, Washington University in St. Louis.
Latest update 03/07/2017
If you have questions or issues with the script, please contact i2b2admin@bmi.wustl.edu 
Team at WashU: Snehil Gupta, Connie Zabarovskaya, Brian Romine, Dan Vianello

Original MSSQL scripts were used from 
https://github.com/SCILHS/SCILHS-utils/tree/master/totalnum/MSSQL; 
id of GitHub commit: 7ab5cd8f679d6f32912e5f556be941a4ca428058

Instructions:
1) Load functions from totalnum_loader_postgres.sql

2) Load function runtotalnum() from runtotalnum_postgres.sql, which also will create the 
   master view with all counts for SCILHS reporting

3 - Option A) Run runtotalnum() like this: select i2b2metadata.runtotalnum(); 
              This will run for a VERY long time (see below, ~69 hours) 

3 - Option B) Run each domain separately in their own process.  
              Total runtime will drop to ~30 hours.
              Note: the parent i2b2metadata.runtotalnum() function also creates a view. 
              As long as there isn't a new domain added to the ontology then the view does 
              NOT need to be recreated each time the total num functions are run.  There 
              is code at the bottom of this README that can generate each of these code
              blocks dynamically for copying into individual sessions, though minor 
              reformatting is needed (to remove cell separator characters, i.e. ";")

3Bi) Run this code block to process PCORNET_ENROLL
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for PCORNET_ENROLL' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.PCORNET_ENROLL');
        select count(*) into v_numpats from i2b2metadata.PCORNET_ENROLL where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for PCORNET_ENROLL, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;

3Bii) Run this code block to process PCORNET_ENC
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for PCORNET_ENC' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.PCORNET_ENC');
        select count(*) into v_numpats from i2b2metadata.PCORNET_ENC where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for PCORNET_ENC, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;

3Biii) Run this code block to process PCORNET_PROC 
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for PCORNET_PROC' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.PCORNET_PROC');
        select count(*) into v_numpats from i2b2metadata.PCORNET_PROC where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for PCORNET_PROC, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;

3Biv) Run this code block to process PCORNET_DIAG
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for PCORNET_DIAG' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.PCORNET_DIAG');
        select count(*) into v_numpats from i2b2metadata.PCORNET_DIAG where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for PCORNET_DIAG, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;

3Bv) Run this code block to process PCORNET_DEMO
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for PCORNET_DEMO' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.PCORNET_DEMO');
        select count(*) into v_numpats from i2b2metadata.PCORNET_DEMO where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for PCORNET_DEMO, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;

3Bvi) Run this code block to process PCORNET_VITAL
   
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for PCORNET_VITAL' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.PCORNET_VITAL');
        select count(*) into v_numpats from i2b2metadata.PCORNET_VITAL where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for PCORNET_VITAL, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;

3Bvii) Run this code block to process PCORNET_LAB
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for pcornet_lab' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.pcornet_lab');
        select count(*) into v_numpats from i2b2metadata.pcornet_lab where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for pcornet_lab, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;

3Bviii) Run this code block to process PCORNET_MED
    do $$
    declare
        v_numpats bigint := 0;
    begin
        raise info 'At %: starting totals for PCORNET_MED' ,clock_timestamp();
        perform i2b2metadata.run_all_counts('i2b2metadata.PCORNET_MED');
        select count(*) into v_numpats from i2b2metadata.PCORNET_MED where c_totalnum is not null and c_totalnum <> 0;
        raise info 'At %: populated % totals for PCORNET_MED, runtime: %' ,clock_timestamp(),v_numpats, clock_timestamp()-now();
    end;
    $$ language plpgsql;


Additional note for 3A
======================
Recent runtimes by domain:
INFO: At 2016-12-19 09:35:45.674580-06: populated      1 totals for PCORNET_ENROLL, runtime: 00:00:09.384148
INFO: At 2016-12-19 09:40:59.908635-06: populated    293 totals for PCORNET_DEMO,   runtime: 00:01:02.403403
INFO: At 2016-12-19 12:28:36.544984-06: populated     67 totals for PCORNET_VITAL,  runtime: 02:48:07.45632
INFO: At 2016-12-19 15:25:22.838417-06: populated  10987 totals for PCORNET_MED,    runtime: 05:44:24.575468
INFO: At 2016-12-19 15:53:49.566838-06: populated    153 totals for PCORNET_ENC,    runtime: 06:14:58.311842
INFO: At 2016-12-19 18:35:26.357629-06: populated  96623 totals for PCORNET_PROC,   runtime: 08:56:11.234711
INFO: At 2016-12-20 01:24:43.481263-06: populated    247 totals for pcornet_lab,    runtime: 15:43:57.785389
INFO: At 2016-12-20 15:40:53.924875-06: populated 146729 totals for PCORNET_DIAG,   runtime: 1 day 06:01:22.034619
TOTAL: ~69 hours.

Additional note for 3B
======================
This query can be used to generate code blocks for running each domain separately:
 select  'do $$'||chr(10)
        ||'declare'||chr(10)
        ||chr(9)||'v_numpats bigint := 0;'||chr(10)
        ||'begin'||chr(10)
        ||chr(9)||chr(9)||'raise info ''At %: starting totals for '||c_table_name||''' ,clock_timestamp();'||chr(10)
        ||chr(9)||'PERFORM i2b2metadata.run_all_counts(' || quote_literal('i2b2metadata.'||c_table_name) || ');'||chr(10)
        , chr(9)||'select count(*) into v_numpats from i2b2metadata.'||c_table_name||' where c_totalnum is not null and c_totalnum <> 0;'||chr(10)
        ||chr(9)||'raise info ''At %: populated % totals for '||c_table_name||', runtime: %'' ,clock_timestamp(),v_numpats, clock_timestamp()-now();'||chr(10)
        ||'end;'||chr(10)
        , '$$ language plpgsql;'||chr(10)||chr(10)
        from i2b2metadata.TABLE_ACCESS 
        where c_visualattributes like '%A%' and c_table_cd like 'PCORI%';












