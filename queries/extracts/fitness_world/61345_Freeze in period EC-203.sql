-- This is the version from 2026-02-05
-- EC-203
SELECT
    per.CENTER||'p'||per.id as MemberID,
	per.external_id,
	per.id,
    sub.START_DATE subStart,
    sub.END_DATE   subEnd,
    sub.BINDING_END_DATE,
    sub.BINDING_PRICE,
    sub.SUBSCRIPTION_PRICE,
	fr.text,
    fr.START_DATE                      beroStart,
    fr.END_DATE                        beroSlut,
    ( fr.END_DATE - fr.START_DATE) +1 AS days
FROM
    subscriptions sub
JOIN
    persons per
ON
    sub.OWNER_CENTER = per.CENTER
    AND sub.OWNER_ID = per.ID
LEFT JOIN
    SUBSCRIPTION_FREEZE_PERIOD fr
ON
    fr.SUBSCRIPTION_CENTER = sub.center
    AND fr.SUBSCRIPTION_ID = sub.id
    AND fr.STATE != 'CANCELLED'
WHERE
  --  st.ST_TYPE = 1
   sub.state IN (1,2,3,4,5,6)
   AND sub.TRANSFERRED_CENTER IS NULL
   AND per.status != 4
    --AND sub."BINDING_PRICE" <> 0
  AND (
        fr.end_date >= :dateFrom_
        AND fr.end_date <= :dateTo_ )

  
