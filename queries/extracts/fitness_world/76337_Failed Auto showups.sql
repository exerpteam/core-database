-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
PERSON_CENTER ||'p'|| PERSON_ID PERSON_ID,
TO_CHAR(longtodate(CREATION_TIME), 'DD-MM-YYYY HH24:MI') TIME,
NAME
FROM
JOURNALENTRIES
WHERE
NAME = 'Error in auto-showup occurred after checkin'