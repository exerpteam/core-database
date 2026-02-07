Select
p.external_id as "Exernal ID",
p.center ||'p'|| p.id as "Member ID",
pr.globalid as "Gift Card global ID",
pr.name as "Gift Card Product name",
gc.center ||'gc'|| gc.id as "Gift card key",
ei.identity as "Card ID",
CASE ei.IDMETHOD WHEN 1 THEN 'BARCODE' WHEN 2 THEN 'MAGNETIC_CARD' WHEN 3 THEN 'SSN' WHEN 4 THEN 'RFID_CARD' WHEN 5 THEN 'PIN' WHEN 6 THEN 'ANTI DROWN' WHEN 7 THEN 'QRCODE' ELSE 'Undefined' END AS "Card Type",
longtodatec(gc.purchase_time, c.id ) as "Valid from date",
gc.expirationdate as "Valid to date",
gc.amount as "Gift card start value" ,
gc.amount_remaining as "Gift card remaining value"

from gift_cards gc

join persons p
on
gc.payer_center = p.center
and
gc.payer_id = p.id

join centers c
on c.id = p.center

join  products pr
on gc.product_center = pr.center
and
gc.product_id = pr.id

join entityidentifiers ei
on
ei.ref_center = gc.center
and
ei.ref_id = gc.id
and ref_type = 5



where 
p.external_id in (:externalid)