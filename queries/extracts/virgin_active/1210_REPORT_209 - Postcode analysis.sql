SELECT
    a.NAME Region,
    p.CENTER Club,
    c.NAME,
    p.EXTERNAL_ID MemberID,
    atts.TXTVALUE Title,
    p.FIRSTNAME FirstName,
    p.LASTNAME LastName,
    prod.NAME MembershipType,
    p.FIRST_ACTIVE_START_DATE JoinDate,
    p.ZIPCODE PostCode,
    floor(months_between(TRUNC(sysdate),p.BIRTHDATE)/12) Age
FROM
    PERSONS p
JOIN CENTERS c
ON
    c.ID = p.CENTER
JOIN AREA_CENTERS ac
ON
    ac.CENTER = p.CENTER
JOIN AREAS a
ON
    a.ID = ac.AREA
LEFT JOIN SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
LEFT JOIN PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = p.CENTER
    AND atts.PERSONID = p.ID
    AND atts.NAME = '_eClub_Salutation'
WHERE
    p.center IN (:Scope)