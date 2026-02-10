-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    p.EXTERNAL_ID                                  AS "External ref",
    CASE c.IDENTITY_METHOD  WHEN 1 THEN 'BARCODE'  WHEN 2 THEN  'MAGNETIC_CARD'  WHEN 3 THEN  'SSN'  WHEN 4 THEN  'Fob'  WHEN 5 THEN  'PIN'  WHEN 7 THEN  'QR'  ELSE 'Undefined' END   AS "PIN/QR flag",
    TO_CHAR(longtodateC(c.CHECKIN_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')   AS "Checkin Time",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME,c.CHECKIN_CENTER),'DD/MM/YY HH24:MI:SS')   AS "Checkout Time",
c.CHECKIN_CENTER as "Checkin center",
CASE p.persontype WHEN 0 THEN 'Private' WHEN 1 THEN 'Student' WHEN 2 THEN 'Staff' WHEN 3 THEN 'Friend' WHEN 4 THEN 'Corporate' WHEN 5 THEN 'Onemancorporate' WHEN 6 THEN 'Family' WHEN 7 THEN 'Senior' WHEN 8 THEN 'Guest' WHEN 9 THEN 'Child' WHEN 10 THEN 'External_Staff' ELSE 'Undefined' END AS PersonType
FROM 
    checkins c
JOIN
    PERSONS p
ON 
    c.PERSON_CENTER = p.CENTER
    AND c.PERSON_ID = p.ID
WHERE 
    c.CHECKIN_TIME >= :From_Date
    AND c.CHECKIN_TIME < :From_To + 24*3600*1000
    AND c.CHECKIN_CENTER in (:Centers)