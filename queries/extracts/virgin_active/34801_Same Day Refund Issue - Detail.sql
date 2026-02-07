SELECT
    longtodatec(cn.ENTRY_TIME,cn.CENTER)      AS entrytime,
    cn.EMPLOYEE_CENTER||'emp'||cn.EMPLOYEE_ID AS emp,
    p.FULLNAME                                AS emp_name,
    cn.PAYER_CENTER||'p'||cn.PAYER_ID         AS payer_id,
    cnl.total_amount                          AS credit_note_amount,
    i.TEXT                                    AS invoice_text,
    cn.TEXT                                   AS credit_note_text,
    cn.COMENT                                 AS credit_note_comment,
    cnl.text                                  AS credit_note_line_text
FROM
    CREDIT_NOTES cn
LEFT JOIN
    INVOICES i
ON
    i.CENTER = cn.INVOICE_CENTER
    AND i.id = cn.INVOICE_ID
LEFT JOIN
    AR_TRANS art
ON
    art.REF_CENTER = cn.CENTER
    AND art.REF_ID = cn.id
    AND art.REF_TYPE = 'CREDIT_NOTE'
LEFT JOIN
    invoicelines il
ON
    i.CENTER = il.CENTER
    AND i.id = il.id
LEFT JOIN
    VA.CREDIT_NOTE_LINES_MT cnl
ON
    cnl.center = cn.center
    AND cnl.id = cn.id
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = cn.EMPLOYEE_CENTER
    AND emp.id = cn.EMPLOYEE_ID
JOIN
    persons p
ON
    p.CENTER = emp.PERSONCENTER
    AND emp.PERSONID = p.id
JOIN
    CASHREGISTERS cr
ON
    cr.id = cn.CASHREGISTER_ID
    AND cr.CENTER = cn.CASHREGISTER_CENTER
LEFT JOIN
    CASHREGISTERTRANSACTIONS crr
ON
    crr.CENTER = cr.CENTER
    AND crr.ID = cr.id
    AND crr.CUSTOMERCENTER = cn.PAYER_CENTER
    AND crr.CUSTOMERID = cn.PAYER_ID
    AND cn.EMPLOYEE_CENTER = crr.EMPLOYEECENTER
    AND cn.EMPLOYEE_ID = crr.EMPLOYEEID
    AND cn.PAYSESSIONID = crr.PAYSESSIONID
JOIN
    centers c
ON
    c.id = p.center
WHERE
    1=1
    AND art.id IS NULL
    AND cn.CASH = 0
    AND cn.PAYSESSIONID IS NULL
    AND c.country = ($$country$$)
    AND (
        cn.ENTRY_TIME > datetolongc('2018-02-21 00:05' , cn.CENTER) )
ORDER BY
    cn.CASHREGISTER_CENTER,
    entrytime DESC