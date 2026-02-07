-- This is the version from 2026-02-05
--  
SELECT 
    c.PERSON_CENTER home_Center,
    hc.SHORTNAME home_Center_Name,
    c.CHECKIN_CENTER to_center,
    tc.SHORTNAME to_center_name,
    count(c.PERSON_CENTER)
FROM
    FW.CHECKINS c
join FW.CENTERS hc on hc.ID = c.PERSON_CENTER
join FW.CENTERS tc on tc.ID = c.CHECKIN_CENTER
WHERE
    c.CHECKIN_TIME BETWEEN :fromDate AND :toDate
GROUP BY
    c.PERSON_CENTER,
    c.CHECKIN_CENTER,
	hc.SHORTNAME,
	tc.SHORTNAME