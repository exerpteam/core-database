select 
p.CENTER ||'p'|| p.ID as PERSONID,
p.FULLNAME as FULLNAME,
DECODE(AR_TYPE,1,'Cash',4,'Payment',5,'Debt',6,'installment') as ACCOUNTTYPE,
ar.BALANCE as BALANCE
from PERSONS p
left join ACCOUNT_RECEIVABLES ar
on p.CENTER = ar.CUSTOMERCENTER and p.ID = ar.CUSTOMERID
where ar.BALANCE != 0
and p.SEX != 'C'