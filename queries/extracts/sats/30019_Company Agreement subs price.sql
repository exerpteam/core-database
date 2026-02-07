SELECT DISTINCT
    comp.center||'p'||comp.id              AS "Company ID",
    comp.FULLNAME                          AS "Company |Name",
    ca.CENTER||'p'||ca.ID||'rpt'||ca.SUBID AS "Company agreement ID",
    ca.NAME                                AS "Company agreement name",
    s.SUBSCRIPTION_PRICE,
    SUM(DECODE(r.STATUS,1,1,0)) AS "Active Relations",
    SUM(DECODE(r.STATUS,1,0,1)) AS "Inactive Relations"
FROM
    SATS.COMPANYAGREEMENTS ca
JOIN
    SATS.RELATIVES r
ON
    r.RELATIVECENTER = ca.CENTER
    AND r.RELATIVEID = ca.ID
    AND r.RELATIVESUBID = ca.SUBID
    AND r.RTYPE = 3
JOIN
    SATS.PERSONS p
ON
    p.center = r.center
    AND p.id= r.id
left JOIN
    SATS.PERSONS comp
ON
    comp.CENTER = ca.CENTER
    AND comp.id = ca.id
JOIN
    SATS.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4)
WHERE
    p.center in ($$scope$$)
    AND p.PERSONTYPE = 4
GROUP BY
    comp.center,
    comp.id ,
    comp.FULLNAME ,
    ca.CENTER,
    ca.ID,
    ca.SUBID,
    ca.NAME,
    s.SUBSCRIPTION_PRICE