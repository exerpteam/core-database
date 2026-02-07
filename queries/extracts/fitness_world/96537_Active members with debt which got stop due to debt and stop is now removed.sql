-- This is the version from 2026-02-05
-- EC-7405
SELECT DISTINCT
    sc.old_subscription_center ||'ss'||sc.old_subscription_id AS "subID",
    sbp.type,
    TO_CHAR(longtodateTZ(sbp.entry_time, 'Europe/Copenhagen'),'YYYY-MM-DD ') AS "block_date",
    sc.type,
    TO_CHAR(longtodateTZ(sc.cancel_time, 'Europe/Copenhagen'),'YYYY-MM-DD ') AS "cancelstop_date"
FROM
    subscription_change sc
JOIN
    subscriptions s
ON
    sc.old_subscription_center = s.center
AND sc.old_subscription_id = s.id
JOIN
    subscription_blocked_period sbp
ON
    sbp.subscription_center = s.center
AND sbp.subscription_id = s.id
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    s.owner_center = ar.customercenter
AND s.owner_id = ar.customerid
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
AND art.ID = ar.ID
WHERE
    sc.type = 'END_DATE'
AND art.STATUS IN ('OPEN',
                   'NEW')
AND s.state = 2 -->ACTIVE<--
AND s.end_date IS NULL
AND sc.cancel_time IS NOT NULL
AND sbp.type = 'DEBT_COLLECTION'
AND art.due_date <= add_months(CURRENT_DATE, -3) 
AND sbp.entry_time < sc.cancel_time 