SELECT DISTINCT
    p.center || 'p' || p.id pid,
    s.CENTER || 'ss' || s.ID "Membership Number",
    p.FIRSTNAME                                                                FIRSTNAME,
    p.LASTNAME                                                                 LASTNAME ,
    prod.NAME SUBSCRIPTION_NAME,
    pg.NAME PRIMARY_PRODUCT_GROUP,
    floor(months_between(TRUNC(SYSDATE),p.BIRTHDATE)/12)                       age,
    longToDate(MAX(ci.CHECKIN_TIME) over (PARTITION BY p.EXTERNAL_ID)) last_checkin,
    c.NAME                                                                     CENTER_NAME ,
    CASE
        WHEN sfp.START_DATE > TRUNC(SYSDATE)
        THEN 'FUTURE'
        ELSE 'CURRENT'
    END      AS "Freeze Status",
    sfp.TYPE AS "Freeze type",
	sfp.TEXT as "Reason",
    sfp.START_DATE "Freeze Start Date" ,
    sfp.END_DATE "Freeze End Date" ,
    email.TXTVALUE         EMAIL ,
    mob.TXTVALUE           MOBILE,
    spp.SUBSCRIPTION_PRICE AS "freeze price"
FROM
    SUBSCRIPTION_FREEZE_PERIOD sfp
LEFT JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.center = sfp.SUBSCRIPTION_CENTER
    AND spp.id = sfp.SUBSCRIPTION_ID
    AND spp.FROM_DATE = sfp.START_DATE
    -- and spp.TO_DATE = sfp.END_DATE
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = sfp.SUBSCRIPTION_CENTER
    AND s.ID = sfp.SUBSCRIPTION_ID
join PRODUCTS prod on prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER and     prod.ID = s.SUBSCRIPTIONTYPE_ID 
join PRODUCT_GROUP pg on pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID 
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
    AND email.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mob
ON
    mob.PERSONCENTER = p.CENTER
    AND mob.PERSONID = p.ID
    AND mob.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    CHECKINS ci
ON
    ci.PERSON_CENTER = p.CENTER
    AND ci.PERSON_ID = p.ID
WHERE
    (
        sfp.START_DATE >= TRUNC(SYSDATE)
        OR (
            sfp.END_DATE > TRUNC(SYSDATE - 1)
            AND sfp.START_DATE <= TRUNC(SYSDATE) ))
    AND sfp.STATE != 'CANCELLED'
    AND p.center IN (403,
440,
436,
411,
441,
442,
419,
434,
407,
400,
406,
435,
401,
443)