 SELECT
                 per.EXTERNAL_ID AS MemberID,
                 per.FIRSTNAME AS MemberName,
                 per.LASTNAME AS MemberLastname,
                 per.BIRTHDATE AS Birth,
                 per.SEX AS Sex,
                 cs.FACILITY_URL AS Facility
 FROM
         PERSONS per
 JOIN
         CENTERS cs
         ON
         cs.ID = per.CENTER
         AND CS.COUNTRY = 'IT'
 LEFT JOIN
         VA.PERSON_EXT_ATTRS ea
         ON
         per.CENTER = ea.PERSONCENTER
         AND per.ID = ea.PERSONID
         AND ea.NAME = '_eClub_WellnessCloudUserPermanentToken'
 WHERE
         per.STATUS IN (1)
         AND ea.TXTVALUE is null
