WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(TO_DATE((:Fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE((:Todate), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                           
            where  c.country = 'CH'  and ((c.id in ($$scope$$)) ) 
                       )                 
SELECT distinct
                r3.*
        FROM
        (  

      Select distinct  
                       longToDateC(act.TRANS_TIME, art.center) AS datetime, 
                      'Cash receipts: Adyen web sales' AS account,
                     '6351' as external_id,
                       case
                       when art.amount < 0
                       then art.amount
                       else '0'  
                                            
                       END  as refund,
                        p.fullname as name,
                        'Debt payment' AS payment_type,
                      art.text  as "Transaction text",
                        ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID AS Person_Id,
                       p.CENTER,
                        CASE
        WHEN (art.amount>0)
        THEN art.amount
        ELSE 0
    END                                                                            AS PAYMENT,
    longToDateC(act.ENTRY_TIME, art.center) AS entry_time,
                    
                        CAST('Debt payment' AS TEXT) AS "type"
                        
                   
   
   
FROM ACCOUNT_TRANS act

join params
on params.center_id = act.center


JOIN
    AR_TRANS art
ON
  art.REF_TYPE = 'ACCOUNT_TRANS'
  and   art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid


join ACCOUNTS acc

ON
    (
        act.DEBIT_ACCOUNTCENTER = acc.center
        AND act.DEBIT_ACCOUNTID = acc.id )
    OR (
        act.CREDIT_ACCOUNTCENTER = acc.center
        AND act.CREDIT_ACCOUNTID = acc.id )

left JOIN
    ACCOUNT_RECEIVABLES AR
ON
    AR.CENTER = art.CENTER
    AND AR.ID = ART.ID
left JOIN
    PERSONS P
ON
    P.CENTER = AR.CUSTOMERCENTER
    AND P.ID = AR.CUSTOMERID
    and p.center in (params.center_id)
        

where    
act.trans_TIME >=  params.fromDateLong 
AND act.trans_TIME < params.toDateLong 

and act.info_type not in  (3,4,5)
and act.AMOUNT != 0
 and act.trans_TIME >= params.fromDatelong  
AND act.trans_TIME < params.toDateLong 
and art.text != 'Write off reminder fees'

 ) r3   