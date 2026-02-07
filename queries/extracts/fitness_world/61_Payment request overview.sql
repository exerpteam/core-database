-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-4042
SELECT
    ch.NAME,
    c.SHORTNAME AS "Club Name",
    cr.CREDITOR_NAME,
    COUNT(*)                                      antal,
    REPLACE('' || SUM(pr."REQ_AMOUNT"), '.', ',') total
FROM
    FW.PAYMENT_REQUESTS pr
JOIN
    FW."CLEARINGHOUSE_CREDITORS" cr
ON
    cr."CREDITOR_ID" = pr."CREDITOR_ID"
    AND cr.CLEARINGHOUSE = pr."CLEARINGHOUSE_ID"
JOIN
    FW."CLEARINGHOUSES" ch
ON
    ch.id = cr."CLEARINGHOUSE"
JOIN 
    Centers c
ON
    c.ID = pr.CENTER
WHERE
    pr.REQ_DATE = $$Request_date$$
    AND (($$Pr_state$$='Sent' AND pr.STATE=2) OR ($$Pr_state$$='More' AND pr.STATE IN (2,3,4,5,6,7,18)))

GROUP BY
    ch.NAME,
    c.SHORTNAME,
    cr.CREDITOR_NAME
ORDER BY
    cr.CREDITOR_NAME
    
