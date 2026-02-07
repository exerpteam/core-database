SELECT
        invl.center AS "Center",
        invl.person_center AS "Member Center",
        CAST(invl.person_id AS TEXT) AS "Member ID",
        invl.quantity AS "Number",
        invl.text AS "Text",
        invl.product_normal_price AS "Price",
        invl.total_amount AS "Total"
FROM invoice_lines_mt invl
WHERE
        (invl.person_center,invl.person_id) IN (:memberid)