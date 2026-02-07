WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                           
            where  c.country = 'CH'   )
                                        
SELECT 
                r3.*
        FROM
        (
              Select distinct  
                       longToDateC(act.TRANS_TIME, art.center) AS datetime, 
                        t1.account AS account,
                        t1.external_id,
                       case
                       when art.amount < 0
                       then art.amount
                       else '0'  
                                            
                       END  as refund,
                        p.fullname as name,
                        'Debt payment' AS payment_type,
                      trim(replace(t1.TEXT,'Debt payment',''))  as "Transaction text",
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
left join

(
Select
act2.text, 
acc2.name                                                                       AS account,
acc2.external_id,
act2.entry_time,
act2.credit_accountcenter,
act2.credit_accountid,
act2.amount,
acc2.globalid


from ACCOUNT_TRANS act2

join params
on params.center_id = act2.center

join ACCOUNTS acc2
ON
    (
        act2.DEBIT_ACCOUNTCENTER = acc2.center
        AND act2.DEBIT_ACCOUNTID = acc2.id )
    OR (
       act2.CREDIT_ACCOUNTCENTER = acc2.center
        and act2.CREDIT_ACCOUNTID = acc2.id )       

where
act2.trans_TIME >= params.fromDatelong  
AND act2.trans_TIME < params.toDatelong
 )t1    

on
act.entry_time-250 < t1.entry_time
and act.entry_time+250 > t1.entry_time
and act.amount = t1.amount              

where    
act.trans_TIME >=  params.fromDateLong 
AND act.trans_TIME < params.toDateLong 

and act.info_type not in  (3,4,5)
and act.AMOUNT != 0
 and act.trans_TIME >= params.fromDatelong  
AND act.trans_TIME < params.toDateLong 
and ((t1.external_id = '6351') or (acc.external_id = '6351')) and t1.external_id not in ('AR_CASH','6301') and t1.globalid not in ('BANKACCOUNT_CREDITCARD') and (ar.CUSTOMERCENTER,ar.CUSTOMERID) in(:memberid)
 ) r3   