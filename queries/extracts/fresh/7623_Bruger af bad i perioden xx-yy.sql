SELECT
    i.payer_center,

    i.ID

FROM
    invoices i
JOIN invoicelines il
ON
    i.id = il.id
JOIN products p
ON
    il.productcenter = p.center
    AND il.productid = p.id
WHERE
    i.trans_time >= :purchase_from
    AND i.trans_time <= :purchase_to +1
    /*day not included*/
    AND p.globalid = 'SHOWER_USAGE'

ORDER BY
    i.payer_center