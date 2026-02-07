-- This is the version from 2026-02-05
--  
SELECT 
c.name AS "Stamcenter",
p.center||'p'||p.ID "Medlems ID",
p.FULLNAME AS "Medlems navn",
decode(p.status,0,'Lead',1,'Active',2,'Inactive',3,'TemporaryInactive',4,'Transferred',5,'Duplicate',6,'Prospect',7,'Deleted',8,'Anonymized',9,'Contact','Undefined') AS "Person status",
ch.NAME "Aftale type",
Decode(pag.STATE,1,'Oprettet',2,'Oprettelse sendt',3,'Fejlet',4,'OK',5,'Afsluttet bank',6,'Afsluttet PBS',7,'Afsluttet kunde',8,'Afmeld',9,'Afmeldelse sendt',10,'Afsluttet kreditor',13,'Aftale ikke nødvendigt',14,'Mangelfuld','Undefined') AS "Aftale status"
FROM persons p
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
JOIN CENTERS c 
                ON c.ID = p.Center
JOIN CLEARINGHOUSES ch 
                ON ch.ID = pag.clearinghouse
WHERE 
                p.Status in (1,3,9)
                AND p.SEX != 'C'
                AND p.Center in (:Scope)
