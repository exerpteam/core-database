-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-10619
 SELECT
    p.EXTERNAL_ID                AS "External_ID",
    p.FULLNAME                   AS "Name",
    CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type",
    CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription Status",
    pr.NAME                      AS "Subscription Name"
 FROM
     PAYMENT_AGREEMENTS pag
 JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.ACTIVE_AGR_CENTER = pag.center
     AND pac.ACTIVE_AGR_ID = pag.ID
         AND pac.ACTIVE_AGR_SUBID = pag.SUBID
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     pac.center = ar.center
     AND pac.ID = ar.ID
     AND ar.AR_TYPE = 4
 JOIN
     PERSONS p
 ON
     ar.CUSTOMERCENTER = p.CENTER
     AND ar.CUSTOMERID = p.ID
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.ID
     AND s.state in (2,8)
 JOIN
     PRODUCTS pr
 ON
     pr.center = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.ID = s.SUBSCRIPTIONTYPE_ID
 WHERE
     pag.PAYMENT_CYCLE_CONFIG_ID = 1401
     and pag.ENDED_DATE IS NULL
