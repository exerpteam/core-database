-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
cc.OWNER_CENTER || 'p' || cc.OWNER_ID pid,
pp.external_id,
longtodateC(i.trans_time, i.center) as SALES_DAY,
cc.CLIPS_INITIAL,
cc.CLIPS_LEFT,
prod.NAME,
invl.TOTAL_AMOUNT,
invl.QUANTITY,
pea.TXTVALUE as AcceptingNewsletter
FROM
CLIPCARDS cc
JOIN INVOICELINES invl
ON
invl.CENTER = cc.INVOICELINE_CENTER
AND invl.ID = cc.INVOICELINE_ID
AND invl.SUBID = cc.INVOICELINE_SUBID
JOIN PRODUCTS prod
ON
prod.CENTER = invl.PRODUCTCENTER
AND prod.ID = invl.PRODUCTID
JOIN INVOICES inv
ON
inv.CENTER = invl.CENTER
AND inv.ID = invl.ID
JOIN fw.PERSONS PP
ON Cc.OWNER_CENTER=PP.CENTER
AND cc.owner_id=pp.ID
Join Invoices I
on I.CENTER=invl.CENTER and I.ID=INVL.ID
JOIN PERSON_EXT_ATTRS pea
ON pp.CENTER = pea.PERSONCENTER
AND pp.ID = pea.PERSONID
AND inv.TRANS_TIME BETWEEN :dateFrom AND :dateTo
AND invl.CENTER IN (:scope)
AND prod.name = 'Værdikupon - Dagspas / prøvetime'
AND pea.NAME = 'eClubIsAcceptingEmailNewsLetters'