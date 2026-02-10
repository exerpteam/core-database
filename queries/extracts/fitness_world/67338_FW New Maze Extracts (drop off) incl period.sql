-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT  
        '722' AS SurveyID,
        p.CENTER||'p'||p.ID AS PersonID, 
        p.FIRSTNAME, 
        p.LASTNAME, 
        email.TXTVALUE As EMail, 
        c.CHECKIN_CENTER, 
        TO_CHAR(exerpro.longtodate(c.CHECKIN_TIME), 'YYYY-MM-DD HH24:MI') AS CheckinTime, 
        s.CREATOR_CENTER AS Sales_Center, 
        TO_CHAR(p.FIRST_ACTIVE_START_DATE, 'YYYY-MM-DD') AS First_Active_Start_Date, 
        TO_CHAR(ss.TERMINATION_DATE, 'YYYY-MM-DD') AS Resigned_Date, 
        TO_CHAR(s.END_DATE, 'YYYY-MM-DD') AS Membership_End_Date,
        p.Sex, 
        floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12) AS "Age", 
        DECODE(st.ST_TYPE, 0, 'Prepaid', 1, 'EFT', 3, 'Prospect') as Membership_Type
FROM 
PERSONS p  
LEFT JOIN
(
  SELECT * FROM
        (SELECT RANK() over (PARTITION BY c2.person_center, c2.person_id ORDER BY c2.CHECKIN_TIME DESC) AS myRANK, c2.*
          FROM checkins c2
        ) t
  WHERE t.MYRANK = 1) c  
ON
   p.id = c.PERSON_ID AND p.center = c.PERSON_CENTER
JOIN
   SUBSCRIPTIONS s     
ON
   p.id = s.OWNER_ID AND p.center = s.OWNER_CENTER 
AND s.state in (2,3,4,7)
JOIN
  SUBSCRIPTION_SALES ss
ON
   ss.SUBSCRIPTION_CENTER = s.CENTER AND ss.SUBSCRIPTION_ID = s.ID
JOIN
   SUBSCRIPTIONTYPES st
ON
   st.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'
WHERE 
  p.center in (:Scope)
  AND p.status IN (1,2,3) 
  AND (ss.TERMINATION_DATE >= :from_date and ss.TERMINATION_DATE <= :to_date)
  AND s.END_DATE is not null
  AND p.PERSONTYPE <> 2 -- exclude staff