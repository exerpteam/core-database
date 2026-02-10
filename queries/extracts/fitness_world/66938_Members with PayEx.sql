-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.CENTER ||'p'|| p.ID AS MemberID,
DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'TRANSFERRED',5,'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS STATUS
FROM
persons p

JOIN account_receivables ar 
                ON ar.customercenter = p.center 
                AND ar.customerid = p.id 
                AND ar.ar_type = 4
JOIN payment_accounts pa 
                ON pa.center = ar.center 
                AND pa.id = ar.id 
JOIN payment_agreements pag 
                ON pag.center = pa.active_agr_center
                AND pag.ID = pa.active_agr_id 
                AND pag.subid = pa.active_agr_subid 

WHERE
pag.CREDITOR_ID = 'PayEx'
AND pag.ACTIVE = 1
AND pag.STATE = 4
AND p.status not in (4,5,7,8)