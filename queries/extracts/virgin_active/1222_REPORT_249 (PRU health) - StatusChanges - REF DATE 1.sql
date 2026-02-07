/* Transferred members */
SELECT DISTINCT
    /* Integer */
    CASE
        WHEN i1.TRANSFERRED_CENTER IS NULL
        THEN p.CENTER
        ELSE i1.CENTER
    END AS "Club",
    /* bigint */
    pruRef.TXTVALUE "EntityNumber",
    /* varchar(20) */
    p.EXTERNAL_ID "ExerpMemberID",
    /* varchar(20) */
    con.TXTVALUE "LegacyMemberID",
    i1.EffectiveDate,
    i1.TRANSFERRED_CENTER TRANSFERREDCLUB,
    i1.RecordType
FROM
    (
        /* Transferred members */
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            s.CENTER,
            s.id,
            s.TRANSFERRED_CENTER,
            'Transfer' RecordType,
            s.START_DATE,
            longToDate(scl.BOOK_START_TIME) EffectiveDate
        FROM
            SUBSCRIPTIONS s
        JOIN RELATIVES rel
        ON
            rel.CENTER = s.OWNER_CENTER
            AND rel.id = s.OWNER_ID
            AND rel.RTYPE = 3
            AND
            (
                rel.RELATIVECENTER,rel.RELATIVEID
            )
            IN ($$pru_company$$)
        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND link.PRODUCT_ID = s.SUBSCRIPTIONTYPE_ID
        JOIN PRODUCT_GROUP pg
        ON
            pg.id = link.PRODUCT_GROUP_ID
            AND pg.NAME = 'Pru'
        JOIN STATE_CHANGE_LOG scl
        ON
            scl.CENTER = s.CENTER
            AND scl.id = s.id
            /* SUBSCRIPTION */
            AND scl.ENTRY_TYPE = 2
            /* ENDED */
            AND scl.STATEID = 3
            /* TRANFERRED */
            AND scl.SUB_STATE = 6
            AND scl.BOOK_END_TIME IS NULL
            AND scl.BOOK_START_TIME BETWEEN dateToLong(TO_CHAR(TRUNC($$refDate$$-1), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(TRUNC($$refDate$$), 'YYYY-MM-dd HH24:MI'))-1
        UNION ALL
        
        /* Rejoiners */
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            s.CENTER,
            s.id,
            s.TRANSFERRED_CENTER,
            'Restart',
            s.START_DATE,
            s.START_DATE EffectiveDate
        FROM
            SUBSCRIPTIONS s
        JOIN RELATIVES rel
        ON
            rel.CENTER = s.OWNER_CENTER
            AND rel.id = s.OWNER_ID
            AND rel.STATUS = 1
            AND rel.RTYPE = 3
            AND
            (
                rel.RELATIVECENTER,rel.RELATIVEID
            )
            IN ($$pru_company$$)
        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND link.PRODUCT_ID = s.SUBSCRIPTIONTYPE_ID
        JOIN PRODUCT_GROUP pg
        ON
            pg.id = link.PRODUCT_GROUP_ID
            AND pg.NAME = 'Pru'
        WHERE
            s.CREATION_TIME BETWEEN dateToLong(TO_CHAR(TRUNC($$refDate$$-1), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(TRUNC($$refDate$$), 'YYYY-MM-dd HH24:MI'))-1
            AND s.STATE IN (2,4,8)
            AND EXISTS
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
        UNION ALL
        
        /* Cancellations */
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            s.CENTER,
            s.id,
            s.TRANSFERRED_CENTER,
            'Cancel' RecordType ,
            s.START_DATE,
            TRUNC($$refDate$$) EffectiveDate
        FROM
            SUBSCRIPTIONS s
        JOIN RELATIVES rel
        ON
            rel.CENTER = s.OWNER_CENTER
            AND rel.id = s.OWNER_ID
            AND rel.STATUS = 1
            AND rel.RTYPE = 3
            AND
            (
                rel.RELATIVECENTER,rel.RELATIVEID
            )
            IN ($$pru_company$$)
        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND link.PRODUCT_ID = s.SUBSCRIPTIONTYPE_ID
        JOIN PRODUCT_GROUP pg
        ON
            pg.id = link.PRODUCT_GROUP_ID
            AND pg.NAME = 'Pru'
            /* ENDED WINDOW */
        JOIN STATE_CHANGE_LOG scl
        ON
            scl.CENTER = s.CENTER
            AND scl.ID = s.ID
            AND scl.ENTRY_TYPE = 2
            AND scl.STATEID IN (3,7)
            AND scl.BOOK_END_TIME IS NULL
        WHERE
            /* Skip transferred and extended */
            s.SUB_STATE NOT IN (5,6)
            /* They should have been created the day before yesterday else just a adjustment during the day */
            AND s.CREATION_TIME < dateToLong(TO_CHAR(TRUNC($$refDate$$-1),'YYYY-MM-dd HH24:MI'))
            AND TRUNC(longToDate(scl.BOOK_START_TIME)) = TRUNC($$refDate$$)
    )
    i1
    /****************************/
    /* NON BUSINESS LOGIC JOINS */
    /****************************/
JOIN SUBSCRIPTIONS s
ON
    s.CENTER = i1.center
    AND s.id = i1.id
LEFT JOIN SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = i1.CENTER
    AND spp.ID = i1.ID
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
    oldP.CENTER = i1.OWNER_CENTER
    AND oldP.ID = i1.OWNER_ID
JOIN PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
JOIN RELATIVES rel
ON
    rel.CENTER = i1.OWNER_CENTER
    AND rel.id = i1.OWNER_ID
    AND rel.RTYPE = 3
    /*AND rel.STATUS = 1*/
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
LEFT JOIN PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_SERVICE = 'CompanyAgreement'
    AND pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
    AND pg.VALID_TO IS NULL
LEFT JOIN PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
LEFT JOIN PRODUCT_PRIVILEGES pp
ON
    pp.PRIVILEGE_SET = ps.ID
    AND pp.VALID_TO IS NULL
LEFT JOIN PERSON_EXT_ATTRS PRU_ENTITY_NUMBER
ON
    PRU_ENTITY_NUMBER.PERSONCENTER = p.CENTER
    AND PRU_ENTITY_NUMBER.PERSONID = p.ID
    AND PRU_ENTITY_NUMBER.NAME = 'COMPANY_AGREEMENT_EMPLOYEE_NUMBER'
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