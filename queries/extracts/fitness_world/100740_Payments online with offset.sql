-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
             CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(CURRENT_TIMESTAMP)-$$offset$$-cast('1970-01-01 00:00:00' as date))::bigint*24*3600*1000 END AS FROMDATE,
             (TRUNC(CURRENT_TIMESTAMP+1)-cast('1970-01-01 00:00:00' as date))::bigint*24*3600*1000                                 AS TODATE,
           
            c.id              AS centerID,
            c.name            AS Centername
        FROM
            centers c
             JOIN
             AREA_CENTERS ac
             on
             ac.center = c.id
             join AREAS a
             on
           ac.area = a.id
          and a.root_area = 1
       and a.id not in (33,34,37,39,133)
       and a.blocked != 'true'
            where ac.area in (6,3,5,4,433,435,436,420)
             and c.country = 'DK' and ((c.id in ($$scope$$)) or (c.id = 100)) 
    )
,    
MATERIALIZED_1 as 
(

SELECT distinct
    TO_CHAR(longtodateTZ(act.TRANS_TIME, 'Europe/Copenhagen'),'DD/MM/YYYY HH24:MI:SS') AS "DATETIME BOOKDATE",
    acc.name                                                                       AS account,
    act.TRANS_TIME,
    acc.external_id,
    CASE
        WHEN (art.amount<0)
        THEN art.amount
        ELSE 0
    END                                     AS REFUND ,
    p.fullname                              AS Name,
    act.TEXT                                AS Text,
     ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID AS PersonId,
	p.CENTER								AS CenterID,
    CASE
        WHEN (art.amount>0)
        THEN art.amount
        ELSE 0
    END                                                                            AS PAYMENT,
    TO_CHAR(longtodateTZ(act.ENTRY_TIME, 'Europe/Copenhagen'),'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME",
   act.ENTRY_TIME,
   art.CENTER||'ar'||art.ID||'art'||art.SUBID AS Transactionkey,
   art.amount,
   act.center,
   act.aggregated_transaction_center
   
   
FROM ACCOUNT_TRANS act

join params
on params.centerID = act.center


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
and acc.GLOBALID IN ('AR_EXTERNALDEBT',
'AR_PAYMENT_PERSONS')
and acc.external_id != '6791' and acc.external_id !='9999' and acc.external_id !='6733' and acc.external_id !='6735' and acc.external_id !='6735' and acc.external_id != '6741'
   

JOIN
    ACCOUNT_RECEIVABLES AR
ON
    AR.CENTER = art.CENTER
    AND AR.ID = ART.ID
JOIN
    PERSONS P
ON
    P.CENTER = AR.CUSTOMERCENTER
    AND P.ID = AR.CUSTOMERID
    and p.center in (params.centerID)

where    
act.TRANS_TIME >=  params.fromDate 
 AND act.TRANS_TIME < params.toDate 
 and acc.external_id != '6791' and acc.external_id !='9999' and acc.external_id !='6733' and acc.external_id !='6735' and acc.external_id != '6741'
 and acc.external_id != '6743' and acc.external_id != '6736' and acc.external_id != '6701' and acc.external_id != '6764'
 and act.aggregated_transaction_center in (params.centerID)
 and act.info_type != 3
and ((art.text = 'API Register remaining money from payment request') or (art.text ='Cash collection payment received') or (art.text ='Online betaling') or (art.employeecenter = 100)) 
and art.AMOUNT <> 0
 and art.entry_TIME >= params.fromDate  
AND art.entry_TIME < params.toDate )

,
MATERIALIZED_2 as 

(
Select distinct
act2.text, 
acc2.name                                                                       AS account,
acc2.external_id,
act2.entry_time,
act2.credit_accountcenter,
act2.credit_accountid,
act2.debit_accountcenter,
act2.debit_accountid,
act2.amount


from ACCOUNT_TRANS act2

join params
on params.centerid = act2.center

join ACCOUNTS acc2
ON
    (
        act2.DEBIT_ACCOUNTCENTER = acc2.center
        AND act2.DEBIT_ACCOUNTID = acc2.id )
    OR (
       act2.CREDIT_ACCOUNTCENTER = acc2.center
        and act2.CREDIT_ACCOUNTID = acc2.id )       
and acc2.external_id != '6791' and acc2.external_id !='9999'and acc2.external_id != '6702'  and acc2.external_id != '6704' and acc2.external_id != '6740' and acc2.external_id != '6735' and acc2.external_id !='6735' and acc2.external_id != '6741'


where
act2.TRANS_TIME >= params.fromDate  
AND act2.TRANS_TIME < params.toDate
and params.centerid = act2.center
and acc2.external_id != '6791' and acc2.external_id !='9999'and acc2.external_id != '6702'  and acc2.external_id != '6704' and acc2.external_id != '6740' and acc2.external_id != '6735' and acc2.external_id !='6735' and acc2.external_id != '6741'
)

SELECT distinct
    TO_CHAR(longtodateTZ(m1.TRANS_TIME, 'Europe/Copenhagen'),'DD/MM/YYYY HH24:MI:SS') AS "DATETIME BOOKDATE",
    m1.name                                                                       AS account,
    m1.external_id,
    CASE
        WHEN (m1.amount<0)
        THEN m1.amount
        ELSE 0
    END                                     AS REFUND ,
    m1.name                              AS Name,
    m1.TEXT                                AS "Transaction Text",
     m1.PersonId,
	m1.CENTERid								AS CenterID,
    CASE
        WHEN (m1.amount>0)
        THEN m1.amount
        ELSE 0
    END                                                                            AS PAYMENT,
    TO_CHAR(longtodateTZ(m1.ENTRY_TIME, 'Europe/Copenhagen'),'DD/MM/YYYY HH24:MI:SS') AS "ENTRYTIME",
 --   act.ENTRY_TIME,
   m2.text, 
  m2.account                                                                       AS account,
 m2.external_id,
 m1.Transactionkey
 
FROM
    materialized_1 m1
JOIN
    materialized_2 m2
    
on
m1.entry_time-500 < m2.entry_time
and m1.entry_time+500 > m2.entry_time
and m1.amount = m2.amount    

join params
on params.centerid = m1.center

where
m1.TRANS_TIME >=  params.fromDate 
 AND m1.TRANS_TIME < params.toDate
and m1.aggregated_transaction_center in (params.centerID)  