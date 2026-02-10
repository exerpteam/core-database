-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
        c.name AS "Stamcenter",
		p.center ||'p'|| p.ID AS "Medlems ID",
		p.EXTERNAL_ID "External ID",
		CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARY INACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS STATUS,
        p.FULLNAME AS "Medlems navn",
        ch.NAME "Aftale type",
		Case pag.STATE When 1 Then 'Oprettet' When 2 Then 'Oprettelse sendt' When 3 Then 'Fejlet' When 4 Then 'OK' When 5 Then 'Afsluttet bank' When 6 Then 'Afsluttet PBS' When 7 Then 'Afsluttet kunde' When 8 Then 'Afmeld' When 9 Then 'Afmeldelse sendt' When 10 Then 'Afsluttet kreditor' When 13 Then 'Aftale ikke nødvendigt' When 14 Then 'Mangelfuld' Else 'Undefined' End AS "Aftale status"
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
JOIN
   RELATIVES rel
   ON
   p.CENTER = rel.RELATIVECENTER
   and p.ID = rel.RELATIVEID
WHERE 
                p.Status in (1,3)
                AND p.SEX != 'C'
				AND pag.STATE not in (4, 13)
				AND rel.RTYPE != 12
