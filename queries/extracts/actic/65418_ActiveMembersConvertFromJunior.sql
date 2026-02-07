/**
* List all members turning 16 this day.
* Supposed to be emailed to administrator for conversion from Junior to Adult.
*/
SELECT
	p.CENTER || 'p' || p.ID as PersonKey,
	CASE p.STATUS
        WHEN 6 THEN 'TEMPORARY INACTIVE'
        WHEN 1 THEN 'ACTIVE'
        ELSE 'UNKNOWN'
    END AS PersonStatus
	
FROM PERSONS p 
WHERE 
	p.BIRTHDATE = CURRENT_DATE - INTERVAL '16 years'
	AND p.STATUS IN (1, 6)