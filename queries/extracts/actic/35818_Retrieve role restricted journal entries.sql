-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    jes.PERSON_CENTER || 'p'|| jes.PERSON_ID AS MEMBER,
    jes.JETYPE AS ENTRY_TYPE,
    jes.NAME,
    longtodatec(jes.CREATION_TIME, jes.PERSON_CENTER)       AS CREATION_DATE,
   utl_raw.cast_to_varchar2( dbms_lob.substr( jes.BIG_TEXT, 2000, 1 ) ) AS NOTE,
    jes.ID,
    jer.ROLE_ID,
    rol.ROLENAME
FROM
    JOURNALENTRIES jes
JOIN
    JOURNALENTRY_AND_ROLE_LINK jer
ON
    jes.id = jer.JOURNALENTRY_ID
JOIN
    ROLES rol
ON
    jer.ROLE_ID = rol.id

WHERE jes.PERSON_CENTER IN (:scope)
