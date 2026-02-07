SELECT * FROM
FROM
    INVOICES inv
LEFT JOIN AR_TRANS art
ON
     art.REF_CENTER = inv.CENTER
    AND art.REF_ID = inv.ID


WHERE 

rownum <= 10
