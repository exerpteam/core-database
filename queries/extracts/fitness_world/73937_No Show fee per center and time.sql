-- This is the version from 2026-02-05
--  
SELECT DISTINCT
inv.PAYER_CENTER || 'p' || inv.PAYER_ID payer_id,
curr_p1.EXTERNAL_ID payer_external_id,
invl.PERSON_CENTER || 'p' || invl.PERSON_ID person_id,
curr_p2.EXTERNAL_ID person_external_id,
to_char(longtodate(inv.TRANS_TIME),'DD-MM-YYYY HH24:MI') TRANSACTION_TIME,
prod.NAME,
cl.checkin_center
FROM
FW.INVOICELINES invl
JOIN FW.INVOICES inv
ON
inv.CENTER = invl.CENTER
AND inv.ID = invl.ID
JOIN FW.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN checkin_log cl
ON
	invl.PERSON_CENTER = cl.CENTER
AND	invl.PERSON_ID = cl.ID
JOIN PERSONS p1
ON inv.PAYER_CENTER = p1.CENTER AND inv.PAYER_ID = p1.ID
JOIN PERSONS curr_p1
ON p1.CURRENT_PERSON_CENTER = curr_p1.CENTER AND p1.CURRENT_PERSON_ID = curr_p1.ID
JOIN PERSONS p2
ON invl.PERSON_CENTER = p2.CENTER AND invl.PERSON_ID = p2.ID
JOIN PERSONS curr_p2
ON p2.CURRENT_PERSON_CENTER = curr_p2.CENTER AND p2.CURRENT_PERSON_ID = curr_p2.ID
WHERE
prod.GLOBALID IN ('NO_SHOW_FEE') AND inv.TRANS_TIME between (:StartDate) and (:EndDate)
AND inv.PAYER_CENTER in (:Person_homecenter)