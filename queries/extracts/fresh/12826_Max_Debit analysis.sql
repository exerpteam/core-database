select p.center, 
p.id, 
DECODE (P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
p.FULLNAME,
DECODE(AR_TYPE,1,'Cash',4,'Payment',5,'Debt',6,'installment') as ar_type,
AR.DEBIT_MAX,
C.NAME,
C.CITY,
C.COUNTRY
from PERSONS p, ACCOUNT_RECEIVABLES ar, centers c
where p.status not in (2,3,7,8)
and c.country = 'FI'
and AR.DEBIT_MAX=0
AND (p.center = ar.customercenter) and (p.center = c.id) and (p.id = ar.customerid)