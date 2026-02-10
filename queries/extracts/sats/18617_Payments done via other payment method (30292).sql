-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 TO_CHAR(longToDate(crt.TRANSTIME),'yyyy-mm-dd') "DATE",
 longToDate(crt.TRANSTIME) transaction_time,
 crt.AMOUNT,
 emp.CENTER || 'emp' || emp.ID empEMPid,
 p.CENTER || 'p' || p.ID empPid,
 p.FIRSTNAME || ' ' || p.LASTNAME EMP_NAME,
 cust.CENTER || 'p' || cust.ID cust_p_id,
 cust.FIRSTNAME || ' ' || cust.LASTNAME CUST_NAME,
 crt.CONFIG_PAYMENT_METHOD_ID,
 crt.CENTER CENTER_ID,
 crt.ID cash_register_id,
 c.NAME CENTER_NAME
 FROM
      CASHREGISTERTRANSACTIONS crt
 JOIN EMPLOYEES emp
 ON
 emp.CENTER = crt.EMPLOYEECENTER
 AND emp.ID = crt.EMPLOYEEID
 JOIN PERSONS p
 ON
 p.CENTER = emp.PERSONCENTER
 AND p.ID = emp.PERSONID
 JOIN CENTERS c
 ON
 c.ID = crt.CENTER
 LEFT JOIN PERSONS cust
 ON
 cust.CENTER = crt.CUSTOMERCENTER
 AND cust.ID = crt.CUSTOMERID
 WHERE
 crt.CENTER in (:scope)
 AND crt.TRANSTIME BETWEEN :transBegin AND :transEnd
 AND crt.CRTTYPE = 13
 ORDER BY
 crt.TRANSTIME DESC
