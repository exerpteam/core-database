SELECT
    longToDate(crt.TRANSTIME) transaction_time,
    crt.AMOUNT,
    emp.CENTER || 'emp' || emp.ID empEMPid,
    p.CENTER || 'p' || p.ID empPid,
    p.FIRSTNAME || ' ' || p.LASTNAME EMP_NAME,
    crt.CONFIG_PAYMENT_METHOD_ID,
    crt.CENTER CENTER_ID,
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
WHERE
     crt.CENTER IN (:scope)
 AND crt.TRANSTIME BETWEEN :from_date and :end_date
 AND crt.CRTTYPE = 13

crt.CONFIG_PAYMENT_METHOD_ID =2


ORDER BY
    crt.TRANSTIME DESC