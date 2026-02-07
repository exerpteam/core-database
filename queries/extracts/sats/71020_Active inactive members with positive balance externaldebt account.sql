SELECT ar.CUSTOMERCENTER, 
ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID as memberid,
p.firstname,
p.lastname, 
ar.BALANCE, 
decode(ar.AR_TYPE,5,'debt account') as ar_account
FROM ACCOUNT_RECEIVABLES ar
join persons p on p.id = ar.CUSTOMERId and p.center = ar.CUSTOMERCENTER 
WHERE ar.BALANCE > 0 
AND ar.AR_TYPE = 5
AND AR.CENTER BETWEEN :FromCenter AND :ToCenter
AND P.STATUS IN(1,2,3,4,5,6)
order by ar.balance