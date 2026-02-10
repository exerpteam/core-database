-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT DISTINCT
         EXTERNAL_ID,
         PERSON_ID,
         Tab."fullname",
         PERSONTYPE,
         SSN,
         emailT.TXTVALUE AS EMAIL,
         mobile.TXTVALUE AS CELL,
         home.TXTVALUE AS TEL_HOME,
         BIRTHDATE,
         Tab."type",
         Tab."ingresso",
         Uscita
 FROM
 (
         SELECT DISTINCT
                 p.EXTERNAL_ID,
                 p.CENTER || 'p' || p.ID AS PERSON_ID,
                 p.CENTER,
                 p.ID,
                 p.FULLNAME,
                 CASE  p.persontype  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN  'CHILD'  WHEN 10 THEN  'EXTERNAL_STAFF' ELSE 'UNKNOWN' END AS PERSONTYPE,
                 p.SSN,
                 P.BIRTHDATE,
                 'CHECKIN' as TYPE,
                 to_char(longToDateC(cin.CHECKIN_TIME,p.center),'YYYY-MM-dd HH24:MI') as Ingresso,
                 to_char(longToDateC(cin.CHECKOUT_TIME,p.center),'YYYY-MM-dd HH24:MI') as Uscita,
                 cin.PERSON_CENTER,
                 cin.CHECKIN_TIME AS STARTDATE
         FROM
                 PERSONS p
         JOIN CHECKINS cin
         ON
                 cin.PERSON_CENTER = p.CENTER
                 AND cin.PERSON_ID = p.ID
         UNION
         SELECT DISTINCT
                 p.EXTERNAL_ID,
                 p.CENTER || 'p' || p.ID AS PERSON_ID,
                 p.CENTER,
                 p.ID,
                 p.FULLNAME,
                 CASE  p.persontype  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN  'CHILD'  WHEN 10 THEN  'EXTERNAL_STAFF' ELSE 'UNKNOWN' END AS PERSONTYPE,
                 p.SSN,
                 P.BIRTHDATE,
                 'ATTENDANCE' as "TYPE",
                 to_char(longToDateC(att.START_TIME,p.center),'YYYY-MM-dd HH24:MI') as Ingresso,
                 to_char(longToDateC(att.STOP_TIME,p.center),'YYYY-MM-dd HH24:MI') as Uscita,
                 att.PERSON_CENTER,
                 att.START_TIME AS STARTDATE
         FROM
                 PERSONS p
         JOIN
                 ATTENDS att
         ON
                 att.PERSON_CENTER = p.CENTER
                 AND att.PERSON_ID = p.ID
 ) Tab
 JOIN
         PERSON_EXT_ATTRS emailT
 ON
         Tab.CENTER = emailT.PERSONCENTER
         AND Tab.ID = emailT.PERSONID
         AND emailT.NAME = '_eClub_Email'
 JOIN
         PERSON_EXT_ATTRS mobile
 ON
         Tab.CENTER = mobile.PERSONCENTER
         AND Tab.ID = mobile.PERSONID
         AND mobile.NAME = '_eClub_PhoneSMS'
 JOIN
         PERSON_EXT_ATTRS home
 ON
         Tab.CENTER = home.PERSONCENTER
         AND Tab.ID = home.PERSONID
         AND home.NAME = '_eClub_PhoneHome'
 WHERE
         Tab.PERSON_CENTER IN ($$Scope$$)
     AND Tab.STARTDATE BETWEEN $$FromDate$$ AND $$ToDate$$
 ORDER BY
         Tab."ingresso",
         Tab."fullname",
         Tab."type" DESC