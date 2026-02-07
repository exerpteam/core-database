-- This is the version from 2026-02-05
--  
SELECT
PERSON_CENTER ||'p'|| PERSON_ID PERSON_ID,
TO_CHAR(longtodate(CREATION_TIME), 'DD-MM-YYYY HH24:MI') TIME,
NAME
FROM
JOURNALENTRIES
WHERE
NAME = 'Error in auto-showup occurred after checkin'