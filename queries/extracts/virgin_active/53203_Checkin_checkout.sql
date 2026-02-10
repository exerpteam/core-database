-- The extract is extracted from Exerp on 2026-02-08
-- ingressi entrata e uscita soci
 SELECT
     p.EXTERNAL_ID,
     p.CENTER || 'p' || p.ID AS PERSON_ID,
         p.FULLNAME,
     to_char(longToDateC(cin.CHECKIN_TIME,p.center),'YYYY-MM-dd HH24:MI') "CheckIn",
         to_char(longToDateC(cin.CHECKOUT_TIME,p.center),'YYYY-MM-dd HH24:MI') "CheckOut"
 FROM
     PERSONS p
 JOIN CHECKINS cin
 ON
     cin.PERSON_CENTER = p.CENTER
     AND cin.PERSON_ID = p.ID
 where  cin.PERSON_CENTER IN ($$Scope$$)
     AND cin.CHECKIN_TIME BETWEEN $$FromDate$$ AND $$ToDate$$
         AND p.country = 'IT'
