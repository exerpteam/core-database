-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    ca.CENTER || 'p' || ca.ID  || 'rpt'||ca.SUBID AS company_id,
	ca.NAME,
    comp.LASTNAME AS company,
    comp.address1,
    comp.zipcode,
    comp.city,
   /* pea_email.txtvalue AS Email,
    pea_invoice.txtvalue AS InvoiceEmail,*/
    CASE ca.STATE  
        WHEN 0 THEN 'Under target'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Stop new'
        WHEN 3 THEN 'Old'
        WHEN 4 THEN 'Awaiting activation'
        WHEN 5 THEN 'Blocked'
        WHEN 6 THEN 'Deleted'
    END AS "Agreement_State",

	/*comp_contact.FULLNAME AS CONTACT_NAME,
    comp_contact_email.txtvalue AS CONTACT_EMAIL,
    comp_contact_phone.txtvalue AS CONTACT_PHONE,*/

    ca.stop_new_date,
    relation.EMP_COUNT

FROM PERSONS comp
JOIN COMPANYAGREEMENTS ca ON
	comp.CENTER = ca.CENTER 
	AND comp.ID = ca.ID
/*LEFT JOIN PERSON_EXT_ATTRS pea_email ON 
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
	AND comp_contact_phone.NAME = '_eClub_PhoneSMS'*/
JOIN (
    SELECT 
		rel.RELATIVECENTER AS REL_CENTER,
		rel.RELATIVEID AS REL_ID,
		rel.RELATIVESUBID AS REL_SUBID,
		COUNT(p.EXTERNAL_ID) AS EMP_COUNT
	FROM RELATIVES rel
	
    JOIN PERSONS p ON 
		rel.CENTER = p.CENTER 
		AND rel.ID = p.ID
    WHERE  
		rel.RTYPE = 3
		AND p.STATUS = 1
		AND p.PERSONTYPE = 4
	GROUP BY 
		rel.RELATIVECENTER,
		rel.RELATIVEID,
		rel.RELATIVESUBID
) relation ON 
	relation.REL_CENTER = ca.CENTER
	AND relation.REL_ID = ca.ID
	AND relation.REL_SUBID = ca.SUBID
WHERE 	
    ca.center in (:scope)
	AND ca.state IN (:Agreement_State)
