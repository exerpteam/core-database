-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.name                          AS center,
    s.OWNER_CENTER||'p'||s.OWNER_ID AS memberid,
    DECODE ( PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,
    'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS persontype,
    s.CENTER||'ss'||s.id                                            AS subscriptionid,
    pr.NAME                                                         AS MEMBERSHIP,
    s.INDIVIDUAL_PRICE,
    s.IS_PRICE_UPDATE_EXCLUDED,
    s.BINDING_END_DATE,
    s.BINDING_PRICE,
    s.SUBSCRIPTION_PRICE,
    pr.PRICE AS product_price
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
AND (
        s.END_DATE IS NULL
    OR  s.END_DATE > $$stopdate_later_than$$)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SUBSCRIPTION_PRICE sp2
        WHERE
            sp.ID = sp2.id
        AND sp2.ENTRY_TIME > $$from_date$$
        AND sp2.ENTRY_TIME < $$to_date$$ )
AND s.CENTER IN ($$scope$$)