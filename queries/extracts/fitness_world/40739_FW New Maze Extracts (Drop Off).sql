-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-2853
https://clublead.atlassian.net/browse/ST-3388
https://clublead.atlassian.net/browse/ST-3374
SELECT  
        '722' AS SurveyID,
        p.CENTER||'p'||p.ID AS PersonID, 
        p.FIRSTNAME, 
        p.LASTNAME, 
        email.TXTVALUE As EMail, 
        c.CHECKIN_CENTER, 
        TO_CHAR(longtodate(c.CHECKIN_TIME), 'YYYY-MM-DD HH24:MI') AS CheckinTime, 
        s.CREATOR_CENTER AS Sales_Center, 
        TO_CHAR(p.FIRST_ACTIVE_START_DATE, 'YYYY-MM-DD') AS First_Active_Start_Date, 
        TO_CHAR(ss.TERMINATION_DATE, 'YYYY-MM-DD') AS Resigned_Date, 
        TO_CHAR(s.END_DATE, 'YYYY-MM-DD') AS Membership_End_Date,
        p.Sex, 
        floor(months_between(current_timestamp, p.BIRTHDATE) / 12) AS "Age", 
        CASE st.ST_TYPE  WHEN 0 THEN  'Prepaid'  WHEN 1 THEN  'EFT'  WHEN 3 THEN  'Prospect' END as Membership_Type
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
   p.id = s.OWNER_ID AND p.center = s.OWNER_CENTER AND s.state in (2,4)
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
and p.center not in (131, 198, 202, 242, 270, 271, 169, 181)
	AND p.status IN (1,3) 
  AND TO_CHAR(ss.TERMINATION_DATE, 'YYYY-MM-DD') = TO_CHAR(current_timestamp - INTERVAL '1' DAY , 'YYYY-MM-DD')   
  AND s.END_DATE is not null
  AND p.PERSONTYPE <> 2 -- exclude staff
