SELECT
    SUM(total),
    COUNT( center) AS subscriptions,
    name,
    FIRSTNAME,
    LASTNAME,
    PersonType,
    pid,
    center || 'ss' || id sid,
    BINDING_END_DATE
FROM
    (
        SELECT
            SUM(invl.TOTAL_AMOUNT) total,
            COUNT(spp.CENTER),
            s.CENTER,
            s.ID,
            p.FIRSTNAME,
            p.LASTNAME,
            s.OWNER_CENTER || 'p' || s.OWNER_ID pid,
            prod.NAME,
            DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
            s.BINDING_END_DATE
        FROM
            SUBSCRIPTIONPERIODPARTS spp
        JOIN SPP_INVOICELINES_LINK link
        ON
            link.PERIOD_CENTER = spp.CENTER
            AND link.PERIOD_ID = spp.ID
            AND link.PERIOD_SUBID= spp.SUBID
        JOIN INVOICELINES invl
        ON
            invl.CENTER = link.INVOICELINE_CENTER
            AND invl.ID = link.INVOICELINE_ID
            AND invl.SUBID = link.INVOICELINE_SUBID
        JOIN SUBSCRIPTIONS s
        ON
            s.CENTER = spp.CENTER
            AND s.ID = spp.ID
        JOIN PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.id = s.OWNER_ID
        WHERE
            spp.FROM_DATE >= :fromDate
            AND spp.TO_DATE < :toDate + 1
            AND spp.SPP_STATE = 1
            AND s.center IN (:scope)
        GROUP BY
            s.CENTER,
            s.ID,
            s.OWNER_CENTER,
            s.OWNER_ID,
            p.FIRSTNAME,
            p.LASTNAME,
            prod.NAME,
            DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN'),
            s.BINDING_END_DATE
    )
GROUP BY
    pid,
    center,
    id,
    name,
    FIRSTNAME,
    LASTNAME,
    PersonType,
    BINDING_END_DATE
HAVING
    SUM(total) > 0