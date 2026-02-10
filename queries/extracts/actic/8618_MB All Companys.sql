-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    ca.CENTER || 'p' || ca.ID AS company_id,
    comp.LASTNAME AS company,
    comp.address1,
    comp.zipcode,
    comp.city,
    pea_email.txtvalue AS Email,
    pea_invoice.txtvalue AS InvoiceEmail,
    CASE ca.STATE  
        WHEN 0 THEN 'Under target'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Stop new'
        WHEN 3 THEN 'Old'
        WHEN 4 THEN 'Awaiting activation'
        WHEN 5 THEN 'Blocked'
        WHEN 6 THEN 'Deleted'
    END AS "Agreement_State",
    comp_contact.FULLNAME AS CONTACT_NAME,
    comp_contact_email.txtvalue AS CONTACT_EMAIL,
    comp_contact_phone.txtvalue AS CONTACT_PHONE,
    ca.stop_new_date,
    relation.EMP_COUNT

FROM PERSONS comp
JOIN COMPANYAGREEMENTS ca ON
	comp.CENTER = ca.CENTER 
	AND comp.ID = ca.ID
LEFT JOIN PERSON_EXT_ATTRS pea_email ON 
	pea_email.PERSONCENTER = comp.center 
	AND pea_email.PERSONID = comp.id 
	AND pea_email.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS pea_invoice ON 
	pea_invoice.PERSONCENTER = comp.center 
	AND pea_invoice.PERSONID = comp.id 
	AND pea_invoice.NAME = '_eClub_InvoiceEmail'
LEFT JOIN PERSONS comp_contact ON 
	comp_contact.CENTER = ca.CONTACTCENTER 
	AND comp_contact.ID = ca.CONTACTID
LEFT JOIN PERSON_EXT_ATTRS comp_contact_email ON 
	comp_contact_email.PERSONCENTER = comp_contact.center 
	AND comp_contact_email.PERSONID = comp_contact.id 
	AND comp_contact_email.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS comp_contact_phone ON 
	comp_contact_phone.PERSONCENTER = comp_contact.center 
	AND comp_contact_phone.PERSONID = comp_contact.id 
	AND comp_contact_phone.NAME = '_eClub_PhoneSMS'
JOIN (
    SELECT 
        rel.CENTER AS REL_CENTER,
        rel.ID AS REL_ID,
        COUNT(p.EXTERNAL_ID) AS EMP_COUNT
    FROM PERSONS p
    JOIN RELATIVES rel ON 
		rel.RELATIVECENTER = p.CENTER 
		AND rel.RELATIVEID = p.ID
    WHERE 
        p.STATUS = 1 
		AND rel.RTYPE = 2
    GROUP BY 
		rel.CENTER, 
		rel.ID
) relation ON 
	relation.REL_CENTER = ca.CENTER 
	AND relation.REL_ID = ca.ID
WHERE
    ca.center in (:scope)
	AND ca.state IN (:Agreement_State)

