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