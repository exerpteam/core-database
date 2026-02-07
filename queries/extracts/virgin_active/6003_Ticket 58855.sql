SELECT
    sp2.SUBSCRIPTION_CENTER || 'ss' || sp2.SUBSCRIPTION_ID ssid,
    s2.OWNER_CENTER || 'p' || s2.OWNER_ID                  pid,
    'KEEP --> '                                            divider,
    sp2.FROM_DATE ,
    sp2.TO_DATE,
    sp2.PRICE,
    'KILL --> ' divider,
    sp3.FROM_DATE ,
    sp3.TO_DATE,
    sp3.PRICE
FROM
    SUBSCRIPTION_PRICE sp2
JOIN
    SUBSCRIPTIONS s2
ON
    s2.CENTER = sp2.SUBSCRIPTION_CENTER
    AND s2.ID = sp2.SUBSCRIPTION_ID
JOIN
    SUBSCRIPTION_PRICE sp3
ON
    sp3.SUBSCRIPTION_CENTER = sp2.SUBSCRIPTION_CENTER
    AND sp3.SUBSCRIPTION_ID = sp2.SUBSCRIPTION_ID
    AND sp3.COMENT = 'Aggregated price administration'
    AND sp3.ID != sp2.ID
    AND sp3.CANCELLED = 0
WHERE
    (sp2.COMENT = 'Aggregated price administration' or sp2.TYPE = 'CONVERSION')
    AND sp2.TO_DATE IS NOT NULL
    AND sp3.TO_DATE IS NULL
    AND (
        sp2.SUBSCRIPTION_CENTER,sp2.SUBSCRIPTION_ID) IN
    (
        SELECT
            s.CENTER,
            s.ID
            --            s.CENTER || 'ss' || s.id            ssid,
            --            s.OWNER_CENTER || 'p' || s.OWNER_ID pid,
            --            COUNT(s.CENTER)                     changes
        FROM
            SUBSCRIPTION_PRICE sp
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sp.SUBSCRIPTION_CENTER
            AND s.ID = sp.SUBSCRIPTION_ID
        WHERE
            --    s.OWNER_CENTER = 405
            --    AND s.OWNER_ID = 1167
            (sp.COMENT = 'Aggregated price administration' or sp.TYPE = 'CONVERSION')
            AND sp.CANCELLED = 0
            AND sp.FROM_DATE = $$check_date$$
            and s.CENTER in  ($$scope$$)
        GROUP BY
            s.CENTER ,
            s.id ,
            s.OWNER_CENTER ,
            s.OWNER_ID
        HAVING
            COUNT(s.CENTER) > 1 )
ORDER BY
    sp2.SUBSCRIPTION_CENTER ,
    sp2.SUBSCRIPTION_ID,
    sp2.FROM_DATE ASC
    
    
