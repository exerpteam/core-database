WITH
    PARAMS AS
    /* materialize */
    (
        SELECT
            dateToLongC(TO_CHAR(CURRENT_DATE - $$offset$$, 'YYYY-MM-DD HH24:MI'),100) AS fromdate,
            dateToLongC(TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD HH24:MI'),100)              AS todate
    )

SELECT distinct
     prodExternalId                 code,
MIN(pname) as "text",
       ROUND(SUM(total_amount), 2) tot_amount,
       ROUND(SUM(excluding_Vat), 2) net_Amount,
       ROUND(SUM(included_Vat), 2) vat_Amount,
     dato as date, 
  case when vat_rate is null
   then '0%'
   else round(vat_rate*100,0) ||'%' END as "tax_rate", 
  transid as transaction_number, 
  person_id,
crttype,
CASE WHEN CRTTYPE = 1 THEN 'CASH' WHEN CRTTYPE = 2 THEN 'CHANGE' WHEN CRTTYPE = 3 THEN 'RETURN ON CREDIT' WHEN CRTTYPE = 4 THEN 'PAYOUT CASH' WHEN CRTTYPE = 5 THEN 'PAID BY CASH AR ACCOUNT' WHEN CRTTYPE = 6 THEN 'DEBIT CARD' WHEN CRTTYPE = 7 and emp_id = '306emp201' THEN 'WEB SALES - CREDIT CARD' WHEN CRTTYPE = 7 and emp_id != '306emp201' THEN 'CREDIT CARD' WHEN CRTTYPE = 8 THEN 'DEBIT OR CREDIT CARD' WHEN CRTTYPE = 9 THEN 'GIFT CARD' WHEN CRTTYPE = 10 THEN 'CASH ADJUSTMENT' WHEN CRTTYPE = 11 THEN 'CASH TRANSFER' WHEN CRTTYPE = 12 THEN 'PAYMENT AR' WHEN CRTTYPE = 13 and emp_id = '100emp13407' THEN 'WEB SALES - CREDIT CARD'
WHEN CRTTYPE = 13 THEN 'CONFIG PAYMENT METHOD' WHEN CRTTYPE = 14 THEN 'CASH REGISTER PAYOUT' WHEN CRTTYPE = 15 THEN 'CREDIT CARD ADJUSTMENT' WHEN CRTTYPE = 16 THEN 'CLOSING CASH ADJUST' WHEN CRTTYPE = 17 THEN 'VOUCHER' WHEN CRTTYPE = 18 THEN 'PAYOUT CREDIT CARD' WHEN CRTTYPE = 19 THEN 'TRANSFER BETWEEN REGISTERS' WHEN CRTTYPE = 20 THEN 'CLOSING CREDIT CARD ADJ' WHEN CRTTYPE = 21 THEN 'TRANSFER BACK CASH COINS' WHEN CRTTYPE = 22 THEN 'INSTALLMENT PLAN' WHEN CRTTYPE = 100 THEN 'INITIAL CASH' WHEN CRTTYPE = 101 THEN 'MANUAL' ELSE 'ACCOUNT' END AS payment_method
    
 FROM
     (
         SELECT
             i.center                                        sales_center,
             club.SHORTNAME                                  sales_club,
             cr.CENTER                                       crCenter,
             cr.id                                           crId,
CASE when il.TOTAL_AMOUNT is null 
Then TO_CHAR(longtodate(crt.TRANSTIME), 'YYYY-MM-DD')             ELSE TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY-MM-DD') END as dato,
CASE when prod.name is NULL
then 'PAYMENT INTO ACCOUNT'
when prod.name like 'Creation%'
then replace(prod.name,'Creation','joining')
ELSE prod.name END as pname,
             CASE
                 WHEN prod.EXTERNAL_ID IS NULL
                 THEN 'CL  -' || prod.id
                 ELSE prod.EXTERNAL_ID
             END                                                                prodExternalId,
             ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),4) excluding_Vat,
             ROUND(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))),4)                     included_Vat,
         case when il.TOTAL_AMOUNT is null
              then crt.amount 
              else ROUND(il.TOTAL_AMOUNT, 4)END as                                          total_Amount,
             il.RATE                                                            vat_rate,
CASE WHEN il.TOTAL_AMOUNT is null
THEN crt.employeecenter ||'emp'|| crt.employeeid
ELSE i.EMPLOYEE_CENTER || 'emp' || i.EMPLOYEE_ID END as                        emp_id,
il.center ||'inv'|| il.id as transid,
CASE 
When il.TOTAL_AMOUNT is null
then crt.customercenter ||'p'|| crt.customerid
ELSE il.person_CENTER ||'p'|| il.person_id END as person_id,
crt.crttype as crttype

         FROM
              CASHREGISTERTRANSACTIONS crt
left join
             INVOICES i
ON
    crt.PAYSESSIONID = i.PAYSESSIONID
       left JOIN
             INVOICELINES il
         ON
             il.center = i.center
             AND il.id = i.id
     
left JOIN
             PRODUCTS prod
         ON
             prod.center = il.PRODUCTCENTER
             AND prod.id = il.PRODUCTID
        left JOIN
             CENTERS club
         ON
             i.center = club.id
cross join params
       left JOIN
             CASHREGISTERS cr
         ON
             i.CASHREGISTER_CENTER = cr.CENTER
             AND i.CASHREGISTER_ID = cr.ID
         WHERE
             crt.CENTER = :Centre
             AND crt.transtime >= params.fromdate
and crt.transtime < params.todate
and crt.crttype not in (16,20,10)

            
           
         UNION ALL
         SELECT
             c.center                                        sales_center,
             club.SHORTNAME                                  sales_club,
             cr.CENTER                                       crCenter,
             cr.id                                           crId,
             TO_CHAR(longtodate(c.TRANS_TIME), 'YYYY-MM-DD') dato,
             prod.NAME                                       pname,
             CASE
                 WHEN prod.EXTERNAL_ID IS NULL
                 THEN 'CL  -' || prod.id
                 ELSE prod.EXTERNAL_ID
             END                                                                          prodExternalId,
             -ROUND(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2), 4) excluding_Vat,
             -ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 4)                             included_Vat,
             -ROUND(cl.TOTAL_AMOUNT, 4)                                                   total_Amount,
             cl.RATE                                                                      vat_rate,
             c.EMPLOYEE_CENTER || 'emp' || c.EMPLOYEE_ID                                  emp_id,
cl.center ||'cred'|| cl.id as transid,
cl.person_CENTER ||'p'|| cl.person_id as person_id,
crt.crttype as crttype

         FROM
CASHREGISTERTRANSACTIONS crt
left join
             CREDIT_NOTES c
ON
    crt.PAYSESSIONID = c.PAYSESSIONID
        left JOIN
             CREDIT_NOTE_LINES cl
         ON
             cl.center = c.center
             AND cl.id = c.id

         left JOIN
             PRODUCTS prod
         ON
             prod.center = cl.PRODUCTCENTER
             AND prod.id = cl.PRODUCTID
         left JOIN
             CENTERS club
         ON
             c.center = club.id
cross join params
         left JOIN
             CASHREGISTERS cr
         ON
             c.CASHREGISTER_CENTER = cr.CENTER
             AND c.CASHREGISTER_ID = cr.ID
         WHERE
             crt.CENTER = :Centre
             AND crt.transtime >= params.fromdate
             and crt.transtime < params.todate
and crt.crttype not in (16,20,10)and crt.employeecenter is not NULL  
  ) t
            
 GROUP BY
     dato,
     sales_center,
     sales_club,
     prodExternalId,
     vat_rate,
     transaction_number,
     person_id,
     crttype, 
     emp_id

    
 ORDER BY
     1,
     2 DESC,
     3
