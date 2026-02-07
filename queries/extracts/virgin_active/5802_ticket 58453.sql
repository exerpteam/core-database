SELECT
    *
FROM
    PERSONS p
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4)
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
WHERE
    p.CENTER IN (247,431,444)
    --AND p.id = 2103
    AND EXISTS
    (
        SELECT
            1
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl2
        WHERE
            ppgl2.PRODUCT_CENTER = pr.CENTER
            AND ppgl2.PRODUCT_ID = pr.ID
            AND ppgl2.PRODUCT_GROUP_ID IN(247,
                                          277 ))