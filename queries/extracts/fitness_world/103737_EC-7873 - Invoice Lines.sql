-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
invl.center AS "Center",
invl.person_center AS "Medlem Center",
invl.person_id::varchar(20) AS "Medlem ID",
invl.quantity AS "Antal",
invl.text AS "Tekst",
invl.product_normal_price AS "Pris",
invl.total_amount AS "I alt"
FROM
fw.invoice_lines_mt invl
WHERE
invl.person_center ||'p'|| invl.person_id IN (:memberid)