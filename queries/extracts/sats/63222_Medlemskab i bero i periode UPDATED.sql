SELECT
    per.CENTER||'p'||per.id as MemberID,
    prod.NAME as Name,
    sub.START_DATE subStart,
    sub.END_DATE   subEnd,
    sub.BINDING_END_DATE,
    sub.BINDING_PRICE,
    sub.SUBSCRIPTION_PRICE,
    fr.START_DATE                      beroStart,
    fr.END_DATE                        beroSlut,
    ( fr.END_DATE - fr.START_DATE) +1 AS days
FROM
    subscriptions sub
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = sub.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
ON
    ppg.PRODUCT_CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND ppg.PRODUCT_ID = sub.SUBSCRIPTIONTYPE_ID
    AND ppg.PRODUCT_GROUP_ID=1
JOIN
    "PRODUCTS" prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID
JOIN
    persons per
ON
    sub."OWNER_CENTER" = per."CENTER"
    AND sub."OWNER_ID" = per."ID"
LEFT JOIN
    SUBSCRIPTION_FREEZE_PERIOD fr
ON
    fr.SUBSCRIPTION_CENTER = sub.center
    AND fr.SUBSCRIPTION_ID = sub.id
    AND fr.STATE <> 'CANCELLED'
WHERE
    st."ST_TYPE" = 1
    AND sub.state IN (1,2,3,4,5,6)
    AND sub.TRANSFERRED_CENTER IS NULL
    AND per.status <> 4
    AND sub."BINDING_PRICE" <> 0
    AND (
        fr.end_date >= :dateFrom_
        AND fr.start_date <= :dateTo_ )