WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(TO_DATE(:cutdate, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE('2025-01-31', 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name,
                                c.country
                                
                       
                                        FROM 
                                                centers c
                                           
            where c.id in (:scope) )  



SELECT 
     ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
 CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS PERSON_STATUS,
     CASE p.SEX WHEN 'C' THEN 'Company' ELSE 'Private' END CUSTOMER_TYPE,
     CASE ar.AR_TYPE WHEN 1 THEN 'Cash' WHEN 4 THEN 'Payment' WHEN 5 THEN 'Debt' END account_type,
     longToDate(art.TRANS_TIME) TRANS_TIME,
     art.AMOUNT,
     art.UNSETTLED_AMOUNT,
     art.TEXT,
   
    CASE
      WHEN crt.config_payment_method_id = 0 THEN 'External payment method'
      
      ELSE 'Undefined'
  
END AS "Payment method Other",
     
     crt.config_payment_method_id,
     CASE crt.CRTTYPE WHEN 1 THEN 'CASH' WHEN 2 THEN 'CHANGE' WHEN 3 THEN 'RETURN ON CREDIT' WHEN 4 THEN 'PAYOUT CASH' WHEN 5 THEN 'PAID BY CASH AR ACCOUNT' WHEN 6 THEN 'DEBIT CARD' WHEN 7 THEN 'CREDIT CARD' WHEN 8 THEN 'DEBIT OR CREDIT CARD' WHEN 9 THEN 'GIFT CARD' WHEN 10 THEN 'CASH ADJUSTMENT' WHEN 11 THEN 'CASH TRANSFER' WHEN 12 THEN 'PAYMENT AR' WHEN 13 THEN 'CONFIG PAYMENT METHOD' WHEN 14 THEN 'CASH REGISTER PAYOUT' WHEN 15 THEN 'CREDIT CARD ADJUSTMENT' WHEN 16 THEN 'CLOSING CASH ADJUST' WHEN 17 THEN 'VOUCHER' WHEN 18 THEN 'PAYOUT CREDIT CARD' WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS' WHEN 20 THEN 'CLOSING CREDIT CARD ADJ' WHEN 21 THEN 'TRANSFER BACK CASH COINS' WHEN 22 THEN 'INSTALLMENT PLAN' WHEN 100 THEN 'INITIAL CASH' WHEN 101 THEN 'MANUAL' ELSE 'Undefined' END AS CRTTYPE,
         -- t1.account,
     ar.CUSTOMERCENTER as "CenterID",
     staff.fullname as "Staff name",
     art.employeecenter ||'emp'|| art.employeeid as "Staff ID",
     art.REF_TYPE 
         
 FROM
     AR_TRANS art
join params
on
art.center = params.center_id     
     
     
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = art.CENTER
     AND ar.ID = art.ID
join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.id  = ar.CUSTOMERID

join ACCOUNT_TRANS act
on
art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid

 
left join employees emp
on emp.center = art.employeecenter
and
emp.id = art.employeeid 

left join persons staff
on
emp.personcenter = staff.center
and
emp.personid = staff.id  

left JOIN cashregistertransactions crt
 ON 
art.center = crt.artranscenter
 AND art.id = crt.artransid 
 AND art.subid = crt.artranssubid

 
 WHERE
     art.TRANS_TIME < params.fromDateLong
     AND art.AMOUNT > 0
     AND art.UNSETTLED_AMOUNT != 0
     AND art.CENTER = params.center_id
     and ar.state = 0 
    
