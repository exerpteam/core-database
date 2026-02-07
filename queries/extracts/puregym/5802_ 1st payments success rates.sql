SELECT DISTINCT
    c.NAME,
    TO_CHAR(SUM(
        CASE
            WHEN pr.STATE IN (3,4)
            THEN 1
            WHEN rep.STATE IN (3,4)
            THEN 1
            ELSE 0
        END) * 100 / COUNT(s.center||'ss'||s.id), 'FM999.00')|| ' %' AS "SUCCEDED"
FROM
    PUREGYM.SUBSCRIPTIONS s
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES ar
ON
    s.OWNER_CENTER = ar.CUSTOMERCENTER
    AND s.OWNER_ID = ar.CUSTOMERID
    --find the first payment request after the creation of the
JOIN
    (
        SELECT
            pr2.CENTER,
            pr2.ID,
            s2.CENTER      s_CENTER,
            s2.id          s_ID,
            MIN(pr2.SUBID) SUBID
        FROM
            PUREGYM.SUBSCRIPTIONS s2
        JOIN
            PUREGYM.SUBSCRIPTIONTYPES st
        ON
            s2.SUBSCRIPTIONTYPE_CENTER = st.CENTER
            AND s2.SUBSCRIPTIONTYPE_ID = st.ID
            AND st.ST_TYPE = 1
        JOIN
            PUREGYM.ACCOUNT_RECEIVABLES ar2
        ON
            s2.OWNER_CENTER = ar2.CUSTOMERCENTER
            AND s2.OWNER_ID = ar2.CUSTOMERID
        JOIN
            PUREGYM.PAYMENT_REQUESTS pr2
        ON
            pr2.CENTER = ar2.CENTER
            AND pr2.ID = ar2.ID
        WHERE
            pr2.REQ_DATE > longtodate(s2.CREATION_TIME)
        GROUP BY
            pr2.CENTER,
            pr2.ID,
            s2.CENTER,
            s2.id) FirstPR
ON
    FirstPR.center = ar.CENTER
    AND FirstPR.ID = ar.ID
JOIN
    PUREGYM.PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
    AND pr.ID = ar.ID
    AND pr.SUBID = FirstPR.SUBID
LEFT JOIN
    PUREGYM.PAYMENT_REQUESTS rep
ON
    rep.INV_COLL_CENTER = pr.INV_COLL_CENTER
    AND rep.INV_COLL_ID = pr.INV_COLL_ID
    AND rep.INV_COLL_SUBID = pr.INV_COLL_SUBID
    AND rep.SUBID!=pr.SUBID
    AND rep.REQUEST_TYPE = 6
JOIN
    PUREGYM.CENTERS c
ON
    pr.CENTER = c.id
WHERE
    s.OWNER_CENTER IN ($$scope$$)
    AND pr.REQ_DATE BETWEEN $$from_date$$ AND $$end_date$$
GROUP BY
    c.name
ORDER BY
    c.name