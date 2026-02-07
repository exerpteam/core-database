

WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$company_name$$ AS company_name
    )
SELECT
c.name as center,
    p.center||'p'||p.id AS "Member ID",
    p.FULLNAME,
    comp.center||'p'||comp.id           AS "Company ID",
    comp.FULLNAME                       AS "Company Name",
    s.center||'ss'||s.id                AS "Subscription ID",
    pr.NAME                             AS "subscription",
    pr.PRICE                            AS "Normal price",
    s.SUBSCRIPTION_PRICE                AS "Current Price",
    TO_CHAR(sp2.FROM_DATE,'yyyy-MM-dd') AS "Price change date",
    sp2.PRICE                           AS "New price",
    ca.NAME                             AS "Company Agreement",
    rca.EXPIREDATE                      AS "Documentation expires"
FROM
    HP.PERSONS p
JOIN
    HP.PERSONS p2 --all the transferred members and the current member
ON
    p2.CURRENT_PERSON_CENTER = p.CENTER
    AND p2.CURRENT_PERSON_ID = p.ID
JOIN
    HP.RELATIVES r
ON
    r.RELATIVECENTER = p.CENTER
    AND r.RELATIVEID = p.id
    AND r.RTYPE = 2
LEFT JOIN
    HP.RELATIVES rca
ON
    rca.CENTER = p.CENTER
    AND rca.ID = p.id
    AND rca.RTYPE = 3
    AND rca.STATUS = 1
LEFT JOIN
    HP.COMPANYAGREEMENTS ca
ON
    ca.CENTER = rca.RELATIVECENTER
    AND ca.id = rca.RELATIVEID
    AND ca.SUBID = rca.RELATIVESUBID
JOIN
    HP.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p2.CENTER
    AND s.OWNER_ID = p2.id
    AND s.STATE IN (2,4)
JOIN
    HP.PRODUCTS pr
ON
    pr.CENTER =s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    HP.SUBSCRIPTION_PRICE sp2
ON
    (
        SP2.SUBSCRIPTION_CENTER = S.CENTER
        AND SP2.SUBSCRIPTION_ID = S.ID
        AND sp2.CANCELLED = 0
        AND sp2.FROM_DATE > CURRENT_DATE )
JOIN
    HP.PERSONS comp
ON
    comp.center = r.CENTER
    AND comp.id = r.id
JOIN
    HP.CENTERS c
ON
    c.ID = p.center
CROSS JOIN
    params
WHERE
    p.PERSONTYPE = 4
    AND p.STATUS IN (1,3)
    AND r.STATUS = 1
    AND p.center IN ($$scope$$)
    AND comp.fullname like
    CASE
        WHEN params.company_name != '**no_name**'
        THEN  '%'||params.company_name||'%'
        ELSE comp.fullname
    END

