-- This is the version from 2026-02-05
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(TO_DATE(:fromdate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS
            bigint) AS fromDate,
            CAST(dateToLongC(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS bigint
            )+(1000*60*60*24)-1 AS toDate,
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
            where ac.area in (17,12,3,16,422,425,427,134,6,421,231,426,335,4,424,433,435,436,337,420,5)
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
   act.aggregated_transaction_center,
   acc3.name as account3name,
   acc3.external_id as acc3external_id
   
   
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
'AR_PAYMENT_PERSONS', 'AR_CASH' )
and acc.external_id != '6791' and acc.external_id !='9999' and acc.external_id !='6735' and acc.external_id !='6735' and acc.external_id !='6735' and acc.external_id != '6741' and acc.external_id != '6746'
   

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
left join ACCOUNTS acc3

ON
    (
        act.DEBIT_ACCOUNTCENTER = acc3.center
        AND act.DEBIT_ACCOUNTID = acc3.id )
    OR (
        act.CREDIT_ACCOUNTCENTER = acc3.center
        AND act.CREDIT_ACCOUNTID = acc3.id )    
and acc3.external_id in ( '6733','6746')         
and acc3.GLOBALID not IN ('AR_EXTERNALDEBT',
'AR_PAYMENT_PERSONS', 'AR_CASH' )         
    

where    
act.TRANS_TIME >=  params.fromDate 
 AND act.TRANS_TIME < params.toDate 
 and acc.external_id != '6791' and acc.external_id !='9999' and acc.external_id !='6733' and acc.external_id !='6735' and acc.external_id != '6741' and acc.external_id != '6746'
 and acc.external_id != '6743' and acc.external_id != '6736' /*and acc.external_id != '6701'*/ and acc.external_id != '6764'
 and acc3.GLOBALID not IN ('AR_EXTERNALDEBT',
'AR_PAYMENT_PERSONS', 'AR_CASH' )
and act.center in (params.centerID)
and act.info_type not in (3,4,5)
and ((art.text = 'API Register remaining money from payment request') or (art.text ='Cash collection payment received') or (art.text ='Online betaling') or  (art.employeecenter = 100)or (art.employeecenter = 114 and art.employeeid = 40220
)) and art.text != 'Mr gavekort' and act.text != 'MR gavekort'
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
and acc2.external_id != '6738'

where
act2.TRANS_TIME >= params.fromDate  
AND act2.TRANS_TIME < params.toDate
and params.centerid = act2.center
and acc2.external_id != '6791' and acc2.external_id !='9999'and acc2.external_id != '6702'  and acc2.external_id != '6704' and acc2.external_id != '6740' and acc2.external_id != '6735' and acc2.external_id !='6735' and acc2.external_id != '6741' 
and acc2.external_id != '6738' and acc2.external_id != '6701')

SELECT distinct
    TO_CHAR(longtodateTZ(m1.TRANS_TIME, 'Europe/Copenhagen'),'DD/MM/YYYY HH24:MI:SS') AS "DATETIME BOOKDATE",
    m1.account                                                                       AS account,
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
  case when m2.text is null
  then m1.text
  else m2.text end as text, 
 case when m2.account is null
 then m1.account3name
 else m2.account
 end                                                                       AS account,
 case when m2.external_id is null
 then m1.acc3external_id
 else m2.external_id
 end as external_id ,
 m1.Transactionkey
 
FROM
    materialized_1 m1
left JOIN
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
and m1.CENTERid in (params.centerID)
and m1.text != 'MR gavekort'