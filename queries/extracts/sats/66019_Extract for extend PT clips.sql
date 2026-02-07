WITH
        params AS
        (        
                SELECT
                    /*+ materialize */
                    datetolongTZ(TO_CHAR(:fromDate,'YYYY-MM-DD HH24:MI'), co.DEFAULTTIMEZONE) AS fromDate,
                    datetolongTZ(TO_CHAR(:toDate,'YYYY-MM-DD HH24:MI'), co.DEFAULTTIMEZONE) AS toDate,
                    c.ID AS center
                FROM
                    SATS.CENTERS c
                JOIN COUNTRIES co ON c.COUNTRY = co.ID
                WHERE
                    c.time_zone IS NOT NULL
        )
SELECT
        je.PERSON_CENTER || 'p' || je.PERSON_ID AS "Member ID",
        regexp_substr(substr(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(je.BIG_TEXT,2000,1)),-24,24),'[^\ ]+',1,1) AS "Clip card expire date old",
        regexp_substr(substr(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(je.BIG_TEXT,2000,1)),-24,24),'[^ ]+',3,3) AS "Clip card expire date new",
        TO_CHAR(longtodateC(je.CREATION_TIME, je.PERSON_CENTER), 'YYYY-MM-DD') AS "Date for doing the extension", 
        e.PERSONCENTER || 'p' || e.PERSONID AS "Staff ID"
FROM
    journalentries je
JOIN PARAMS params ON params.center = je.PERSON_CENTER
LEFT JOIN SATS.EMPLOYEES e ON je.CREATORCENTER = e.CENTER AND je.CREATORID = e.ID
WHERE
    je.PERSON_CENTER IN (:Scope)
    AND je.jetype = 3
    AND je.name = 'Clipcard end date changed'
    AND je.creation_time BETWEEN params.fromDate AND params.toDate
        