SELECT
   b.NAME,  c.SHORTNAME as Club, p.FULLNAME AS Nominativo,CONCAT(CONCAT(cast(p.CENTER as INT), 'p'), cast(p.ID as int)) as personId, longToDate(B.STARTTIME) as dataPrenotazione FROM bookings b
INNER JOIN Centers c
ON c.ID = B.OWNER_CENTER
INNER JOIN PERSONS p
ON p.ID = B.OWNER_ID and p.CENTER = b.OWNER_CENTER
where longToDate(B.STARTTIME) BETWEEN CAST($$startDate$$ AS DATE) AND CAST($$enddate$$ AS DATE) + interval '1' day AND c.COUNTRY = 'IT' AND b.NAME = 'Check & Go'
ORDER BY  c.SHORTNAME, longToDate(B.STARTTIME), p.FULLNAME