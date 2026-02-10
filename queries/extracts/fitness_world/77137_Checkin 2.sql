-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT *
FROM
fw.checkins c
WHERE
    longtodate(c.checkin_time) > current_date -1
AND	c.CHECKIN_CENTER in (:scope)	
