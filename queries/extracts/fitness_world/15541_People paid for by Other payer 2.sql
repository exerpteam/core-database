-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    betaler.CENTER||'p'||betaler.ID Betaler_id,
	betaler.external_id as Betaler_ex_id,
    paidfor.center||'p'||paidfor.id as paid_for,
	paidfor.external_id as paidfor_ex_id
FROM
   PERSONS betaler
JOIN
   RELATIVES rel
   ON
   betaler.CENTER   = rel.CENTER
   and betaler.ID   = rel.ID
   and rel.RTYPE = 12
JOIN
   PERSONS paidfor
   ON
   paidfor.CENTER = rel.RELATIVECENTER
   and paidfor.ID = rel.RELATIVEID
WHERE
rel.STATUS        = 1
and paidfor.status = 1 -- active
--and betaler.status = 1 -- active
order by
    betaler.CENTER||'p'||betaler.ID
