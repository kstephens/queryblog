BEGIN;

-- Demo source data table ----------------------------------------------------------

CREATE TEMP SEQUENCE loans_seq;
CREATE TEMP TABLE loans ( 
       	id int NOT NULL PRIMARY KEY DEFAULT nextval('loans_seq')
       ,created_on TIMESTAMP NOT NULL DEFAULT NOW() 
       ,amount FLOAT
       ,approved BOOLEAN
);
CREATE INDEX loans_created_on ON loans(created_on);

INSERT INTO loans ( amount, approved, created_on ) VALUES
        ( 123.00, 'f', '2011-03-01' )
       ,(  82.00, 't', '2011-03-01' )
       ,( 256.00, 't', '2011-03-01' )
       ,( 123.00, 'f', '2011-03-02' )
       ,( 233.00, 'f', '2011-03-02' )
       ,( 432.00, 't', '2011-03-03' )
       ,( 444.00, 't', '2011-03-03' )
       ,( 342.00, 't', '2011-03-04' )
;

-- quebee reports schema ----------------------------------------------------------

CREATE TEMP SEQUENCE quebee_reports_seq;
CREATE TEMP TABLE quebee_reports (
        id int NOT NULL PRIMARY KEY DEFAULT nextval('quebee_reports_seq')
       ,name VARCHAR(255) NOT NULL
       ,description VARCHAR(255) NOT NULL
       ,table_name VARCHAR(255) NOT NULL
       ,title_template TEXT
       ,select_stmt TEXT
       ,where_clause_template TEXT
);

CREATE TEMP SEQUENCE quebee_reports_executions_seq;
CREATE TEMP TABLE quebee_report_executions ( 
        id int NOT NULL PRIMARY KEY DEFAULT nextval('quebee_reports_executions_seq')
       ,report_id int NOT NULL -- REFERENCES quebee_reports.id
       ,title TEXT NOT NULL
       ,where_clause TEXT NOT NULL
       ,started_on TIMESTAMP
       ,finished_on TIMESTAMP
       ,created_on TIMESTAMP DEFAULT NOW()
       ,rows int
       ,errors TEXT
);


-- create report ----------------------------------------------------------

INSERT INTO quebee_reports VALUES 
       ( 1
       ,'loan_daily_summary'
       ,'sample loan report'
       ,'qb_report_xyz'
       ,E'loan_daily_summary for <<TODAY-1>>'
       ,E'SELECT 
(SELECT COUNT(*) FROM loans l WHERE l.approved = \'t\' <<WHERE>>) AS num_approved, 
(SELECT COUNT(*) FROM loans l WHERE l.approved = \'f\' <<WHERE>>) AS num_declined'
       ,E'<<TODAY-1>> <= created_on AND created_on < <<TODAY>>'
       );

-- generate materialized report table based on columns of 'SELECT ...' above.
CREATE TEMP TABLE qb_report_xyz (
       -- REPORT HEADER
        qb_re_id int NOT NULL -- REFERENCES quebee_report_executions.id
       ,qb_re_row int NOT NULL
       -- REPORT DATA
       ,num_approved int
       ,num_declined int
);

-- report run #1 ----------------------------------------------------------

INSERT INTO quebee_report_executions
VALUES ( 1
       , (SELECT id FROM quebee_reports WHERE name = 'loan_daily_summary')
       , E'loan_daily_summary for 2011-03-01'
       , E'\'2011-03-01\' <= created_on AND created_on < \'2011-03-02\''
       , timeofday()::timestamp
       );

CREATE TEMP SEQUENCE qb_rr_xyz_seq;

INSERT INTO qb_report_xyz
SELECT 
  (SELECT MAX(id) FROM quebee_report_executions), nextval('qb_rr_xyz_seq'),
(SELECT COUNT(*) FROM loans WHERE approved = 't' AND ('2011-03-01' <= created_on AND created_on < '2011-03-02')) AS num_approved, 
(SELECT COUNT(*) FROM loans WHERE approved = 'f' AND ('2011-03-01' <= created_on AND created_on < '2011-03-02')) AS num_declined
;

DROP SEQUENCE qb_rr_xyz_seq;

UPDATE quebee_report_executions re
SET 
   rows = (SELECT COUNT(*) FROM qb_report_xyz WHERE qb_re_id = re.id )
  ,finished_on = timeofday()::timestamp
WHERE re.id = (SELECT MAX(id) FROM quebee_report_executions);

-- report run #2 ----------------------------------------------------------

INSERT INTO quebee_report_executions
VALUES ( 2
       , (SELECT id FROM quebee_reports WHERE name = 'loan_daily_summary')
       , E'loan_daily_summary for 2011-03-02'
       , E'\'2011-03-02\' <= created_on AND created_on < \'2011-03-03\''
       , timeofday()::timestamp
       );

CREATE TEMP SEQUENCE qb_rr_xyz_seq;

INSERT INTO qb_report_xyz
SELECT
  (SELECT MAX(id) FROM quebee_report_executions), nextval('qb_rr_xyz_seq'),
(SELECT COUNT(*) FROM loans WHERE approved = 't' AND ('2011-03-02' <= created_on AND created_on < '2011-03-03')) AS num_approved, 
(SELECT COUNT(*) FROM loans WHERE approved = 'f' AND ('2011-03-02' <= created_on AND created_on < '2011-03-03')) AS num_declined
;

DROP SEQUENCE qb_rr_xyz_seq;

UPDATE quebee_report_executions re 
SET 
   rows = (SELECT COUNT(*) FROM qb_report_xyz WHERE qb_re_id = re.id )
  ,finished_on = timeofday()::timestamp
WHERE re.id = (SELECT MAX(id) FROM quebee_report_executions);

-- report run #3 ----------------------------------------------------------

INSERT INTO quebee_report_executions
VALUES ( 3
       , (SELECT id FROM quebee_reports WHERE name = 'loan_daily_summary')
       , E'loan_daily_summary for 2011-03-03'
       , E'\'2011-03-03\' <= created_on AND created_on < \'2011-03-04\''
       , timeofday()::timestamp
       );

CREATE TEMP SEQUENCE qb_rr_xyz_seq;

INSERT INTO qb_report_xyz
SELECT
  (SELECT MAX(id) FROM quebee_report_executions), nextval('qb_rr_xyz_seq'),
(SELECT COUNT(*) FROM loans WHERE approved = 't' AND ('2011-03-03' <= created_on AND created_on < '2011-03-04')) AS num_approved, 
(SELECT COUNT(*) FROM loans WHERE approved = 'f' AND ('2011-03-03' <= created_on AND created_on < '2011-03-04')) AS num_declined
;

DROP SEQUENCE qb_rr_xyz_seq;

UPDATE quebee_report_executions re 
SET 
   rows = (SELECT COUNT(*) FROM qb_report_xyz WHERE qb_re_id = re.id )
  ,finished_on = timeofday()::timestamp
WHERE re.id = (SELECT MAX(id) FROM quebee_report_executions);

-- See materialized report data ----------------------------------------------------------

\d+ t

\d+ qb_report_xyz

\x
SELECT * FROM quebee_reports;
SELECT * 
FROM 
--        quebee_reports r
       quebee_report_executions re 
--WHERE
--   r.id = re.report_id
;
\x

SELECT * FROM qb_report_xyz;

ROLLBACK;

