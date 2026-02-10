-- The extract is extracted from Exerp on 2026-02-08
-- EC-7617
SELECT
inv.center,
invl.quantity,
invl.total_amount,
TO_CHAR(longtodateTZ(inv.trans_time, 'Europe/Copenhagen'),'YYYY-MM-DD ') AS "Salesdate",
invl.text
FROM
    INVOICELINES invl
JOIN INVOICES inv
ON
    invl.CENTER = inv.CENTER
    AND invl.id = inv.id
LEFT JOIN PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN CENTERS c
ON
    c.id = invl.CENTER
JOIN PRODUCTS prod
ON
    prod.ID = invl.PRODUCTID
    AND prod.CENTER = invl.PRODUCTCENTER
JOIN PRODUCT_GROUP productGroup
ON
    prod.PRIMARY_PRODUCT_GROUP_ID = productGroup.id
LEFT JOIN employees staff
ON
    inv.EMPLOYEE_CENTER = staff.center
    AND inv.EMPLOYEE_ID = staff.id
LEFT JOIN persons staffp
ON
    staff.personcenter = staffp.center
    AND staff.personid = staffp.id
LEFT JOIN CASHREGISTERS cr
ON 
    inv.CASHREGISTER_CENTER = cr.CENTER
    AND inv.CASHREGISTER_ID = cr.ID
WHERE 
prod.globalid IN ('RENT_OF_BADMINTONCOURT_NEW', 'RENT_OF_BADMINTONCOUR_NEW2', 'RENT  OF BADMINTONCOURT', 'RENT_OF_TENNISCOURT2_NEW', 'RENT_OF_TENNISCOURT2', 'RENT INDOORHOCKEYCOURT', 'RENT OF TENNISCOURT', 'TEAM_SPORT2')
AND invl.center in (:scope)
