SELECT
    p.center||'p'||p.id AS memberID,
    DECODE(pa.CENTER,NULL,null,'yes') AS "Has agreement"
FROM
    VA.PERSONS p
JOIN
    VA.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND s.STATE IN(2,4)
    AND s.SUBSCRIPTION_PRICE > 0
JOIN
    VA.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
    AND st.ST_TYPE=1
LEFT JOIN
    VA.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.CUSTOMERID =p.id
    AND ar.AR_TYPE = 4
LEFT JOIN
    VA.PAYMENT_ACCOUNTS pac
ON
    pac.center=ar.center
    AND pac.id =ar.id
LEFT JOIN
    VA.PAYMENT_AGREEMENTS pa
ON
    pac.ACTIVE_AGR_CENTER = pa.CENTER
    AND pa.id = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
WHERE
    floor(months_between(SYSDATE, p.BIRTHDATE) / 12) < 16
    AND p.STATUS IN (1,3)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            VA.RELATIVES r
        WHERE
            r.RELATIVECENTER = p.center
            AND r.RELATIVEID = p.id
            AND r.rtype = 12
            AND r.STATUS = 1)