-- This is the version from 2026-02-05
--  
SELECT DISTINCT ON (bk.center, bk.id)
     c.id AS "ClubID",
     c.SHORTNAME AS "Held At",
     per.Center || 'p' || per.id AS "Membership Number",
     per.firstname AS "Member First Name",
     ins.FULLNAME AS "Trainer",
     CASE
         WHEN mpr.CACHED_PRODUCTNAME IN ('PT - Kickstart Promo', 'PT - Staff', 'PT (No Level)', 'PT - Full Throttle Promo', 'Coaching Level 1', 'Coaching Level 0', 'PT - Promo Nov 2025') THEN 'PT Level 1'
		WHEN act.Name = 'Meeting' then 'PT Level 1'
		WHEN mpr.CACHED_PRODUCTNAME IN('Coaching Level 2','Coaching Level 2 Top Up') THEN 'PT Level 2'
WHEN mpr.CACHED_PRODUCTNAME IN ('Coaching Level 3','Coaching Level 3 Top Up') THEN 'PT Level 3'
WHEN mpr.CACHED_PRODUCTNAME IN('Coaching Level 4','Coaching Level 4 Top Up') THEN 'PT Level 4'
         ELSE act.NAME
     END AS "Activity Name",
CASE WHEN act.Name = 'Meeting' then 'Meeting'
ELSE
     mpr.CACHED_PRODUCTNAME END AS "Clip Card Used",
     CASE 
         WHEN par.STATE = 'PARTICIPATION' THEN 'Yes'
         WHEN par.STATE = 'CANCELLED' THEN 'No'
         ELSE par.STATE 
     END AS "Attended",
     longtodateC(bk.STARTTIME, bk.center) AS "Date of PT Session",
     TO_CHAR(longtodateC(bk.STARTTIME, bk.center), 'HH24:MI') AS "Start Time",
ROUND(EXTRACT(EPOCH FROM (longtodateC(bk.STOPTIME, bk.center) - longtodateC(bk.STARTTIME, bk.center))) / 60) AS "Session Length",
     bk.center || 'bk' || bk.ID AS "Booking ID",
     ins.Center || 'p' || ins.id AS "Exerp Staff ID",
     CAST(staffID.txtvalue AS INTEGER) AS "Trainer ID",
	CASE
		WHEN act.Name IN ('Wellness Consult') then '0'
		ELSE sales.product_normal_price
    END AS "PT Revenue",
CASE
		WHEN act.Name IN ('Wellness Consult') then '0'
		ELSE sales.total_amount
    END AS "Total Amount" 
FROM BOOKINGS bk
JOIN CENTERS c ON c.id = bk.CENTER
JOIN ACTIVITY act ON bk.ACTIVITY = act.ID
JOIN ACTIVITY_GROUP actgr ON act.ACTIVITY_GROUP_ID = actgr.ID
JOIN ACTIVITY_STAFF_CONFIGURATIONS staffconfig ON staffconfig.ACTIVITY_ID = act.ID
JOIN STAFF_GROUPS stfg ON stfg.ID = staffconfig.STAFF_GROUP_ID
LEFT JOIN PARTICIPATIONS par ON par.BOOKING_CENTER = bk.CENTER AND par.BOOKING_ID = bk.ID
LEFT JOIN STAFF_USAGE st ON bk.center = st.BOOKING_CENTER AND bk.id = st.BOOKING_ID
LEFT JOIN PERSONS ins ON st.PERSON_CENTER = ins.CENTER AND st.PERSON_ID = ins.ID
JOIN PERSONS per ON par.PARTICIPANT_CENTER = per.CENTER AND par.PARTICIPANT_ID = per.ID
LEFT JOIN PERSON_EXT_Attrs ptlvl ON ins.center = ptlvl.Personcenter AND ins.id = ptlvl.PERSONID AND ptlvl.name = 'PTLevel'
LEFT JOIN PERSON_EXT_Attrs staffID ON ins.center = staffID.Personcenter AND ins.id = staffID.PERSONID AND staffID.name = '_eClub_StaffExternalId'
LEFT JOIN PERSON_STAFF_GROUPS psg ON psg.PERSON_CENTER = ins.CENTER AND psg.PERSON_ID = ins.ID AND psg.STAFF_GROUP_ID = stfg.ID AND psg.SCOPE_TYPE = 'C' AND psg.SCOPE_ID = bk.CENTER
LEFT JOIN PERSONS su_p ON su_p.CENTER = par.SHOWUP_BY_CENTER AND su_p.ID = par.SHOWUP_BY_ID
LEFT JOIN PRIVILEGE_USAGES pu ON pu.TARGET_SERVICE IN ('Participation') AND pu.TARGET_CENTER = par.CENTER AND pu.TARGET_ID = par.ID
LEFT JOIN PRIVILEGE_GRANTS pg ON pg.ID = pu.GRANT_ID
LEFT JOIN MASTERPRODUCTREGISTER mpr ON mpr.ID = pg.GRANTER_ID AND pg.GRANTER_SERVICE IN ('GlobalCard','GlobalSubscription','Addon')
LEFT JOIN CHECKINS cin ON cin.PERSON_CENTER = per.CENTER AND cin.PERSON_ID = per.ID AND cin.CHECKIN_CENTER = par.CENTER AND cin.CHECKIN_TIME <= par.SHOWUP_TIME AND cin.CARD_CHECKED_IN IS NOT NULL

-- Deduplicated invoice lines subquery with ROW_NUMBER
LEFT JOIN (
    SELECT *
    FROM (
        SELECT
            sales.*,
            inv.trans_time,
            ROW_NUMBER() OVER (
                PARTITION BY sales.PERSON_CENTER, sales.PERSON_ID, sales.PRODUCTID, inv.trans_time
                ORDER BY sales.product_normal_price DESC NULLS LAST
            ) AS rn
        FROM INVOICE_LINES_MT sales
        LEFT JOIN PRODUCTS prod ON prod.CENTER = sales.PRODUCTCENTER AND prod.ID = sales.PRODUCTID
        LEFT JOIN INVOICES inv ON inv.CENTER = sales.CENTER AND inv.ID = sales.ID
        WHERE
            (sales.text ILIKE '%PT by DD%' OR sales.text ILIKE '%Coaching%' OR sales.text ILIKE '%PT%')
            AND sales.text NOT ILIKE '%Creation PT by DD%'
            AND sales.text NOT ILIKE '%Creation Coaching%'
            AND TO_CHAR(longtodateC(inv.trans_time, sales.CENTER), 'YYYY-MM-DD') > '2025-07-16'
    ) filtered_sales
    WHERE rn = 1
) sales ON sales.PERSON_CENTER = per.CENTER AND sales.PERSON_ID = per.ID

WHERE
    actgr.NAME IN ('Personal Training','Group Personal Training', 'Coaching','Group PT')
    AND bk.center IN (:scope)
    AND bk.STARTTIME >= (EXTRACT(EPOCH FROM ((date_trunc('day', CURRENT_DATE) - INTERVAL '15 days') AT TIME ZONE 'Australia/Sydney')) * 1000)::bigint
    AND st.STATE = 'ACTIVE'
    AND bk.STARTTIME < (EXTRACT(EPOCH FROM ((date_trunc('day', CURRENT_DATE) - INTERVAL '0 day') AT TIME ZONE 'Australia/Sydney')) * 1000)::bigint
    AND act.NAME NOT IN ('Admin')

ORDER BY bk.center, bk.id, sales.product_normal_price DESC NULLS LAST;