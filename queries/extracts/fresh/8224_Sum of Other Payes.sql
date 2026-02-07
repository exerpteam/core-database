SELECT
    COUNT(po.CENTER),
    CASE
        WHEN rel.RELATIVECENTER IS NOT NULL
        THEN 'true'
        ELSE 'false'
    END AS "Other payer",
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'ERROR') type
FROM
    PERSONS po
LEFT JOIN RELATIVES rel
ON
    rel.RTYPE = 12
    AND rel.RELATIVECENTER = po.CENTER
    AND rel.RELATIVEID = po.ID
    AND rel.STATUS = 1
LEFT JOIN SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = po.CENTER
    AND s.OWNER_ID = po.ID
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
WHERE
    po.STATUS = 1
    AND po.center IN
    (
        SELECT
            ac.CENTER
        FROM
            AREA_CENTERS ac
        WHERE
            ac.AREA = 3
    )
    AND
    (
        po.CENTER,po.id
    )
    NOT IN
    (
        SELECT
            p.CENTER,
            p.ID
        FROM
            PERSONS p
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
        JOIN PAYMENT_ACCOUNTS pa
        ON
            pa.CENTER = ar.CENTER
            AND pa.ID = ar.ID
        JOIN PAYMENT_AGREEMENTS pagr
        ON
            pagr.CENTER = pa.ACTIVE_AGR_CENTER
            AND pagr.ID = pa.ACTIVE_AGR_ID
            AND pagr.SUBID = pa.ACTIVE_AGR_SUBID
        JOIN CLEARINGHOUSES ch
        ON
            ch.ID = pagr.CLEARINGHOUSE
        WHERE
            p.STATUS IN (1)
            AND p.center IN
            (
                SELECT
                    ac.CENTER
                FROM
                    AREA_CENTERS ac
                WHERE
                    ac.AREA = 3
            )
            AND pagr.CREATION_TIME BETWEEN :start_time AND :end_time
            AND ar.AR_TYPE = 4
    )
GROUP BY
    CASE
        WHEN rel.RELATIVECENTER IS NOT NULL
        THEN 'true'
        ELSE 'false'
    END ,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'ERROR')