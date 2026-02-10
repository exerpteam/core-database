-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TO_CHAR(longtodatec(cn.ENTRY_TIME,cn.CENTER),'YYYY-MM-DD')      AS entrytime,
    cn.EMPLOYEE_CENTER||'emp'||cn.EMPLOYEE_ID AS emp,
    p.FULLNAME                                AS emp_name,
    cn.PAYER_CENTER||'p'||cn.PAYER_ID         AS payer_id,
    cnl.total_amount                          AS credit_note_amount,
    i.TEXT                                    AS invoice_text,
    cn.TEXT                                   AS credit_note_text,
    cn.COMENT                                 AS credit_note_comment,
    cnl.text                                  AS credit_note_line_text
FROM
    goodlife.credit_notes cn
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
    goodlife.invoice_lines_mt il
ON
    i.CENTER = il.CENTER
    AND i.id = il.id
LEFT JOIN
    goodlife.credit_note_lines_mt cnl
ON
    cnl.center = cn.center
    AND cnl.id = cn.id
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = cn.EMPLOYEE_CENTER
    AND emp.id = cn.EMPLOYEE_ID
LEFT JOIN
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
WHERE
    1=1
    AND art.id IS NULL
    AND cn.CASH = 0
    AND cn.PAYSESSIONID IS NULL
    AND (
        cn.ENTRY_TIME > datetolongc('2018-03-01 00:05' , cn.CENTER) )
ORDER BY
    cn.CASHREGISTER_CENTER,
    entrytime DESC