-- The extract is extracted from Exerp on 2026-02-08
--  
select 
	PA.PERSONCENTER,
	PA.PERSONID,
	PA.PERSONCENTER,
	PA.NAME AS "EXT ATT",
	PA.TXTVALUE,
	TO_CHAR(longtodateC(PA.LAST_EDIT_TIME, p.CENTER),'YYYY-MM-DD HH24:MI:SS') AS "EXT ATT LAST UPDATE",
	p.FULLNAME AS PERSON_NAME,
	CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS PERSON_STATUS,
    CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
    pem.txtvalue AS email,
	pea1.txtvalue AS homephone,
	pea2.txtvalue AS mobilephone
		from PERSONS P 
join PERSON_EXT_ATTRS PA 
	on PA.personcenter = P.center 
	and PA.personid=P.id

		

left join PERSON_EXT_ATTRS pem on pem.personcenter = p.center and pem.personid = p.id and pem.name = '_eClub_Email' 
left join PERSON_EXT_ATTRS pea1 on pea1.personcenter = p.center and pea1.personid = p.id and pea1.name = '_eClub_PhoneHome'
left join PERSON_EXT_ATTRS pea2 on pea2.personcenter = p.center and pea2.personid = p.id and pea2.name = '_eClub_PhoneSMS'

WHERE 
	P.center IN (:center) 
    AND PA.NAME IN (:Person_Ext_Attributes)
 	AND P.STATUS IN ( :PersonStatus )
	AND PA.TXTVALUE IS NOT NULL