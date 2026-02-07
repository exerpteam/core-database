SELECT 
	p.center||'p'||p.id AS "PersonID"
	,CASE 
	       WHEN p.PERSONTYPE = 0 THEN 'PRIVATE' 
	       WHEN p.PERSONTYPE = 1 THEN 'STUDENT' 
	       WHEN p.PERSONTYPE = 2 THEN 'STAFF' 
	       WHEN p.PERSONTYPE = 3 THEN 'FRIEND' 
	       WHEN p.PERSONTYPE = 4 THEN 'CORPORATE' 
	       WHEN p.PERSONTYPE = 5 THEN 'ONEMANCORPORATE' 
	       WHEN p.PERSONTYPE = 6 THEN 'FAMILY' 
	       WHEN p.PERSONTYPE = 7 THEN 'SENIOR' 
	       WHEN p.PERSONTYPE = 8 THEN 'GUEST' 
	       WHEN p.PERSONTYPE = 9 THEN 'CHILD' 
	       WHEN p.PERSONTYPE = 10 THEN 'EXTERNAL_STAFF' 
	       ELSE 'Undefined' 
        END AS "Person Type"
	,CASE 
	       WHEN p.STATUS = 0 THEN 'LEAD' 
	       WHEN p.STATUS = 1 THEN 'ACTIVE' 
	       WHEN p.STATUS = 2 THEN 'INACTIVE' 
	       WHEN p.STATUS = 3 THEN 'TEMPORARYINACTIVE' 
	       WHEN p.STATUS = 4 THEN 'TRANSFERRED' 
	       WHEN p.STATUS = 5 THEN 'DUPLICATE' 
	       WHEN p.STATUS = 6 THEN 'PROSPECT' 
	       WHEN p.STATUS = 7 THEN 'DELETED' 
	       WHEN p.STATUS = 8 THEN 'ANONYMIZED' 
	       WHEN p.STATUS = 9 THEN 'CONTACT' 
	       ELSE 'Undefined' END AS "Person Status"
	,ext.txtvalue AS "24/7 value"
FROM 
        persons p
LEFT JOIN 
        person_ext_attrs ext
        ON ext.personcenter = p.center
        AND ext.personid = p.id
        AND ext.name like 'TWENTY4HOURACCESS%'
WHERE 
        p.center in (:Scope)
