WITH thisbuild_timestamp AS (

    SELECT 
    
    MIN(startuptime) AS cut_time
    
    FROM 
    
    client_instances 
    
    WHERE 
    
    clientversion LIKE '%555%'


), casl1 AS (

    SELECT
    
    TO_CHAR(LONGTODATEC(entry_time,person_center),'YYYY-MM-DD HH24:MI:SS') AS entry_date
	,change_attribute
	,person_center||'p'||person_id AS person_id
	,TO_CHAR(LONGTODATEC((SELECT cut_time FROM thisbuild_timestamp),100),'YYYY-MM-DD HH24:MI:SS') AS upgrade_time
    
    FROM 
    
    person_change_logs 
    
    WHERE 
    
    change_attribute = 'CASL1' 
    AND new_value = 'false' 
    AND login_type = 'p'
    AND entry_time > (SELECT cut_time FROM thisbuild_timestamp)

    LIMIT 1
), casl2 AS (

    SELECT
    
     TO_CHAR(LONGTODATEC(entry_time,person_center),'YYYY-MM-DD HH24:MI:SS') AS entry_date
	,change_attribute
	,person_center||'p'||person_id AS person_id
	,TO_CHAR(LONGTODATEC((SELECT cut_time FROM thisbuild_timestamp),100),'YYYY-MM-DD HH24:MI:SS') AS upgrade_time
    
    FROM 
    
    person_change_logs 
    
    WHERE 
    
    change_attribute = 'CASL2' 
    AND new_value = 'false' 
    AND login_type = 'p'
    AND entry_time > (SELECT cut_time FROM thisbuild_timestamp)

    LIMIT 1
)
, casl3 AS (

    SELECT
    
        TO_CHAR(LONGTODATEC(entry_time,person_center),'YYYY-MM-DD HH24:MI:SS') AS entry_date
	,change_attribute
	,person_center||'p'||person_id AS person_id
	,TO_CHAR(LONGTODATEC((SELECT cut_time FROM thisbuild_timestamp),100),'YYYY-MM-DD HH24:MI:SS') AS upgrade_time
    
    FROM 
    
    person_change_logs 
    
    WHERE 
    
    change_attribute = 'CASL3' 
    AND new_value = 'false' 
    AND login_type = 'p'
    AND entry_time > (SELECT cut_time FROM thisbuild_timestamp)

    LIMIT 1
)
, casl4 AS (

    SELECT
    
        TO_CHAR(LONGTODATEC(entry_time,person_center),'YYYY-MM-DD HH24:MI:SS') AS entry_date
	,change_attribute
	,person_center||'p'||person_id AS person_id
	,TO_CHAR(LONGTODATEC((SELECT cut_time FROM thisbuild_timestamp),100),'YYYY-MM-DD HH24:MI:SS') AS upgrade_time
    
    FROM 
    
    person_change_logs 
    
    WHERE 
    
    change_attribute = 'CASL4' 
    AND new_value = 'false' 
    AND login_type = 'p'
    AND entry_time > (SELECT cut_time FROM thisbuild_timestamp)

    LIMIT 1
)
, casl5 AS (

    SELECT
    
        TO_CHAR(LONGTODATEC(entry_time,person_center),'YYYY-MM-DD HH24:MI:SS') AS entry_date
	,change_attribute
	,person_center||'p'||person_id AS person_id
	,TO_CHAR(LONGTODATEC((SELECT cut_time FROM thisbuild_timestamp),100),'YYYY-MM-DD HH24:MI:SS') AS upgrade_time
    
    FROM 
    
    person_change_logs 
    
    WHERE 
    
    change_attribute = 'CASL5' 
    AND new_value = 'false' 
    AND login_type = 'p'
    AND entry_time > (SELECT cut_time FROM thisbuild_timestamp)

    LIMIT 1
)

SELECT * FROM CASL1

UNION

SELECT * FROM CASL2

UNION

SELECT * FROM CASL3

UNION

SELECT * FROM CASL4

UNION

SELECT * FROM CASL5