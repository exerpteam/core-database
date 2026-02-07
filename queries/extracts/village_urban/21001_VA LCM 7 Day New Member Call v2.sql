---CTE for journal notes---         
WITH
    journal AS MATERIALIZED
    (   SELECT
            je.person_center,
            je.person_id,
            je.CREATORCENTER ,
            je.CREATORID,
            TO_CHAR(longtodateTZ(je.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS "Date Contact",
            je.NAME AS "Note Subject",
            convert_from(je.BIG_TEXT, 'UTF-8') AS "Note Details"
        FROM journalentries je
 WHERE
         je.CREATION_TIME BETWEEN :Start_Date AND (:End_Date+(24*3600*1000)-1)
     AND je.PERSON_CENTER IN (:Scope)
            AND
            (
                je.NAME LIKE '%LCM 7 DAY NEW%'
                OR je.NAME LIKE '%lcm 7 day%'
                OR je.NAME LIKE '%LCM New Member%')
    )
    ,

---CTE for latest checkin---
chkins as materialized (
SELECT
    chk.PERSON_CENTER,
    chk.PERSON_ID,
    TO_CHAR(longtodateTZ(MAX(chk.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS Last_Checkin
FROM CHECKINS chk
JOIN journal je ON chk.person_center = je.PERSON_CENTER AND chk.PERSON_ID = je.PERSON_ID
GROUP BY 
    1, 
    2 )
  
---Main SQL---
SELECT
    p.CENTER ||'p'|| p.ID AS PersonId,
    p.FULLNAME AS "Member Name",
    email.TXTVALUE AS Email,
    mobile.TXTVALUE AS Mobile,
    Home.TXTVALUE AS "Home tel",
    c.NAME AS Club,
    p.ZIPCODE AS PostCode,
    p.SEX AS Sex,
    pro.NAME AS Subscription_Name,
    (CASE p.status
        WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'UNKNOWN' END) 
     AS P_STATUS,
    je."Date Contact",
    je."Note Subject",
    je."Note Details",
    staff.FULLNAME AS Staff,
    chkins.Last_Checkin
FROM JOURNAL je
JOIN CHKINS                       ON chkins.PERSON_CENTER = je.PERSON_CENTER AND chkins.PERSON_ID = je.PERSON_ID
LEFT JOIN PERSONS p               ON p.ID = je.PERSON_ID AND p.CENTER = je.PERSON_CENTER
LEFT JOIN PERSON_EXT_ATTRS email  ON email.PERSONCENTER = je.PERSON_CENTER AND email.PERSONID = je.PERSON_ID AND email.name='_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS home   ON p.center=home.PERSONCENTER AND p.id=home.PERSONID AND home.name='_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS mobile ON p.center=mobile.PERSONCENTER AND p.id=mobile.PERSONID AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN CENTERS c               ON je.PERSON_CENTER = c.ID
LEFT JOIN EMPLOYEES staffLogin    ON staffLogin.ID = je.CREATORID AND staffLogin.CENTER = je.CREATORCENTER
LEFT JOIN PERSONS staff           ON staff.ID = staffLogin.PERSONID AND staff.CENTER = staffLogin.PERSONCENTER
LEFT JOIN SUBSCRIPTIONS s         ON s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID AND s.STATE IN (2,4,8)
LEFT JOIN PRODUCTS pro            ON pro.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND pro.ID = s.SUBSCRIPTIONTYPE_ID
  