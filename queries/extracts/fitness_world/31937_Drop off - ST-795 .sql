-- This is the version from 2026-02-05
-- ST-795
SELECT
    p.CENTER || 'p' || p.ID pid,
    p.SEX,
    floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12) AGE,
    p.ZIPCODE                                        POSTAL_CODE,
    prod.NAME                                        SUBSCRIPTION,
    CASE
        WHEN COUNT(DISTINCT sfp.ID) > 0
        THEN 1
        ELSE 0
    END                   AS FREEZE,
    COUNT(DISTINCT ci.ID)    checkins
FROM
    SUBSCRIPTIONS s
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
LEFT JOIN
    SUBSCRIPTION_FREEZE_PERIOD sfp
ON
    sfp.SUBSCRIPTION_CENTER = s.CENTER
    AND sfp.SUBSCRIPTION_ID = s.ID
    AND sfp.START_DATE > exerpsysdate()
    AND sfp.END_DATE = s.END_DATE
    AND sfp.STATE = 'ACTIVE'
LEFT JOIN
    CHECKINS ci
ON
    ci.PERSON_CENTER = s.OWNER_CENTER
    AND ci.PERSON_ID = s.OWNER_ID
    AND ci.CHECKIN_TIME > dateToLong(TO_CHAR(ADD_MONTHS(exerpsysdate(),-3), 'YYYY-MM-dd HH24:MI'))
WHERE
    s.END_DATE IS NOT NULL
    AND s.END_DATE BETWEEN $$from_date$$ AND $$to_date$$
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SUBSCRIPTIONS s2
        WHERE
            s2.OWNER_CENTER = s.OWNER_CENTER
            AND s2.OWNER_ID = s.OWNER_ID
            AND s2.ID != s.ID
            AND s2.START_DATE > s.END_DATE
            AND s2.SUB_STATE NOT IN (7,8) )
    AND p.CENTER IN ($$scope$$)
GROUP BY
    p.CENTER || 'p' || p.ID ,
    p.SEX,
    floor(months_between(exerpsysdate(), p.BIRTHDATE) / 12) ,
    p.ZIPCODE ,
    prod.NAME