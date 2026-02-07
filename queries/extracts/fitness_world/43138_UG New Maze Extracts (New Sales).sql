-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-3388
SELECT '1090' As SurveyID, p.CENTER||'p'||p.ID AS PersonID, p.FIRSTNAME, p.LASTNAME, email.TXTVALUE As EMail, c.CHECKIN_CENTER, TO_CHAR(exerpro.longtodate(c.CHECKIN_TIME), 'YYYY-MM-DD HH24:MI') AS CheckinTime, 
       s.CREATOR_CENTER AS Sales_Center, TO_CHAR(p.FIRST_ACTIVE_START_DATE, 'YYYY-MM-DD') AS First_Active_Start_Date, TO_CHAR(ss.TERMINATION_DATE, 'YYYY-MM-DD') AS Resigned_Date, s.END_DATE AS Membership_End_Date,
       p.Sex, floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12) AS "Age", DECODE(st.ST_TYPE, 0, 'Prepaid', 1, 'EFT', 3, 'Prospect') as Membership_Type

FROM 
(
  SELECT * FROM
        (SELECT RANK() over (PARTITION BY c2.person_center, c2.person_id ORDER BY c2.CHECKIN_TIME DESC) AS myRANK, c2.*
          FROM checkins c2
          WHERE exerpro.longtodate(c2.CHECKIN_TIME) > trunc(exerpsysdate()) - INTERVAL '1' DAY
        ) t
  WHERE t.MYRANK = 1) c
JOIN
  PERSONS p  
ON
   p.id = c.PERSON_ID AND p.center = c.PERSON_CENTER
JOIN
   SUBSCRIPTIONS s     
ON
   p.id = s.OWNER_ID AND p.center = s.OWNER_CENTER AND s.state = 2
JOIN
  SUBSCRIPTION_SALES ss
ON
   ss.SUBSCRIPTION_CENTER = s.CENTER AND ss.SUBSCRIPTION_ID = s.ID
JOIN
   SUBSCRIPTIONTYPES st
ON
   st.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN FW.PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'
JOIN FW.PERSON_EXT_ATTRS allow_email
ON
    allow_email.PERSONCENTER=p.center
    AND allow_email.PERSONID=p.id
    AND allow_email.name='_eClub_AllowedChannelEmail'
    AND allow_email.txtvalue = 'true'
WHERE 
  p.center in (:scope)
  AND p.status IN (1)
  AND p.FIRST_ACTIVE_START_DATE + INTERVAL '28' DAY >=  exerpro.longtodate(c.CHECKIN_TIME)
  AND TO_CHAR(exerpro.longtodate(c.CHECKIN_TIME), 'YYYY-MM-DD') =  TO_CHAR(exerpsysdate() - INTERVAL '1' DAY , 'YYYY-MM-DD')
  AND p.FIRST_ACTIVE_START_DATE < trunc(exerpsysdate()) - INTERVAL '1' DAY 
  AND p.PERSONTYPE <> 2 -- exclude staff