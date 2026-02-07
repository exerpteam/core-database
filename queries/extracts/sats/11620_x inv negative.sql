SELECT ar.CUSTOMERCENTER, ar.CUSTOMERID
FROM ACCOUNT_RECEIVABLES ar

join PAYMENT_REQUEST_SPECIFICATIONS prs on
prs.center = ar.center and
prs.id = ar.id and
WHERE 
prs.TOTAL_INVOICE_AMOUNT<=0  and
prs.center >  499 and
prs.center < 601 and


prs.ENTRY_TIME BETWEEN  :fromdate AND 
:todate 