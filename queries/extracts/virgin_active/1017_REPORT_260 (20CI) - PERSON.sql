SELECT
    iq.PERSONID,
    iq.HOMEADDRESSID,
    iq.SITEID,
    iq.CREATEDDATE,
    longToDateC(pcl.ENTRY_TIME,cc.center) "MODIFIEDDATE",
    iq.TITLE,
    iq.FORENAME,
    iq.SURNAME,
    iq.DOB,
    iq.GENDER,
    CASE
        WHEN cc.CENTER IS NOT NULL
        THEN 'CASH COLLECTION'
        WHEN SYSDATE - MIN(art.DUE_DATE) < 30
        THEN 'UNDER'
        ELSE 'OVER 30'
    END              ACCOUNTSTATUS,
    arCash.DEBIT_MAX "CREDITLIMIT",
    CASE
        WHEN arCash.DEBIT_MAX IS NULL
            OR arCash.DEBIT_MAX = 0
        THEN 0
        ELSE 1
    END                    "ACCOUNTENABLED",
    NVL(SUM(art.AMOUNT),0) DEBTBALANCE,
    iq.CREATEDBY,
    cp.FULLNAME "EDITEDBY",
    iq.COMPANYID,
    iq.REFERREDBYID,
    iq.HEADOFFAMILY,
    iq.STATUS,
    iq.type person_type,
    iq.old_system_id,
    iq.ExerpPersonID
FROM
    (
        SELECT
            (
                SELECT
                    MAX(pcl2.id)
                FROM
                    PERSON_CHANGE_LOGS pcl2
                WHERE
                    pcl2.PERSON_CENTER = pv.CENTER
                    AND pcl2.PERSON_ID = pv.ID
                    AND pcl2.CHANGE_ATTRIBUTE IN ('_eClub_AllowedChannelLetter',
                                                  '_eClub_InvoiceAddress1',
                                                  '_eClub_InvoiceAddress2',
                                                  '_eClub_InvoiceCity',
                                                  '_eClub_InvoiceCoName',
                                                  '_eClub_InvoiceCountry',
                                                  '_eClub_InvoiceEmail',
                                                  '_eClub_InvoiceZipCode',
                                                  '_eClub_Salutation',
                                                  'ACCEPTING_EMAIL_NEWS_LETTERS',
                                                  'ACCEPTING_THIRD_PARTY_OFFERS',
                                                  'ADDRESS_1',
                                                  'ADDRESS_2',
                                                  'ADDRESS_3',
                                                  'ALLOWED_CHANNEL_EMAIL',
                                                  'ALLOWED_CHANNEL_PHONE',
                                                  'ALLOWED_CHANNEL_SMS',
                                                  'BIRTHDATE',
                                                  'CITY',
                                                  'CO_NAME',
                                                  'COUNTRY',
                                                  'E_MAIL',
                                                  'FIRST_NAME',
                                                  'HOME_PHONE',
                                                  'LAST_NAME',
                                                  'MOB_PHONE',
                                                  'SEX',
                                                  'SSN',
                                                  'WORK_PHONE',
                                                  'ZIP_CODE
') ) max_change_id,
            pv.CENTER,
            pv.ID,
            pv.UNIQUE_KEY                                              "PERSONID",
            pv.UNIQUE_KEY                                              "HOMEADDRESSID",
            pv.CENTER                                                  "SITEID",
            pv.CREATION_TIME                                           "CREATEDDATE",
            pv.SALUTATION                                              "TITLE",
            pv.FIRST_NAME                                              "FORENAME",
            pv.LAST_NAME                                               "SURNAME",
            pv.DATE_OF_BIRTH                                           "DOB",
            pv.GENDER                                                  "GENDER",
            pv.CREATED_BY_FIRST_NAME || ' ' || pv.CREATED_BY_LAST_NAME "CREATEDBY",
            comp.EXTERNAL_ID                                           "COMPANYID",
            pRef.EXTERNAL_ID                                           "REFERREDBYID",
            NVL2(relHOF.CENTER,1,0)                                    "HEADOFFAMILY",
            NULL                                                       "STATUS",
            pv.type,
            oldId.TXTVALUE old_system_id ,
            /* should be taken from person extended atts */
            pv.CENTER || 'p' || pv.ID ExerpPersonID
        FROM
            PERSONS_VW pv
        LEFT JOIN
            PERSON_EXT_ATTRS oldId
        ON
            oldId.PERSONCENTER = pv.CENTER
            AND oldId.PERSONID = pv.ID
            AND oldId.NAME = '_eClub_OldSystemPersonId'
        LEFT JOIN
            RELATIVES rel
        ON
            rel.CENTER = pv.CENTER
            AND rel.ID = pv.ID
            AND rel.RTYPE = 3
            AND rel.STATUS = 1
        LEFT JOIN
            PERSONS comp
        ON
            comp.CENTER = rel.RELATIVECENTER
            AND comp.ID = rel.RELATIVEID
        LEFT JOIN
            RELATIVES relRef
        ON
            relRef.CENTER = pv.CENTER
            AND relRef.ID = pv.ID
            AND relRef.RTYPE = 13
            AND relRef.STATUS = 1
        LEFT JOIN
            PERSONS pRef
        ON
            pRef.CENTER = relRef.RELATIVECENTER
            AND pRef.ID = relRef.RELATIVEID
        LEFT JOIN
            RELATIVES relHOF
        ON
            relHOF.RELATIVECENTER = pv.CENTER
            AND relHOF.RELATIVEID = pv.ID
            AND relHOF.RTYPE = 4
            AND relHOF.STATUS = 1 
where pv.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'GB')
) iq
LEFT JOIN
    PERSON_CHANGE_LOGS pcl
ON
    pcl.ID = iq.MAX_CHANGE_ID
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = pcl.EMPLOYEE_CENTER
    AND emp.ID = pcl.EMPLOYEE_ID
LEFT JOIN
    PERSONS cp
ON
    cp.CENTER = emp.PERSONCENTER
    AND cp.ID = emp.PERSONID
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = iq.center
    AND ar.CUSTOMERID = iq.id
    AND ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES arCash
ON
    arCash.CUSTOMERCENTER = iq.center
    AND arCash.CUSTOMERID = iq.id
    AND arCash.AR_TYPE = 1
LEFT JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.id = ar.id
    AND (
        art.DUE_DATE IS NOT NULL
        AND art.DUE_DATE < TRUNC(SYSDATE,'DD') 

)
LEFT JOIN
    CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = ar.CUSTOMERCENTER
    AND cc.PERSONID = ar.CUSTOMERID
    AND cc.CLOSED = 0
    AND cc.SUCCESSFULL = 0
    AND cc.MISSINGPAYMENT = 1

GROUP BY
    iq.old_system_id,
    iq.type,
    iq.ExerpPersonID,
    iq.PERSONID,
    iq.HOMEADDRESSID,
    iq.SITEID,
    iq.CREATEDDATE,
    cc.CENTER,
    pcl.ENTRY_TIME,
    iq.TITLE,
    iq.FORENAME,
    iq.SURNAME,
    iq.DOB,
    iq.GENDER,
    iq.CREATEDBY,
    cp.FULLNAME ,
    iq.COMPANYID,
    iq.REFERREDBYID,
    iq.HEADOFFAMILY,
    iq.STATUS,
    arCash.DEBIT_MAX