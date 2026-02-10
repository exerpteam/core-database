-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    S.CENTER,
    S.ID,
    (CASE s.STATE
        WHEN 2 THEN 'Active'
        WHEN 3 THEN 'Ended'
        WHEN 4 THEN 'Frozen'
        WHEN 7 THEN 'Window'
        WHEN 8 THEN 'Created'
        ELSE 'Unknown'
    END) AS STATE,
    (CASE s.SUB_STATE
        WHEN 1 THEN 'None'
        WHEN 6 THEN 'Transferred'
        WHEN 9 THEN 'Blocked'
        ELSE 'Unknown'
    END) AS SUB_STATE,
    S.SUBSCRIPTIONTYPE_CENTER,
    S.BINDING_END_DATE,
    S.SUBSCRIPTION_PRICE,
    S.START_DATE,
    S.END_DATE,
    S.TRANSFERRED_CENTER,
    PR.NAME
FROM
    SUBSCRIPTIONS S
LEFT JOIN
    PERSONS P
ON
    P.CENTER = S.OWNER_CENTER
AND P.ID = S.OWNER_ID
LEFT JOIN
    PRODUCTS PR
ON
    PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER
AND PR.ID = S.SUBSCRIPTIONTYPE_ID
WHERE
    P.CENTER IN (205,204,207,206,201,203,202,220,221,222,223,216,217,218,219,212,213,214,215,208,
                 209,210,211,102,103,100,101,108,106,107,225,104,224,105)
AND S.END_DATE >= :End_Date_From
AND S.END_DATE <= :End_Date_To
AND P.STATUS IN ( :PersonStatus )
AND S.STATE IN ( :Subscription_state )
AND p.center IN ($$scope$$)
