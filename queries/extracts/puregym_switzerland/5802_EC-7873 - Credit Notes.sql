SELECT
        cn.center AS "Center",
        TO_CHAR(longtodateC(cn.trans_time, cn.center), 'dd-MM-YYYY') AS "Transaction date",
        cn.payer_center AS "Member Center",
        CAST(cn.payer_id AS TEXT) AS "Member ID",
        cn.text AS "Text",
        cn.invoice_center AS "Invoicing Center",
        CAST(cn.invoice_id AS TEXT) AS "Invoice ID",
        cn.coment AS "Comment"
FROM credit_notes cn
WHERE
        (cn.payer_center,cn.payer_id) IN (:memberid) 