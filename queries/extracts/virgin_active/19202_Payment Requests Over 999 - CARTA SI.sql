-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         Pr.REQ_DATE,
     ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID person,
     pr.REQ_AMOUNT,
         CR.NAME
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     ACCOUNT_RECEIVABLES ar
 JOIN
     PERSONS p
         ON ar.CUSTOMERCENTER = p.CENTER
                 AND ar.CUSTOMERID = p.ID
         ON ar.CENTER = pr.CENTER
                 AND ar.ID = pr.ID
 JOIN
         clearinghouses cr
         ON pr.CLEARINGHOUSE_ID = cr.ID
 WHERE
         pr.REQ_AMOUNT > 999
 AND
         pr.REQ_DATE = $$PaymentDate$$
 AND
         p.sex <> 'C'
 AND
         cr.name like '%Carta%'
 ORDER BY
     pr.REQ_AMOUNT desc
