select 

c.SHORTNAME AS CHECKIN_CENTER,
longtodateC(ci.CHECKIN_TIME, ci.CHECKIN_CENTER) AS CHECKIN_TIME,
longtodateC(ci.CHECKIN_TIME, ci.CHECKIN_CENTER) AS CHECKOUT_TIME,
DECODE(ci.CHECKIN_RESULT, 0, 'Unknown', 1, 'accessGranted', 2, 'presenceRegistered', 3, 'accessDenied') as CHECKIN_RESULT

from CHECKINS ci

join CENTERS c on ci.CHECKIN_CENTER = c.ID 

where ci.PERSON_CENTER||'p'||ci.PERSON_ID = :personID