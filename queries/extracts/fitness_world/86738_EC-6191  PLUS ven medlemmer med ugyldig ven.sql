-- This is the version from 2026-02-05
--  
SELECT DISTINCT
        p.fullname AS MemberName,
        p.center ||'p'|| p.id AS PersonId,
        p.EXTERNAL_ID AS ExternalId,
        pr.name AS SubscriptionName
FROM
    FW.SUBSCRIPTIONS s
JOIN
    FW.PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
JOIN
    FW.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    FW.PRODUCTS pr
ON
    pr.center = st.CENTER
AND pr.id= st.ID
LEFT JOIN
    FW.RELATIVES rel
ON
    rel.center = s.OWNER_CENTER
AND rel.id = s.OWNER_ID
AND rel.RTYPE = 4
LEFT JOIN
    FW.SUBSCRIPTIONS s2
ON
    s2.OWNER_CENTER = rel.RELATIVECENTER
AND s2.OWNER_ID = rel.RELATIVEID
AND s2.STATE != 2
LEFT JOIN
    FW.PRODUCTS pr2
ON
    pr2.center = s2.SUBSCRIPTIONTYPE_CENTER
AND pr2.id= s2.SUBSCRIPTIONTYPE_ID
WHERE
    pr.GLOBALID = 'PLUS_FRIEND'
AND s.STATE = 2
AND NOT EXISTS
    (
        SELECT
            s3.OWNER_CENTER,
            s3.OWNER_ID ,
            pr3.NAME AS "subscription name"
        FROM
            FW.SUBSCRIPTIONS s3
        JOIN
            FW.PRODUCTS pr3
        ON
            pr3.center = s3.SUBSCRIPTIONTYPE_CENTER
        AND pr3.id = s3.SUBSCRIPTIONTYPE_ID
        JOIN
            FW.RELATIVES rel1
        ON
            rel1.center = s3.OWNER_CENTER
        AND rel1.id = s3.OWNER_ID
        AND rel1.RTYPE = 4
        AND rel1.STATUS = 1
        JOIN
            FW.SUBSCRIPTIONS s4
        ON
            s4.OWNER_CENTER = rel1.RELATIVECENTER
        AND s4.OWNER_ID = rel1.RELATIVEID
        AND s4.STATE = 2
        JOIN
            FW.PRODUCTS pr4
        ON
            pr4.center = s4.SUBSCRIPTIONTYPE_CENTER
        AND pr4.id= s4.SUBSCRIPTIONTYPE_ID
        WHERE
            pr4.GLOBALID LIKE 'PLUS%'
        AND pr4.GLOBALID != 'PLUS_FRIEND'
        AND pr3.GLOBALID = 'PLUS_FRIEND'
        AND s3.STATE = 2
        AND s3.OWNER_CENTER = s.OWNER_CENTER
        AND s3.OWNER_ID = s.OWNER_ID)