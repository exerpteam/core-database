-- This is the version from 2026-02-05
--  
SELECT *
FROM
fw.checkins c
WHERE
    longtodate(c.checkin_time) > current_date -1
AND	c.CHECKIN_CENTER in (:scope)	
