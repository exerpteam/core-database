-- This is the version from 2026-02-05
--  
SELECT
    p.fullname AS "Full Name",
    email.txtvalue AS "Email Address",
    COUNT(*) AS "Total Attendance Count"
FROM CHECKINS c
JOIN persons p
    ON p.center = c.person_center
   AND p.id = c.person_id
LEFT JOIN PERSON_EXT_ATTRS email 
    ON p.center = email.personcenter 
   AND p.id = email.personid 
   AND email.name = '_eClub_Email'
JOIN
    RELATIVES r
ON
    r.CENTER = p.center
AND r.id = p.id
AND r.RTYPE IN (3)
AND r.STATUS<3
JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = r.RELATIVECENTER
AND ca.ID = r.RELATIVEID
AND ca.SUBID = r.RELATIVESUBID
JOIN
    PERSONS comp
ON
    comp.center = ca.CENTER
AND comp.id=ca.ID
WHERE c.checkin_time >= EXTRACT(EPOCH FROM ($$CreationFrom$$::TIMESTAMP AT TIME ZONE 'Australia/Sydney')) * 1000
  AND c.checkin_time < (EXTRACT(EPOCH FROM $$CreationTo$$::TIMESTAMP AT TIME ZONE 'Australia/Sydney') * 1000 + 86400000)
  AND (comp.center, comp.id) IN (:companyid)
GROUP BY p.fullname, email.txtvalue
ORDER BY p.fullname;