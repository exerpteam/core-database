SELECT
    ei.identity,
    p.globalid,
    p.name
FROM
     sats.ENTITYIDENTIFIERS EI
join sats.products p
on   ei.globalid = p.globalid 
WHERE
    EI.REFERENCETYPE IN (3,4) /* 3= Local Product, 4 = Global Product */
AND EI.IDMETHOD = 1 /* 1 = BARCODE */
/*and ei.identity in  (:barcode )*/
group by
    ei.identity,
    p.globalid,
    p.name
order by
    globalid