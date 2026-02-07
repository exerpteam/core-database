SELECT
    c.SHORTNAME                                                                                                                                                                        club_name,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS person_STATUS,
    p.CENTER || 'p' || p.ID                                                                                                                                                            member_id,
    oldId.TXTVALUE                                                                                                                                                                     legacySystemId,
    p.FIRSTNAME,
    p.LASTNAME,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    p.CITY,
    mpr.CACHED_PRODUCTNAME product_name,
    mpr.INFO_TEXT,
    sa.START_DATE,
    sa.END_DATE,
    ROUND(months_between(SYSDATE,sa.START_DATE),2) months_from_start,
    sa.QUANTITY,
    sa.INDIVIDUAL_PRICE_PER_UNIT CURRENT_PRICE,
    cc.AMOUNT                    ARC_AMOUNT,
    nvl2(cc.CENTER,'Y','N') cash_collection,    
    pv.*
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = sa.SUBSCRIPTION_CENTER
    AND s.ID = sa.SUBSCRIPTION_ID
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
join PERSONS_VW pv on pv.UNIQUE_KEY = p.EXTERNAL_ID    
LEFT JOIN
    PERSON_EXT_ATTRS oldId
ON
    oldId.PERSONCENTER = p.CENTER
    AND oldId.PERSONID = p.ID
    AND oldId.NAME = '_eClub_OldSystemPersonId'
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.CENTER
    AND prod.GLOBALID = mpr.GLOBALID
LEFT JOIN
    CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = p.CENTER
    AND cc.PERSONID = p.ID
    AND cc.CLOSED = 0
    AND cc.SUCCESSFULL = 0
    AND cc.MISSINGPAYMENT = 1
WHERE
    (
        sa.END_DATE >= SYSDATE
        OR sa.END_DATE IS NULL )
    AND sa.CANCELLED = 0
    AND EXISTS
    (
        SELECT
            1
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK link
        WHERE
            link.PRODUCT_CENTER = prod.CENTER
            AND link.PRODUCT_ID = prod.ID
            AND link.PRODUCT_GROUP_ID = 271 )