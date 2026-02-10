-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.NAME AS Center,
    p.FULLNAME,
    sa.SUBSCRIPTION_CENTER||'ss'|| sa.SUBSCRIPTION_ID AS Subscription_ID,
    p.CENTER || 'p' ||p.ID                            AS Pref,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY   AS pin,
    pem.TXTVALUE AS email,
    ph.TXTVALUE  AS phoneHome,
    pm.TXTVALUE  AS mobile,
    sa.PRICE_PERIOD,
    TO_CHAR( longtodateTZ(inv.ENTRY_TIME,'Europe/London') ,'DD/MM/YYYY HH24:MI') as "SALES TIME",
    pr.NAME
FROM
    PUREGYM.SUBSCRIPTION_SALES sa
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.center = sa.SUBSCRIPTION_TYPE_CENTER
    AND pr.id = sa.SUBSCRIPTION_TYPE_ID
JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    sa.SUBSCRIPTION_CENTER = s.center
    AND s.id = sa.SUBSCRIPTION_ID
JOIN
    PUREGYM.INVOICES inv
ON
    inv.center = s.INVOICELINE_CENTER
    AND inv.id = s.INVOICELINE_ID
JOIN
    PUREGYM.INVOICES inv
ON
    inv.center = s.INVOICELINE_CENTER
    AND inv.id = s.INVOICELINE_ID
JOIN
    PUREGYM.PERSONS p
ON
    p.CENTER = sa.OWNER_CENTER
    AND p.ID = sa.OWNER_ID
JOIN
    PUREGYM.CENTERS c
ON
    c.ID = p.CENTER
LEFT JOIN
    person_ext_attrs ph
ON
    ph.personcenter = p.center
    AND ph.personid = p.id
    AND ph.name = '_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs pem
ON
    pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs pm
ON
    pm.personcenter = p.center
    AND pm.personid = p.id
    AND pm.name = '_eClub_PhoneSMS'
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
WHERE
    sa.SUBSCRIPTION_TYPE_TYPE = 0
    AND sa.PRICE_PERIOD = 0
    AND pr.GLOBALID = 'DAY_PASS_1_DAY'
    AND sa.SALES_DATE BETWEEN $$from_date$$ AND $$to_date$$
    AND sa.SUBSCRIPTION_TYPE_CENTER IN (43,33,57,5,4)