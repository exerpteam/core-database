SELECT
    ca.center                            AS companycenter,
    ca.id                                AS companyid,
    ca.subid                             AS agreementid,
    c.lastname                           AS company ,
    ca.name                              AS agreement,
    mc.lastname                          AS mothercompany,
    mc.center                            AS mccenter,
    mc.id                                AS mcid,
    key.firstname || ' ' || key.lastname AS employeeName,
    (
        SELECT
            COUNT(*)
        FROM
            /*company agreement relation*/
            RELATIVES rel ,
            /* persons under agreement*/
            PERSONS p ,
            subscriptions s
        WHERE
            rel.RELATIVECENTER = ca.CENTER
            AND rel.RELATIVEID = ca.ID
            AND rel.RELATIVESUBID = ca.SUBID
            AND rel.RTYPE = 3
            AND rel.CENTER = p.CENTER
            AND rel.ID = p.ID
            AND rel.RTYPE = 3
            AND s.OWNER_CENTER = rel.CENTER
            AND s.OWNER_ID = rel.ID
            AND s.start_date < :fromDate
            AND
            (
                s.end_date > :fromDate
                OR s.end_date IS NULL
            )
    ) AS MembersBeginning ,
    (
        SELECT
            COUNT(*)
        FROM
            /*company agreement relation*/
            RELATIVES rel ,
            /* persons under agreement*/
            PERSONS p ,
            subscriptions s
        WHERE
            rel.RELATIVECENTER = ca.CENTER
            AND rel.RELATIVEID = ca.ID
            AND rel.RELATIVESUBID = ca.SUBID
            AND rel.RTYPE = 3
            AND rel.CENTER = p.CENTER
            AND rel.ID = p.ID
            AND rel.RTYPE = 3
            AND s.OWNER_CENTER = rel.CENTER
            AND s.OWNER_ID = rel.ID
            AND s.start_date >= :fromDate
            AND s.start_date <= :toDate
    ) AS memberStarted ,
    (
        SELECT
            COUNT(*)
        FROM
            /*company agreement relation*/
            RELATIVES rel ,
            /* persons under agreement*/
            PERSONS p ,
            subscriptions s
        WHERE
            rel.RELATIVECENTER = ca.CENTER
            AND rel.RELATIVEID = ca.ID
            AND rel.RELATIVESUBID = ca.SUBID
            AND rel.RTYPE = 3
            AND rel.CENTER = p.CENTER
            AND rel.ID = p.ID
            AND rel.RTYPE = 3
            AND s.OWNER_CENTER = rel.CENTER
            AND s.OWNER_ID = rel.ID
            AND s.end_date >= :fromDate
            AND s.end_date <= :toDate
    ) AS memberStopped
FROM
    COMPANYAGREEMENTS ca
    /* company */
JOIN PERSONS c
ON
    ca.CENTER = c.CENTER
    AND ca.ID = c.ID
    /* mother company */
LEFT JOIN RELATIVES relc
ON
    relc.RELATIVECENTER = c.CENTER
    AND relc.RELATIVEID = c.ID
    AND relc.RTYPE = 6
LEFT JOIN PERSONS mc
ON
    relc.CENTER = mc.CENTER
    AND relc.ID = mc.ID
    AND relc.RTYPE = 6
    /* key account manager */
LEFT JOIN RELATIVES relkey
ON
    relkey.CENTER = c.CENTER
    AND relkey.ID = c.ID
    AND relkey.RTYPE = 10
LEFT JOIN PERSONS KEY
ON
    relkey.RELATIVECENTER = key.CENTER
    AND relkey.RELATIVEID = key.ID
    AND relkey.RTYPE = 10
WHERE
    ca.CENTER BETWEEN :FromCenter AND :ToCenter
ORDER BY
    ca.center,
    ca.id,
    ca.subid