-- This is the version from 2026-02-05
--  
SELECT
*
FROM
fw.checkin_log c
WHERE
    c.checkin_time >= :From_date
AND c.checkin_time < :To_date
AND	c.CHECKIN_CENTER in (:scope)