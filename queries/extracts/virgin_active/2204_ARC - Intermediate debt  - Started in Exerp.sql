SELECT
    *
FROM
    (
        SELECT
            SUB_MEMBER_ID,
            SUB_MEMBER_NAME,
            SUB_MEMBER_AGE,
            SUB_TYPE,
            SUB_SALES_DATE,
            SUB_START_DATE,
            SUB_BINDING_END_DATE,
            SUB_PRICE_UNIT_TYPE,
            SUB_PRICE_UNIT_COUNT,
            SUB_PRICE_UNIT,
            PAYER_PERSON_ID,
            PAYER_LEGACY_ID,
            PAYER_SALUTATION,
            PAYER_FIRST_NAME,
            PAYER_LAST_NAME,
            PAYER_ADDRESS_1,
            PAYER_ADDRESS_2,
            PAYER_ADDRESS_3,
            PAYER_POSTCODE,
            PAYER_CITY,
            PAYER_DOB,
            PAYER_AGE,
            PAYER_PHONE_MOBILE,
            PAYER_PHONE_HOME,
            PAYER_E_MAIL,
            PAYER_TOTAL_DEBT,
            PAYER_DEBT_START_DATE,
            PAYER_CENTER_NAME
        FROM
            (
                SELECT
                    pv.CENTER || 'p' || pv.ID                                  PAYER_PERSON_ID,
                    oldId.TXTVALUE                                             PAYER_LEGACY_ID,
                    prod.NAME                                                  SUB_TYPE,
                    center.NAME                                                PAYER_CENTER_NAME,
                    pv.LAST_NAME                                               PAYER_LAST_NAME,
                    pv.FIRST_NAME                                              PAYER_FIRST_NAME,
                    susr.CENTER || 'p' || susr.id                              SUB_MEMBER_ID,
                    susr.FULLNAME                                              SUB_MEMBER_NAME,
                    floor(months_between(TRUNC(SYSDATE),pv.DATE_OF_BIRTH)/12)  PAYER_AGE,
                    floor(months_between(TRUNC(SYSDATE),susr.BIRTHDATE)/12)    SUB_MEMBER_AGE,
                    'MONTH'                                                    SUB_PRICE_UNIT_TYPE,
                    1                                                          SUB_PRICE_UNIT_COUNT,
                    s.BINDING_PRICE                                            SUB_PRICE_UNIT,
                    cc.AMOUNT                                                  PAYER_TOTAL_DEBT,
                    pv.ADDRESS_1                                               PAYER_ADDRESS_1,
                    pv.ADDRESS_2                                               PAYER_ADDRESS_2,
                    pv.ADDRESS_3                                               PAYER_ADDRESS_3,
                    pv.POSTAL_CODE                                             PAYER_POSTCODE,
                    pv.CITY                                                    PAYER_CITY,
                    pv.CELLULAR_PHONE                                          PAYER_PHONE_MOBILE,
                    pv.HOME_PHONE                                              PAYER_PHONE_HOME,
                    pv.SALUTATION                                              PAYER_SALUTATION,
                    TO_CHAR(pv.DATE_OF_BIRTH, 'YYYY-MM-DD')                    PAYER_DOB,
                    pv.EMAIL                                                   PAYER_E_MAIL,
                    TO_CHAR(cc.STARTDATE, 'YYYY-MM-DD')                        PAYER_DEBT_START_DATE,
                    TO_CHAR(exerpro.longtodate(s.CREATION_TIME), 'YYYY-MM-DD') SUB_SALES_DATE,
                    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                        SUB_START_DATE,
                    TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                          SUB_END_DATE,
                    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD')                  SUB_BINDING_END_DATE
                FROM
                    SUBSCRIPTIONS s
                JOIN
                    PRODUCTS prod
                ON
                    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PERSONS susr
                ON
                    susr.CENTER = s.OWNER_CENTER
                    AND susr.ID = s.OWNER_ID
                JOIN
                    SUBSCRIPTIONPERIODPARTS spp
                ON
                    spp.CENTER = s.CENTER
                    AND spp.ID = s.ID
                    AND spp.SPP_STATE = 1
                JOIN
                    SPP_INVOICELINES_LINK link
                ON
                    link.PERIOD_CENTER = spp.CENTER
                    AND link.PERIOD_ID = spp.ID
                    AND link.PERIOD_SUBID = spp.SUBID
                JOIN
                    INVOICELINES invl
                ON
                    invl.CENTER = link.INVOICELINE_CENTER
                    AND invl.ID = link.INVOICELINE_ID
                    AND invl.SUBID = link.INVOICELINE_SUBID
                JOIN
                    AR_TRANS art
                ON
                    art.REF_TYPE = 'INVOICE'
                    AND art.REF_CENTER = invl.CENTER
                    AND art.REF_ID = invl.ID
                JOIN
                    ACCOUNT_RECEIVABLES ar
                ON
                    ar.CENTER = art.CENTER
                    AND ar.ID = art.ID
                    AND ar.AR_TYPE = 4
                JOIN
                    PERSONS_VW pv
                ON
                    pv.CENTER = ar.CUSTOMERCENTER
                    AND pv.ID = ar.CUSTOMERID
                JOIN
                    CASHCOLLECTIONCASES cc
                ON
                    cc.PERSONCENTER = pv.CENTER
                    AND cc.PERSONID = pv.id
                    AND cc.MISSINGPAYMENT = 1
                    AND cc.CLOSED = 0
                    AND cc.SUCCESSFULL = 0
                LEFT JOIN
                    CENTERS center
                ON
                    center.ID = pv.CENTER
                LEFT JOIN
                    PERSON_EXT_ATTRS oldId
                ON
                    oldId.PERSONCENTER = pv.CENTER
                    AND oldId.PERSONID = pv.ID
                    AND oldId.NAME = '_eClub_OldSystemPersonId'
                WHERE
                    s.SUB_STATE = 9
                    AND art.UNSETTLED_AMOUNT < 0
                    AND art.DUE_DATE < SYSDATE
                    -- Age restriction
                    AND floor(months_between(TRUNC(cc.STARTDATE),pv.DATE_OF_BIRTH)/12) >= 18
                    AND floor(months_between(TRUNC(cc.STARTDATE),susr.BIRTHDATE)/12) >= 18
                    -- To only pic up cases started in 2014
                    AND cc.STARTDATE < $$casesBefore$$
                    -- To make sure they have no prior debt
                    AND  not  EXISTS
                    (
                        SELECT
                            1
                        FROM
                            AR_TRANS art2
                        WHERE
                            art2.CENTER = ar.CENTER
                            AND art2.ID = ar.ID
                            and art2.EMPLOYEECENTER = 100 and art2.EMPLOYEEID = 1
                            and art2.REF_TYPE = 'ACCOUNT_TRANS'
                            and art2.AMOUNT < 0
                            )
                GROUP BY
                    pv.CENTER ,
                    pv.ID,
                    oldId.TXTVALUE,
                    pv.LAST_NAME,
                    pv.FIRST_NAME,
                    pv.ADDRESS_1 ,
                    pv.ADDRESS_2 ,
                    pv.ADDRESS_3 ,
                    pv.POSTAL_CODE ,
                    pv.CITY,
                    pv.SALUTATION,
                    pv.CELLULAR_PHONE ,
                    pv.HOME_PHONE ,
                    pv.DATE_OF_BIRTH ,
                    pv.EMAIL,
                    center.NAME,
                    cc.STARTDATE,
                    cc.AMOUNT,
                    s.CENTER,
                    s.ID,
                    prod.NAME ,
                    susr.CENTER ,
                    susr.id,
                    susr.FULLNAME ,
                    susr.BIRTHDATE,
                    floor(months_between(TRUNC(cc.STARTDATE),pv.DATE_OF_BIRTH)/12) ,
                    s.BINDING_PRICE,
                    s.BINDING_END_DATE,
                    s.START_DATE,
                    s.END_DATE,
                    s.BINDING_END_DATE,
                    s.CREATION_TIME ) )
WHERE
    PAYER_TOTAL_DEBT >= 25