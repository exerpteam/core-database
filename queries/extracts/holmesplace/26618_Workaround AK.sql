-- The extract is extracted from Exerp on 2026-02-08
--  

WITH PARAMS AS
(
        SELECT
                DATETOLONGC(TO_CHAR(TO_DATE('2020-11-01','YYYY-MM-DD'),'YYYY-MM-DD HH24:MI'), c.ID) AS FROM_DATE,
                DATETOLONGC(TO_CHAR(TO_DATE('2020-11-06','YYYY-MM-DD'),'YYYY-MM-DD HH24:MI'), c.ID) AS TO_DATE,
                c.ID AS CENTER_ID
        FROM 
                HP.CENTERS c
        WHERE
                c.COUNTRY = 'AT'
)
SELECT
        ar.CUSTOMERCENTER AS CENTER_ID,
        art.CENTER || 'ar' || art.ID || 'art' || art.SUBID AS TRANSACTION_ID,
        ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PERSON_ID,
        pr.REQ_DELIVERY AS FILE_ID,
        TO_CHAR(LONGTODATEC(art.ENTRY_TIME, art.CENTER),'YYYY-MM-DD') AS TRANSACTION_ENTRY_TIME,
        art.AMOUNT,
        art.TEXT,
        art.STATUS,
        art.UNSETTLED_AMOUNT
FROM
        HP.PAYMENT_REQUESTS pr
JOIN
        PARAMS par ON pr.CENTER = par.CENTER_ID
JOIN 
        HP.PAYMENT_REQUEST_SPECIFICATIONS prs ON prs.CENTER = pr.INV_COLL_CENTER AND prs.ID = pr.INV_COLL_ID AND prs.SUBID = pr.INV_COLL_SUBID
JOIN
        HP.AR_TRANS art ON prs.CENTER = art.PAYREQ_SPEC_CENTER AND prs.ID = art.PAYREQ_SPEC_ID AND prs.SUBID = art.PAYREQ_SPEC_SUBID
JOIN
        HP.ACCOUNT_RECEIVABLES ar ON ar.CENTER = art.CENTER AND ar.ID = art.ID
WHERE
        pr.REQ_DELIVERY IN (42321, 42315, 42318, 42317)
        AND pr.STATE NOT IN (17)
        AND art.ENTRY_TIME >= par.FROM_DATE
        AND art.ENTRY_TIME < par.TO_DATE
        AND art.TEXT LIKE 'Automatic placement%'
