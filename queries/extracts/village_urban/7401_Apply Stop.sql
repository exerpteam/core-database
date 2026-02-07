SELECT
    p.CENTER ||'p'|| p.ID as PersonId,
    p.FULLNAME                                                                     AS "Member Name",
    email.TXTVALUE                                                                 AS Email,
    mobile.TXTVALUE                                                                AS Mobile,
    Home.TXTVALUE                                                                  AS "Home tel",
    c.NAME                                                                         AS Club,
    p.ZIPCODE                                                                      AS PostCode,
    p.SEX                                                                          AS Sex,
    pro.NAME as Subscription_Name,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS P_STATUS,
    TO_CHAR(longtodateTZ(je.CREATION_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS
    "Date contact",
    je.NAME AS "Note Subject",
    UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(je.BIG_TEXT,2000,1))|| UTL_RAW.CAST_TO_VARCHAR2
    (dbms_lob.substr(je.BIG_TEXT,2000,2001)) AS "Note Details",
    staff.FULLNAME                           AS Staff,
    chkins.Last_Checkin                      AS "Last Attendance"
FROM
    VU.JOURNALENTRIES je
LEFT JOIN
    VU.PERSONS p
ON
    p.ID = je.PERSON_ID
    AND p.CENTER = je.PERSON_CENTER
LEFT JOIN
    VU.PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = je.PERSON_CENTER
    AND email.PERSONID = je.PERSON_ID
    AND email.name='_eClub_Email'
LEFT JOIN
    VU.PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    VU.PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    VU.CENTERS c
ON
    je.PERSON_CENTER = c.ID
JOIN
    VU.EMPLOYEES staffLogin
ON
    staffLogin.ID = je.CREATORID
    AND staffLogin.CENTER = je.CREATORCENTER
LEFT JOIN
    VU.PERSONS staff
ON
    staff.ID = staffLogin.PERSONID
    AND staff.CENTER = staffLogin.PERSONCENTER
LEFT JOIN
    (
        SELECT
            PERSON_CENTER,
            PERSON_ID,
            TO_CHAR(longtodateTZ(MAX(chk.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS
            Last_Checkin
        FROM
            VU.CHECKINS chk
        GROUP BY
            PERSON_CENTER,
            PERSON_ID ) chkins
ON
    chkins.PERSON_CENTER = je.PERSON_CENTER
    AND chkins.PERSON_ID = je.PERSON_ID
    
left join VU.SUBSCRIPTIONS s
 on s.OWNER_CENTER = p.CENTER
 and s.OWNER_ID = p.ID
 and s.STATE in (2,4,8)
 
left join VU.PRODUCTS pro
 on pro.CENTER = s.SUBSCRIPTIONTYPE_CENTER
 and pro.ID = s.SUBSCRIPTIONTYPE_ID    
    
WHERE
	je.CREATION_TIME BETWEEN $$Start_Date$$ AND ($$End_Date$$+(24*3600*1000)-1)
    AND je.PERSON_CENTER IN ($$Scope$$)
    AND (je.NAME LIKE '%Apply: Stop subscriptions%'
	OR je.NAME LIKE '%Apply: Stop subscriptions%')