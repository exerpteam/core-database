-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
*
FROM
fw.checkin_log c
WHERE
    c.checkin_time >= :From_date
AND c.checkin_time < :To_date
AND	c.CHECKIN_CENTER in (:scope)