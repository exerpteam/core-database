-- The extract is extracted from Exerp on 2026-02-08
-- Ticket 35376
SELECT
    ca.center  AS companycenter,
    ca.id      AS companyid,
    c.lastname AS company,
    c.address1 AS addresse1,
    c.zipcode  AS zip,
    contact.FIRSTNAME,
    contact.LASTNAME,
    attsCEmail.TXTVALUE email,
    attsCMob.TXTVALUE mobile,
    attsCWP.TXTVALUE phone,
    zipcodes.city,
    COUNT (p.center||'p'|| p.id) AS antal_mindre_eller_lig_10
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
    AND rel.STATUS = 1
LEFT JOIN FW.RELATIVES cc
ON
    cc.CENTER = ca.CENTER
    AND cc.ID = ca.ID
    AND cc.RTYPE = 7
LEFT JOIN FW.PERSONS contact
ON
    contact.CENTER = cc.RELATIVECENTER
    AND contact.ID = cc.RELATIVEID
LEFT JOIN FW.PERSON_EXT_ATTRS attsCEmail
ON
    attsCEmail.PERSONCENTER = contact.CENTER
    AND attsCEmail.PERSONID = contact.ID
    AND attsCEmail.NAME = '_eClub_Email'
LEFT JOIN FW.PERSON_EXT_ATTRS attsCMob
ON
    attsCMob.PERSONCENTER = contact.CENTER
    AND attsCMob.PERSONID = contact.ID
    AND attsCMob.NAME = '_eClub_PhoneSMS'
LEFT JOIN FW.PERSON_EXT_ATTRS attsCWP
ON
    attsCWP.PERSONCENTER = contact.CENTER
    AND attsCWP.PERSONID = contact.ID
    AND attsCWP.NAME = '_eClub_PhoneWork'
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
WHERE
    p.STATUS IN (1,3)
    AND NOT EXISTS
    (
        SELECT
            *
        FROM
            FW.PRIVILEGE_GRANTS pg
        WHERE
            pg.GRANTER_SERVICE = 'CompanyAgreement'
            AND pg.GRANTER_CENTER = ca.CENTER
            AND pg.GRANTER_ID = ca.ID
            AND pg.VALID_FROM < dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
            AND
            (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
            )
            AND pg.SPONSORSHIP_NAME in ('FULL','PERCENTAGE')
    )
GROUP BY
    ca.center,
    ca.id,
    c.lastname,
    c.address1,
    c.zipcode,
    contact.LASTNAME,
    attsCEmail.TXTVALUE ,
    attsCMob.TXTVALUE ,
    attsCWP.TXTVALUE ,
    contact.FIRSTNAME,
    zipcodes.city