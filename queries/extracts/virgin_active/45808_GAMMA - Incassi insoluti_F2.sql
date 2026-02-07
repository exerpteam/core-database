WITH
    PARAMS AS NOT MATERIALIZED
    (
        SELECT
            EXTRACT(MONTH FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1)) AS sel_month,
            EXTRACT(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))  AS sel_year,
            TRUNC(CURRENT_DATE) as importdate,
            ADD_MONTHS(LAST_DAY(CAST(CURRENT_TIMESTAMP AS DATE)),-2) as pr_req_date_param
         
    )

SELECT
    CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'), CAST(p1.ID AS VARCHAR(8))) AS "PERSONID",
        c.EXTERNAL_ID                                                         AS "EXTERNAL_ID",
    agr.TEXT                    AS "TEXT",
    art3.AMOUNT                 AS "AMOUNT",
    longtodate(art3.TRANS_TIME) AS "PAYMENT_DATE",
    CAST(
        CASE ad.EXTERNAL_ID
            WHEN '01852'
            THEN '99'
            WHEN '01853'
            THEN '98'
            WHEN '11707'
            THEN '97'
            WHEN '01850'
            THEN '01'
            WHEN '00320'
            THEN '02'
            WHEN '00340'
            THEN '03'
            WHEN '00360'
            THEN '04'
            WHEN '01870'
            THEN '05'
        END AS INT) AS "CASH_PAYMENT_METHOD",
par.importdate  AS "IMPORTDATE",
    art3.EMPLOYEECENTER AS "PAYMENT_CENTER"
FROM
    PERSONS p1
    
 join centers c
 ON p1.center = c.id
 AND  c.COUNTRY ='IT'
    
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p1.CENTER
AND ar.CUSTOMERID = p1.ID
AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
AND pac.ID = ar.ID
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
AND pr.ID = ar.id
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
AND art.PAYREQ_SPEC_ID = prs.ID
AND art.PAYREQ_SPEC_SUBID = prs.SUBID
LEFT JOIN
    AR_TRANS ART3
ON
    Art.CENTER = ART3.center
AND Art.ID = ART3.ID
AND art3.SUBID > art.SUBID
AND art3.AMOUNT > 0
AND art3.TEXT NOT LIKE 'Automatic%'
    --and art3.TEXT NOT LIKE 'Transfer to%'
AND art3.REF_TYPE = 'ACCOUNT_TRANS'
LEFT JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = art3.REF_CENTER
AND act.ID = art3.REF_ID
AND act.SUBID = art3.REF_SUBID
LEFT JOIN
    AGGREGATED_TRANSACTIONS agr
ON
    agr.CENTER = act.AGGREGATED_TRANSACTION_CENTER
AND agr.ID = act.AGGREGATED_TRANSACTION_ID
LEFT JOIN
    ACCOUNTS ad
ON
    ad.ID = act.DEBIT_ACCOUNTID
AND ad.CENTER = act.DEBIT_ACCOUNTCENTER
LEFT JOIN
    ACCOUNTS ac
ON
    ac.ID = act.CREDIT_ACCOUNTID
AND ac.CENTER = act.CREDIT_ACCOUNTCENTER
AND ac.EXTERNAL_ID = '11705'


  
CROSS JOIN params par
   
   

WHERE pr.req_date <= par.pr_req_date_param
AND CAST(extract(DAY FROM pr.req_date) AS INT)<=4
--AND pr.req_date <= ADD_MONTHS(LAST_DAY(CAST(CURRENT_TIMESTAMP AS DATE)),-2)
AND CAST(extract(DAY FROM pr.req_date) AS INT) <=4
    --and art1.PAYREQ_SPEC_CENTER = select c.ID from CENTERS c where  c.COUNTRY = 'IT' and
    -- art1.PAYREQ_SPEC_ID = 21020  and art1.PAYREQ_SPEC_SUBID = 2
AND Extract(MONTH FROM(longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = par.sel_month
AND Extract(YEAR FROM(longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = par.sel_year
AND Extract(MONTH FROM(longtodate(art3.ENTRY_TIME))) = par.sel_month
AND Extract(YEAR FROM(longtodate(art3.ENTRY_TIME))) = par.sel_year
AND pr.STATE IS NOT NULL
AND ART.REF_TYPE = 'INVOICE'
AND OPEN_AMOUNT < REQUESTED_AMOUNT


GROUP BY
    p1.CENTER,
    p1.ID,
    c.EXTERNAL_ID,
    agr.TEXT,
    art3.AMOUNT,
    par.importdate,
    art3.TRANS_TIME,
    ad.EXTERNAL_ID,
    art3.CENTER,
    art3.ID,
    art3.SUBID,
    art3.EMPLOYEECENTER,
    art3.TEXT,
    pr.REQ_DATE