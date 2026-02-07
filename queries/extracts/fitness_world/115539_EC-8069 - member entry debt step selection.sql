-- This is the version from 2026-02-05
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:From_Date), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
            AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:To_Date), 'YYYY-MM-DD')+ interval '1 day',
            'YYYY-MM-DD')) AS BIGINT) AS todate,
            c.id                      AS centerid
        FROM
            centers c
    )
    ,
    base_report AS
(SELECT
    p.center ||'p'|| p.id                                                 AS memberid,
    p.external_id                                                         AS externalId,
    ccje.step                                                             AS step,
    TO_CHAR(longtodateC(ccje.creationtime,params.centerid), 'YYYY-MM-dd') AS "date",
    COALESCE(ar_payment.balance, 0)                                       AS Payment_Account_Balance,
    COALESCE(ar_ext_debt.balance, 0)                                      AS External_Debt_Account_Balance,
       convert_from(settings, 'UTF8')::xml AS doc
FROM
    cashcollectionjournalentries ccje
JOIN
    cashcollectioncases cc
ON
    cc.center = ccje.center
AND cc.id = ccje.id
JOIN
    persons p
ON
    p.center = cc.personcenter
AND p.id = cc.personid
JOIN
    params
ON
    params.centerid = ccje.center
LEFT JOIN
    account_receivables ar_payment
ON
    p.center = ar_payment.customercenter
AND p.id= ar_payment.customerid    
AND ar_payment.ar_type = 4
AND ar_payment.state = 0 --Active
LEFT JOIN
    account_receivables ar_ext_debt
ON
    p.center = ar_ext_debt.customercenter
AND p.id= ar_ext_debt.customerid    
AND ar_ext_debt.ar_type = 5
AND ar_ext_debt.state = 0 --Active
WHERE
    ccje.step IN (:Last_Step_Number)  
AND p.sex != 'C'
AND ccje.creationtime BETWEEN params.fromdate AND params.todate
AND cc.missingpayment
and cc.center in (:Scope)
    )
SELECT
    memberid,
    externalId, 
    CASE (xpath('/cashCollectionSettings/systemPropertyName/text()', t.doc))[1]::TEXT
        WHEN 'CASHCOLLECTION_PERS_CREDIT_CARD_PAY_OUTBIND'
        THEN 'Person credit card payment outside binding period'
        WHEN 'CASHCOLLECTION_PERS_CREDIT_CARD_PAY_INBIND'
        THEN 'Person credit card payment inside binding period'
        WHEN 'CASHCOLLECTION_PERS_EFT_PAY_INBIND'
        THEN 'Person EFT payment inside binding period'
        WHEN 'CASHCOLLECTION_PERS_EFT_PAY_OUTBIND'
        THEN 'Person EFT payment outside binding period'
        WHEN 'CASHCOLLECTION_PERS_EFT_AGREE_INBIND'
        THEN 'Person EFT agreement inside binding period'
        WHEN 'CASHCOLLECTION_PERS_EFT_AGREE_OUTBIND'
        THEN 'Person EFT agreement outside binding period'
        WHEN 'CASHCOLLECTION_PERS_INV_PAY_INBIND'
        THEN 'Person invoice payment inside binding period'
        WHEN 'CASHCOLLECTION_PERS_INV_PAY_OUTBIND'
        THEN 'Person invoice payment outside binding period'
        ELSE 'NA'
    END                                               AS case_type,
    u.ordinality                                      AS step,
  case  ( (xpath('string(local-name(*))', u.x))[1])::TEXT 
  WHEN 'message'              THEN 'Message'
  WHEN 'reminder'             THEN 'Reminder fee'
  WHEN 'block'                THEN 'Block membership'
  WHEN 'requestAndStop'       THEN 'Request remaining amount and stop'
  WHEN 'requestBuyoutAndStop' THEN 'Request Remaining Buyout or Binding and Stop Today'
  WHEN 'cashCollection'       THEN 'Debt collection'
  WHEN 'wait'                 THEN 'Wait'
  WHEN 'close'                THEN 'Close'
  WHEN 'push'                 THEN 'Push'
  ELSE 'NA'
END
AS step_type,
    "date",
    Payment_Account_Balance,
    External_Debt_Account_Balance
FROM
    base_report t
CROSS JOIN
    LATERAL unnest(xpath('/cashCollectionSettings/cashCollectionStep/' || '*', t.doc)) 
    WITH ORDINALITY AS u(x, ordinality)
WHERE
    u.ordinality=t.step