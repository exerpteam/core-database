-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    betaler.CENTER||'p'||betaler.ID Betaler_id,
    count(paidfor.center||'p'||paidfor.id) as count_of_paid_for
FROM
   fw.PERSONS betaler
JOIN
   fw.RELATIVES rel
   ON
   betaler.CENTER   = rel.CENTER
   and betaler.ID   = rel.ID
   and rel.RTYPE = 12
JOIN
   fw.PERSONS paidfor
   ON
   paidfor.CENTER = rel.RELATIVECENTER
   and paidfor.ID = rel.RELATIVEID
WHERE
    rel.STATUS        = 1
and paidfor.status = 1 -- active
and betaler.status = 1 -- active
group by
    betaler.CENTER||'p'||betaler.ID
order by
    count(paidfor.center||'p'||paidfor.id)