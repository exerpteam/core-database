-- This is the version from 2026-02-05
-- ST-13184
SELECT
    c.name                          AS center,
     pr.NAME                                                         AS MEMBERSHIP,
    p.CENTER||'p'||p.id as "Member Id", 
     -- s.CENTER||'ss'||s.id                                            AS subscriptionid,
    pr.PRICE AS product_price,
    s.SUBSCRIPTION_PRICE as "current price",
    sp.PRICE as "price in period",
    sp.FROM_DATE,
    sp.TO_DATE  
FROM
    SUBSCRIPTIONS s
JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
AND sp.SUBSCRIPTION_ID = s.id
JOIN
    centers c
ON
    s.center = c.id
JOIN
    products pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    persons p
ON
    s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.id
WHERE
    s.state IN (2,4)
AND s.CENTER IN (258,262,263,264,266,267,268,269,270,271)
order by
p.CENTER,
p.id, 
sp.FROM_DATE