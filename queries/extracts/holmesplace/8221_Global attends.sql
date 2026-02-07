SELECT
    att.BOOKING_RESOURCE_CENTER AS center,
    to_char(longtodate(att.START_TIME),'MONTH') as MONTH,
    COUNT(*)                    AS "attends"
FROM
    HP.SUBSCRIPTIONS s
JOIN
    HP.PRODUCTS pr
ON
    pr.center = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    HP.ATTENDS att
ON
    att.PERSON_CENTER = s.OWNER_CENTER
    AND att.PERSON_ID = s.OWNER_ID
WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            HP.ATTENDS att2
        WHERE
            att2.PERSON_CENTER = att.PERSON_CENTER
            AND att2.PERSON_ID = att.PERSON_ID
            AND att2.START_TIME BETWEEN att.START_TIME - 1000*60*60*3 AND att.START_TIME-1)
    AND att.BOOKING_RESOURCE_CENTER IN ($$scope$$)
    AND pr.GLOBALID IN ('GFM_12',
                        'GLOBAL_FULL_MONTHLY_24',
                        'GFA_12')
    AND att.START_TIME BETWEEN $$from_date$$ AND $$to_date$$
    AND s.STATE IN (2,4)
GROUP BY
    att.BOOKING_RESOURCE_CENTER,
    to_char(longtodate(att.START_TIME),'MONTH')