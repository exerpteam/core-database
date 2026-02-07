-- This is the version from 2026-02-05
--  
SELECT
    CI.NAME                            AS SALES_CENTER,
    PP.CENTER || 'p' || PP.ID          AS CUSTOMER_ID,
	pp.external_id						AS ExternalID,
    PP.FIRSTNAME || ' ' || PP.LASTNAME AS CUSTOMER,
    P.NAME                             AS PRODUCT,
    c.CLIPS_LEFT                       AS clipsremaining,
    c.CLIPS_INITIAL                    AS initialclip,
    longtodateC(i.trans_time, i.center) as SALES_DAY,
to_char(longtodate(c.valid_until),'dd-mm-yyyy')				as udløbsdato
FROM
     fw.INVOICES I
JOIN fw.INVOICELINES IL
ON
    I.CENTER=IL.CENTER
AND I.ID=IL.ID
JOIN fw.PRODUCTS P
ON
    IL.PRODUCTCENTER=P.CENTER
AND IL.PRODUCTID=P.ID
JOIN fw.CLIPCARDS C
ON
    IL.CENTER=C.INVOICELINE_CENTER
AND IL.ID=C.INVOICELINE_ID
AND IL.SUBID=C.INVOICELINE_SUBID
JOIN fw.PERSONS PP
ON
    C.OWNER_CENTER=PP.CENTER
AND C.OWNER_ID=PP.ID
JOIN fw.CENTERS CI
ON
    I.CENTER=CI.ID
WHERE
P.PTYPE=4 AND
C.INVOICELINE_CENTER IN (:scope)
--and c.finished = 0
order by
    CI.NAME