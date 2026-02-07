-- This is the version from 2026-02-05
--  
SELECT
ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID as MEMBERID,
P.FULLNAME,
p.EXTERNAL_ID,
DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARY INACTIVE',4,'TRANSFERRED',5,'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS STATUS,
DECODE ( p.PERSONTYPE,
0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE',
6, 'FAMILY', 7,'SENIOR', 8,'GUEST', 10, 'EXTERNAL STAFF','UNKNOWN') AS "PERSON TYPE",
longtodate(art.ENTRY_TIME)as entrydate,
art.text,
art.amount,
ar.BALANCE,
DECODE(ar.AR_TYPE,1,'CASH ACCOUNT',4,'PAYMENT ACCOUNT',5,'DEBT ACCOUNT','Undefined') AS "ACCOUNT TYPE"
FROM
ACCOUNT_RECEIVABLES ar
JOIN
AR_TRANS art
on
art.center = ar.center
and
art.id = ar.id

JOIN
persons p
ON
ar.customercenter = p.center
AND ar.customerid = p.id
WHERE
--ar.BALANCE <= 0
ar.AR_TYPE in (1)
And (p.center,p.id) in (:memberid)
AND p.sex != 'C'
and art.ENTRY_TIME > :cutdate
and art.amount < 0
ORDER BY memberid