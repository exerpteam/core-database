-- The extract is extracted from Exerp on 2026-02-08
-- Ticket 35446

SELECT
    ca.center  AS companycenter,
    ca.id      AS companyid,
    c.lastname AS company,
    c.address1 AS addresse1,
    c.zipcode  AS zip,
    zipcodes.city,
    p.center||'p'|| p.id pid,
    p.FIRSTNAME,
    p.LASTNAME,
    p.BIRTHDATE,
    ph.txtvalue home,
    pem.txtvalue email,
    pm.txtvalue mobile
FROM
    FW.COMPANYAGREEMENTS ca
JOIN FW.PERSONS c
ON
    ca.CENTER = c.CENTER
    AND ca.ID = c.ID
JOIN FW.RELATIVES rel
ON
    rel.RELATIVECENTER = ca.CENTER
    AND rel.RELATIVEID = ca.ID
    AND rel.RELATIVESUBID = ca.SUBID
    AND rel.RTYPE = 3
JOIN FW.PERSONS p
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 3
LEFT JOIN FW.person_ext_attrs ph
ON
    ph.personcenter = p.center
    AND ph.personid = p.id
    AND ph.name = '_eClub_PhoneHome'
LEFT JOIN FW.person_ext_attrs pem
ON
    pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'
LEFT JOIN FW.person_ext_attrs pm
ON
    pm.personcenter = p.center
    AND pm.personid = p.id
    AND pm.name = '_eClub_PhoneSMS'
LEFT JOIN FW.subscriptions s
ON
    s.OWNER_CENTER = rel.CENTER
    AND s.OWNER_ID = rel.ID
    AND s.STATE IN (2,4 )
LEFT JOIN FW.subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id
LEFT JOIN FW.products prod
ON
    st.center = prod.center
    AND st.id = prod.id
LEFT JOIN FW.zipcodes
ON
    c.country=zipcodes.country
    AND c.zipcode=zipcodes.zipcode
JOIN FW.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
JOIN FW.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
    AND st.ST_TYPE = 1
    AND s.STATE IN (2,4)
JOIN FW.PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_SERVICE = 'CompanyAgreement'
    AND pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
    AND
    (
        pg.SPONSORSHIP_NAME IN ('NONE')
        OR pg.SPONSORSHIP_NAME IS NULL
    )
    AND pg.VALID_FROM < dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
    AND
    (
        pg.VALID_TO > dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
        OR pg.VALID_TO IS NULL
    )
WHERE
    p.STATUS IN (1,3)
    AND rel.STATUS = 1
    AND
    (
        SELECT
            SUM(COUNT(rel2.CENTER))
        FROM
            FW.RELATIVES rel2
        JOIN FW.PERSONS p
        ON
            p.CENTER = rel2.CENTER
            AND p.ID = rel2.ID
        WHERE
            rel2.RELATIVECENTER = ca.CENTER
            AND rel2.RELATIVEID = ca.ID
            AND rel2.STATUS = 1
            AND rel2.RTYPE = 3
            AND p.STATUS IN (1,3)
        GROUP BY
            rel2.CENTER,
            rel2.ID
    )
    < 10
group by 
    ca.center,
    ca.id,
    c.lastname,
    c.address1,
    c.zipcode,
    zipcodes.city,
    p.center||'p'|| p.id,
    p.FIRSTNAME,
    p.LASTNAME,
    p.BIRTHDATE,
    ph.txtvalue,
    pem.txtvalue,
    pm.txtvalue

ORDER BY
    ca.CENTER,
    ca.id
