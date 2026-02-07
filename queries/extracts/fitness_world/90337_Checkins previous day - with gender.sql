-- This is the version from 2026-02-05
--  
SELECT
c.CHECKIN_CENTER AS CenterID,
cen.NAME AS CenterNavn,
to_char(longtodate(c.checkin_time),'DD-MM-YYYY') AS Dato,
m.Male,
f.Female
FROM
fw.checkin_log c
JOIN
CENTERS cen
ON
c.CHECKIN_CENTER = cen.ID
JOIN
(SELECT c.CHECKIN_CENTER, COUNT() AS Male
FROM fw.checkin_log c
JOIN persons p
ON c.id = p.id
WHERE p.sex = 'M'
AND TO_CHAR(longtodate(c.checkin_time), 'dd-MM-YYYY') = TO_CHAR(current_date-1, 'dd-MM-YYYY')
AND c.CHECKIN_CENTER in (:scope)
GROUP BY c.CHECKIN_CENTER) m
ON c.CHECKIN_CENTER = m.CHECKIN_CENTER
JOIN
(SELECT c.CHECKIN_CENTER, COUNT() AS Female
FROM fw.checkin_log c
JOIN persons p
ON c.id = p.id
WHERE p.sex = 'F'
AND TO_CHAR(longtodate(c.checkin_time), 'dd-MM-YYYY') = TO_CHAR(current_date-1, 'dd-MM-YYYY')
AND c.CHECKIN_CENTER in (:scope)
GROUP BY c.CHECKIN_CENTER) f
ON c.CHECKIN_CENTER = f.CHECKIN_CENTER
GROUP BY
c.CHECKIN_CENTER,
cen.NAME,
to_char(longtodate(c.checkin_time),'DD-MM-YYYY'),
m.Male,
f.Female
ORDER BY
c.CHECKIN_CENTER



Regenerate resp