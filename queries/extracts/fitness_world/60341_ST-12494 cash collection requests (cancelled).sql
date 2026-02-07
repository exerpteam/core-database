-- This is the version from 2026-02-05
--  
SELECT
'EXERP'         AS "DATA_SUPPLIER",
        'fweinkasso'    AS "ACCOUNT_ID",
        'EXERP'         AS "SOURCE_SYSTEM",
        p.CENTER || 'p' || p.ID AS "PERSON_ID",
        'P' AS "PERSON_TYPE",
        'D' AS "RECORD_TYPE",  
        NULL AS "SALUTATION",
        p.FIRSTNAME AS "FIRST_NAME",
        p.MIDDLENAME AS "MIDDLE_NAME",
        p.LASTNAME AS "LAST_NAME",
        p.FULLNAME AS "FULL_NAME",
        NULL AS "CO_NAME",
        p.ADDRESS1 AS "ADDRESS_1",
        p.ADDRESS2 AS "ADDRESS_2",
        p.ADDRESS3 AS "ADDRESS_3",
        NULL AS "COUNTY",
        p.ZIPCODE AS "POSTCODE",
        p.CITY AS "CITY",
        TO_CHAR(p.BIRTHDATE,'DD-MM-YYYY') AS "DOB",
        c.NAME AS "CENTER_NAME",
        p.COUNTRY AS "COUNTRY",
        p.SSN AS "SSN_CID",
        REPLACE(mobilephone.TXTVALUE,'+','') AS "PHONE_MOBILE",
        REPLACE(homephone.TXTVALUE,'+','') AS "PHONE_HOME",
        REPLACE(workphone.TXTVALUE,'+','') AS "PHONE_WORK",
        email.TXTVALUE AS "E_MAIL",
        ar.BALANCE*(-1) AS "TOTAL_DEBT",
        prs.REF AS "INVOICE_REF",
        TO_CHAR(pr.REQ_DATE,'DD-MM-YYYY') AS "TEXT",
        pag.REF || '-' || pr.REF AS "PAYMENT_REF",
        TO_CHAR(pr.REQ_DATE,'DD-MM-YYYY') AS "REQ_DATE",
        TO_CHAR(pr.DUE_DATE,'DD-MM-YYYY') AS "DUE_DATE",
        'DKK' AS "CURRENCY",
        pr.REQ_AMOUNT AS "ORIGINAL_AMOUNT",
        NULL AS "ADMIN_FEES",
        ccr.REQ_AMOUNT AS "OPEN_AMOUNT",
        art.UNSETTLED_AMOUNT AS "OPEN_AMOUNT_TRANSACTION",
        TO_CHAR(ccc.STARTDATE,'DD-MM-YYYY') AS "DEBT_CASE_START_DATE",        DECODE(ar.AR_TYPE,1,'CASH_ACCOUNT',4,'PAYMENT_ACCOUNT',5,'EXTERNAL_DEBT_ACCOUNT',6,'installment') as ACCOUNT_TYPE,         
        ccc.AMOUNT AS CCC_AMOUNT,
        ccc.CENTER || 'ccol' || ccc.ID AS CCC_ID,
        ccr.CENTER  || 'ccol' ||ccr.ID || 'r' || ccr.SUBID AS CCR_ID,
        ccr.REQ_DELIVERY AS FILE_ID,
        ccr.REF AS CCR_REF,
        ccr.REQ_AMOUNT AS CCR_REQ_AMOUNT,
        ccr.PRSCENTER || 'ar' || ccr.PRSID || 'sp' || ccr.PRSSUBID AS PAYMENT_REQUEST_SPEC_ID,
        ccr.PAYMENT_REQUEST_CENTER || 'ar' || ccr.PAYMENT_REQUEST_ID || 'req' || ccr.PAYMENT_REQUEST_SUBID AS PAYMENT_REQUEST_ID,
        art.CENTER || 'ar' || art.ID || 'art' || art.SUBID AS TRANSACTION_ID,
        art.AMOUNT AS TRANSACTION_AMOUNT,
        art.TEXT AS TRANSACTION_TEXT,
        art.STATUS AS TRANSACTION_STATUS,

        ccc.PERSONCENTER || 'p' || ccc.PERSONID AS "PERSON_ID",
        ar.BALANCE AS "TOTAL_DEBT",
        DECODE(ar.AR_TYPE,1,'CASH_ACCOUNT',4,'PAYMENT_ACCOUNT',5,'EXTERNAL_DEBT_ACCOUNT',6,'installment') as ACCOUNT_TYPE,
        prs.REF AS "INVOICE_REF",
        pr.REQ_DATE AS "TEXT",
        pag.REF as "PAYMENT_REF",
        pag.EXAMPLE_REFERENCE AS "PAYMENT_REF_2",
        pr.REQ_DATE AS "REQ_DATE",
        pr.DUE_DATE AS "DUE_DATE",
        pr.REQ_AMOUNT AS "ORIGINAL_AMOUNT",
        ccr.REQ_AMOUNT AS "OPEN_AMOUNT",
        art.UNSETTLED_AMOUNT AS "OPEN_AMOUNT_TRANSACTION",
        ccc.STARTDATE AS "DEBT_CASE_START_DATE",
        ccc.AMOUNT AS CCC_AMOUNT,
        ccc.CENTER || 'ccol' || ccc.ID AS CCC_ID,
        ccr.CENTER  || 'ccol' ||ccr.ID || 'r' || ccr.SUBID AS CCR_ID,
        ccr.REQ_DELIVERY AS FILE_ID,
        ccr.REF AS CCR_REF,
        ccr.REQ_AMOUNT AS CCR_REQ_AMOUNT,
        ccr.PRSCENTER || 'ar' || ccr.PRSID || 'sp' || ccr.PRSSUBID AS PAYMENT_REQUEST_SPEC_ID,
        ccr.PAYMENT_REQUEST_CENTER || 'ar' || ccr.PAYMENT_REQUEST_ID || 'req' || ccr.PAYMENT_REQUEST_SUBID AS PAYMENT_REQUEST_ID,
        art.CENTER || 'ar' || art.ID || 'art' || art.SUBID AS TRANSACTION_ID,
        art.AMOUNT AS TRANSACTION_AMOUNT,
        art.TEXT AS TRANSACTION_TEXT,
        art.STATUS AS TRANSACTION_STATUS
FROM 
        FW.CASHCOLLECTION_REQUESTS ccr
JOIN
        FW.CASHCOLLECTIONCASES ccc 
                ON ccr.CENTER = ccc.CENTER AND ccr.ID = ccc.ID
JOIN
        FW.PAYMENT_REQUEST_SPECIFICATIONS prs
                ON prs.CENTER = ccr.PRSCENTER AND prs.ID = ccr.PRSID AND prs.SUBID = ccr.PRSSUBID
JOIN 
        FW.PAYMENT_REQUESTS pr 
                ON pr.INV_COLL_CENTER = prs.CENTER AND pr.INV_COLL_ID = prs.ID AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
        FW.AR_TRANS art
                ON art.PAYREQ_SPEC_CENTER = prs.CENTER AND art.PAYREQ_SPEC_ID = prs.ID AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
        FW.ACCOUNT_RECEIVABLES ar
                ON ar.CENTER = art.CENTER AND ar.ID = art.ID
JOIN
        FW.PAYMENT_AGREEMENTS pag
                ON pag.CENTER = pr.CENTER AND pag.ID = pr.ID AND pag.SUBID = pr.AGR_SUBID
JOIN
        FW.PERSONS p
                ON p.CENTER = ccc.PERSONCENTER AND p.ID = ccc.PERSONID
JOIN
        FW.CENTERS c
                ON p.CENTER = c.ID

LEFT JOIN
        FW.PERSON_EXT_ATTRS mobilephone
                ON p.CENTER = mobilephone.PERSONCENTER AND p.ID = mobilephone.PERSONID AND mobilephone.NAME = '_eClub_PhoneSMS'
LEFT JOIN
        FW.PERSON_EXT_ATTRS homephone
                ON p.CENTER = homephone.PERSONCENTER AND p.ID = homephone.PERSONID AND homephone.NAME = '_eClub_PhoneHome'
LEFT JOIN
        FW.PERSON_EXT_ATTRS workphone
                ON p.CENTER = workphone.PERSONCENTER AND p.ID = workphone.PERSONID AND workphone.NAME = '_eClub_PhoneWork'
LEFT JOIN
        FW.PERSON_EXT_ATTRS email
                ON p.CENTER = email.PERSONCENTER AND p.ID = email.PERSONID AND email.NAME = '_eClub_Email'
WHERE
        ccr.STATE = 4
        --AND ccc.CLOSED = 0
        AND art.UNSETTLED_AMOUNT != 0
        AND ccr.REQ_DATE >= TO_DATE('2020-03-01','YYYY-MM-DD')
		AND ccr.CENTER IN (:Scope)