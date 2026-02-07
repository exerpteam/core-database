SELECT DISTINCT
    /* Integer */
    p.CENTER "Club",
    /* bigint */
    pruRef.TXTVALUE "EntityNumber",
    /* varchar(20) */
    p.EXTERNAL_ID "ExerpMemberID",
    /* varchar(20) */
    con.TXTVALUE "LegacyMemberID",
    FIRST_VALUE(invl.TOTAL_AMOUNT) OVER (PARTITION BY s.CENTER, s.ID ORDER BY invl.SUBID ASC) ProRata1,
    FIRST_VALUE(invl.TOTAL_AMOUNT) OVER (PARTITION BY s.CENTER, s.ID ORDER BY invl.SUBID DESC) ProRata2,
    s.BINDING_PRICE "Amount",
    perCreation.TXTVALUE "JoinDate",
    s.START_DATE "ContractStart",
    s.BINDING_END_DATE "EarliestEnd",
    NVL(ss.PRICE_NEW,0) + NVL(ss.PRICE_ADMIN_FEE,0) "ActivateFee",
    REGEXP_SUBSTR(prod.name,'([[:digit:]]+)%',1,1,'i',1) "Discount",
    /*pp.PRICE_MODIFICATION_AMOUNT "Discount",*/
    ca.NAME "PlanType",
    PRU_ENTITY_NUMBER.TXTVALUE "AuthCode",
    PBLookupPartnerErrorCode.TXTVALUE ErrorCode,
    EMPLOYER_NAME.TXTVALUE "EmployerName",
    EMPLOYER_NBR.TXTVALUE "EmployerNo",
    1 "DataProtect",
    1 "TandCagree",
    s.START_DATE "DateVABilled"
FROM
    SUBSCRIPTIONS s
JOIN SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = s.CENTER
    AND ss.SUBSCRIPTION_ID = s.ID
LEFT JOIN SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = s.CENTER
    AND spp.ID = s.ID
    AND spp.SPP_TYPE = 8
    AND spp.SPP_STATE= 1
LEFT JOIN SPP_INVOICELINES_LINK link
ON
    link.PERIOD_CENTER = spp.CENTER
    AND link.PERIOD_ID = spp.ID
    AND link.PERIOD_SUBID = spp.SUBID
LEFT JOIN INVOICELINES invl
ON
    invl.CENTER = link.INVOICELINE_CENTER
    AND invl.ID = link.INVOICELINE_ID
    AND invl.SUBID = link.INVOICELINE_SUBID
LEFT JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN PERSONS oldP
ON
    oldP.CENTER = s.OWNER_CENTER
    AND oldP.ID = s.OWNER_ID
JOIN PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
JOIN RELATIVES rel
ON
    rel.CENTER = s.OWNER_CENTER
    AND rel.id = s.OWNER_ID
    AND rel.RTYPE = 3
    AND rel.STATUS = 1
    AND
    (
        rel.RELATIVECENTER,rel.RELATIVEID
    )
    IN ($$pru_company$$)
JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.ID = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID
JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.ID = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID
JOIN PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_SERVICE = 'CompanyAgreement'
    AND pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
    AND pg.VALID_TO IS NULL
JOIN PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
JOIN PRODUCT_PRIVILEGES pp
ON
    pp.PRIVILEGE_SET = ps.ID
    AND pp.VALID_TO IS NULL
LEFT JOIN PERSON_EXT_ATTRS PRU_ENTITY_NUMBER
ON
    PRU_ENTITY_NUMBER.PERSONCENTER = p.CENTER
    AND PRU_ENTITY_NUMBER.PERSONID = p.ID
    AND PRU_ENTITY_NUMBER.NAME = '_eClub_PBActivationAuthorizationCode'
LEFT JOIN PERSON_EXT_ATTRS AUTH_CODE
ON
    AUTH_CODE.PERSONCENTER = p.CENTER
    AND AUTH_CODE.PERSONID = p.ID
    AND AUTH_CODE.NAME = 'AUTH_CODE'
LEFT JOIN PERSON_EXT_ATTRS EMPLOYER_NAME
ON
    EMPLOYER_NAME.PERSONCENTER = p.CENTER
    AND EMPLOYER_NAME.PERSONID = p.ID
    AND EMPLOYER_NAME.NAME = 'EMPLOYER_NAME'
LEFT JOIN PERSON_EXT_ATTRS EMPLOYER_NBR
ON
    EMPLOYER_NBR.PERSONCENTER = p.CENTER
    AND EMPLOYER_NBR.PERSONID = p.ID
    AND EMPLOYER_NBR.NAME = 'EMPLOYER_NBR'
JOIN PERSONS allOld
ON
    allOld.CURRENT_PERSON_CENTER = p.CENTER
    AND allOld.CURRENT_PERSON_ID = p.ID
LEFT JOIN PERSON_EXT_ATTRS con
ON
    con.PERSONCENTER = allOld.CENTER
    AND con.PERSONID = allOld.ID
    AND con.NAME = '_eClub_OldSystemPersonId'
LEFT JOIN PERSON_EXT_ATTRS pruRef
ON
    pruRef.PERSONCENTER = p.CENTER
    AND pruRef.PERSONID = p.ID
    AND pruRef.NAME = '_eClub_PBLookupPartnerPersonId'
LEFT JOIN PERSON_EXT_ATTRS PBLookupPartnerErrorCode
ON
    PBLookupPartnerErrorCode.PERSONCENTER = p.center
    AND PBLookupPartnerErrorCode.PERSONID = p.id
    AND PBLookupPartnerErrorCode.NAME = '_eClub_PBActivationPartnerErrorCode'
LEFT JOIN PERSON_EXT_ATTRS perCreation
ON
    perCreation.PERSONCENTER = p.CENTER
    AND perCreation.PERSONID = p.ID
    AND perCreation.NAME = 'CREATION_DATE'
WHERE
    /* Membership should be a pru membership*/
    EXISTS
    (
        SELECT
            1
        FROM
            PRODUCT_GROUP pg
        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_GROUP_ID = pg.id
        WHERE
            link.PRODUCT_CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND link.PRODUCT_ID = s.SUBSCRIPTIONTYPE_ID
            AND pg.NAME = 'Pru'
    )
    AND NOT EXISTS
    (
        SELECT
            s.CENTER,
            s.id,
            s.SUB_STATE,
            s2.CENTER,
            s2.id,
            s2.SUB_STATE,
            TRUNC(s.START_DATE) - TRUNC(s2.END_DATE) days_between
        FROM
            SUBSCRIPTIONS s2
            /*        JOIN SUBSCRIPTIONS s
            ON
            s.OWNER_CENTER = 401
            AND s.OWNER_ID = 6210 */
        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK link2
        ON
            link2.PRODUCT_CENTER = s2.SUBSCRIPTIONTYPE_CENTER
            AND link2.PRODUCT_ID = s2.SUBSCRIPTIONTYPE_ID
        JOIN PRODUCT_GROUP pg2
        ON
            pg2.ID = link2.PRODUCT_GROUP_ID
        WHERE
            s2.END_DATE - s.START_DATE < $$days_between$$
            AND pg2.NAME = 'Pru'
            AND
            (
                s2.CENTER,s2.ID
            )
            NOT IN ((s.center,s.id))
            AND
            (
                s2.OWNER_CENTER,s2.OWNER_ID
            )
            IN ((s.OWNER_CENTER,s.OWNER_ID))
            AND s2.END_DATE IS NOT NULL
            AND s2.id < s.id
    )
    AND s.CREATION_TIME BETWEEN exerpro.dateToLong(TO_CHAR(TRUNC($$refDate$$)-1,'YYYY-MM-DD HH24:MI')) AND exerpro.dateToLong(TO_CHAR(TRUNC($$refDate$$),'YYYY-MM-DD HH24:MI'))-1
    AND s.STATE IN (2,4,8)