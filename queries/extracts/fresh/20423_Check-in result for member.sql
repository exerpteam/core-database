 select
 c.SHORTNAME AS CHECKIN_CENTER,
 longtodateC(ci.CHECKIN_TIME, ci.CHECKIN_CENTER) AS CHECKIN_TIME,
 longtodateC(ci.CHECKIN_TIME, ci.CHECKIN_CENTER) AS CHECKOUT_TIME,
 CASE ci.CHECKIN_RESULT  WHEN 0 THEN  'Unknown'  WHEN 1 THEN  'accessGranted'  WHEN 2 THEN  'presenceRegistered'  WHEN 3 THEN  'accessDenied' END as CHECKIN_RESULT
 from CHECKINS ci
 join CENTERS c on ci.CHECKIN_CENTER = c.ID
 where ci.PERSON_CENTER||'p'||ci.PERSON_ID = :personID
