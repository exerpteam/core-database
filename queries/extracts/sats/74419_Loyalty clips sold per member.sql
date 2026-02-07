SELECT
p.CENTER || 'p' || p.ID "member ID",
prod.GLOBALID product,
prod.name AS product_name,                          
staffp.fullname                                                                              AS Sales_staff_name,
    to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') as "Sales Date",
    to_char(longtodate(inv.TRANS_TIME),'HH24:MI') as "Sales Time",
att.txtvalue as "Loyalty level",
longtodate(pcl.ENTRY_TIME) as "Level change date"
FROM
        INVOICES inv
JOIN INVOICELINES invl
ON	
    invl.CENTER = inv.CENTER
    AND invl.id = inv.iD
JOIN PERSONS p
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
left join PERSON_EXT_ATTRS Att
on
p.center = att.personcenter
and
p.id = att.personid
AND att.NAME = 'UNBROKENMEMBERSHIPGROUPSE'

left join
PERSON_CHANGE_LOGS pcl
on
p.center = pcl.person_center
and
p.id = pcl.person_id
and
att.name = pcl.CHANGE_ATTRIBUTE
and
pcl.NEW_VALUE = att.txtvalue

WHERE
p.external_id IN (:externalid)    

    --AND productGroup.SHOW_IN_SHOP = 1
    AND NOT EXISTS
    (
        SELECT
            *
        FROM
            CREDIT_NOTE_LINES cnl
        WHERE
            cnl.INVOICELINE_CENTER = invl.CENTER
            AND cnl.INVOICELINE_ID = invl.id
            AND cnl.INVOICELINE_SUBID = invl.SUBID
    )
	and prod.PTYPE = '4'
and (prod.GLOBALID = 'PT60LEVEL1_LOYALTY_CLIP' or
prod.GLOBALID = 'PT60LEVEL2_LOYALTY_CLIP' or
prod.GLOBALID = 'PT60LEVEL3_LOYALTY_CLIP' or
prod.GLOBALID = 'PT60LEVEL4_LOYALTY_CLIP')