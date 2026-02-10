-- The extract is extracted from Exerp on 2026-02-08
-- Select a Timezone and enter a list of Person_id's. You will be given a list of Journal_Id's related to the Fast Pass Doucments for each Person_id. The Journal_id's that need to be deleted can be provided to Exerp Support. 
SELECT
    person_center||'p'||person_id                                                   AS "Member ID",
    TO_CHAR(longtodateTZ(creation_time,:timezone),'YYYY-MM-DD HH24:MI:SS') AS "Creation Time",  
    id AS "Journal ID",
    name
FROM
    journalentries je
WHERE
    jetype = 38
AND
 person_center||'p'||person_id IN (:member)
AND name = 'Fast Pass Consent';