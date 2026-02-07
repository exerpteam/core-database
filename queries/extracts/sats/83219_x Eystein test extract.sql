SELECT 
    ar.CUSTOMERCENTER AS CENTER,
    ar.CUSTOMERID AS ID,
    prs.center AS PRS_CENTER,
    prs.id AS PRS_ID,
prs.*
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
join ACCOUNT_RECEIVABLES ar
    on
    prs.center = ar.center
    AND prs.id = ar.id
WHERE
    prs.TOTAL_INVOICE_AMOUNT<=0
AND prs.center = 500
AND ENTRY_TIME BETWEEN  :fromdate AND :toDate 