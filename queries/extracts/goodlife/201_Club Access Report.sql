SELECT DISTINCT
    p.external_id                                                                                                                                                                   AS ExternalId,
    p.center || 'p' || p.id                                                                                                                                                         AS PersonId,
    p.firstname                                                                                                                                                                     AS Firstname,
    p.lastname                                                                                                                                                                      AS Lastname,
    p.ADDRESS1                                                                                                                                                                      AS Address1,
    p.ADDRESS2                                                                                                                                                                      AS Address2,
    p.ADDRESS3                                                                                                                                                                      AS Address3,
    p.city                                                                                                                                                                          AS City,
    zipcode.province                                                                                                                                                                AS Province,
    p.zipcode                                                                                                                                                                       AS "Postal Code",
    p.sex                                                                                                                                                                           AS Gender,
    TO_CHAR(p.birthdate, 'YYYY-MM-DD')                                                                                                                                              AS Birthdate,
    home.txtvalue                                                                                                                                                                   AS "Home Phone",
    mobile.txtvalue                                                                                                                                                                 AS "Mobile Phone",
    workphone.txtvalue                                                                                                                                                              AS "Work Phone",
    barcode.IDENTITY                                                                                                                                                                AS Barcode,
    rfid.IDENTITY                                                                                                                                                                   AS RFID,
    p.center                                                                                                                                                                        AS "Home Club Number",
    s.subscriptiontype_center AS "Subscription Center",
    s.center ||'ss'|| s.id AS "Subscription ID",
    CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
		WHEN 4 THEN 'TRANSFERRED'
		WHEN 5 THEN 'DUPLICATE'
		WHEN 7 THEN 'DELETED'
		WHEN 8 THEN 'ANONYMIZED'
		WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
   END AS "Person Status",
   CASE s.state
        WHEN 2 THEN 'ACTIVE'
		WHEN 3 THEN 'ENDED'
        WHEN 4 THEN 'FROZEN'
		WHEN 7 THEN 'WINDOW'
        WHEN 8 THEN 'CREATED'
        ELSE 'UNKNOWN'
   END AS "Subscription State" ,
   CASE s.SUB_STATE
        WHEN 1 THEN 'NONE'
        WHEN 2 THEN 'AWAITING_ACTIVATION'
        WHEN 3 THEN 'UPGRADED'
        WHEN 4 THEN 'DOWNGRADED'
        WHEN 5 THEN 'EXTENDED'
        WHEN 6 THEN 'TRANSFERRED'
        WHEN 7 THEN 'REGRETTED'
        WHEN 8 THEN 'CANCELLED'        
        WHEN 9 THEN 'BLOCKED' 
		WHEN 10 THEN 'CHANGED'
        ELSE 'UNKNOWN'
    END AS "Subscription Sub State",
    pg.name                                                                                                                                                                         AS "Subscription Access",
    CASE
        WHEN ccc.CENTER IS NOT NULL
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "Active Debt Case",
    CASE
        WHEN mac.CENTER IS NOT NULL
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "Active Missing Agreement"
FROM
    persons p
JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
    AND pr.id = s.subscriptiontype_id
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pglink
ON
    pglink.PRODUCT_CENTER = pr.CENTER
    AND pglink.PRODUCT_ID = pr.id
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = pglink.PRODUCT_GROUP_ID
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = p.country
    AND zipcode.zipcode = p.zipcode
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS workphone
ON
    p.center=workphone.PERSONCENTER
    AND p.id=workphone.PERSONID
    AND workphone.name='_eClub_PhoneWork'
LEFT JOIN
    ENTITYIDENTIFIERS rfid
ON
    rfid.IDMETHOD = 4
    AND rfid.ENTITYSTATUS = 1
    AND rfid.REF_CENTER=p.CENTER
    AND rfid.REF_ID = p.ID
    AND rfid.REF_TYPE = 1
LEFT JOIN
    ENTITYIDENTIFIERS barcode
ON
    barcode.IDMETHOD = 1
    AND barcode.ENTITYSTATUS = 1
    AND barcode.REF_CENTER=p.CENTER
    AND barcode.REF_ID = p.ID
    AND barcode.REF_TYPE = 1
LEFT JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = p.center
    AND ccc.PERSONID = p.id
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT = 1
LEFT JOIN
    CASHCOLLECTIONCASES mac
ON
    mac.PERSONCENTER = p.center
    AND mac.PERSONID = p.id
    AND mac.CLOSED = 0
    AND mac.MISSINGPAYMENT = 0
WHERE
    p.center IN ($$scope$$)
    AND pg.name IN ('Single Club Access', 'Multi-Club Access')
    AND p.STATUS = 1