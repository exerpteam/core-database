-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
cn.center AS "Center",
TO_CHAR(longtodateC(cn.trans_time, cn.center), 'dd-MM-YYYY') AS "Transaktionsdato",
cn.payer_center AS "Member Center",
cn.payer_id::varchar(20) AS "Member ID",
cn.text AS "Tekst",
cn.invoice_center AS "Faktura Center",
cn.invoice_id::varchar(20) AS "Faktura ID",
cn.coment AS "Kommentar"
FROM
credit_notes cn
WHERE
cn.payer_center ||'p'|| cn.payer_id IN (:memberid)