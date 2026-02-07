 SELECT
     p.firstname as Firstname,
     p.lastname as Lastname,
     e.identity as PIN,
     p.SEX as Gender,
     p.center as BranchId,
     coalesce(a1.TXTVALUE, 'false') as Sunbed,
     coalesce(a2.TXTVALUE, 'false') as Disabled,
     coalesce(a3.TXTVALUE, 'false') as Water,
     'false' as Staff,
     'false' as PT,
     CASE
     WHEN p.BLACKLISTED = 0 AND p.STATUS = 1 THEN 'Live'
     WHEN p.BLACKLISTED = 2 and p.STATUS = 1 THEN 'Paused'
     WHEN p.PERSONTYPE = 2 THEN 'Staff'
     ELSE 'Removed'
     END as Status
 FROM
     persons p
 -- PIN
 LEFT JOIN ENTITYIDENTIFIERS e
 ON e.IDMETHOD = 5 and e.ENTITYSTATUS = 1 and e.REF_CENTER=p.CENTER and e.REF_ID = p.ID and e.REF_TYPE = 1
 -- Sunbed
 LEFT JOIN PERSON_EXT_ATTRS a1
 ON a1.PERSONCENTER = p.CENTER and a1.PERSONID = p.ID and a1.name ='SUNBED_ALLOWED'
 -- Disabled
 LEFT JOIN PERSON_EXT_ATTRS a2
 ON a2.PERSONCENTER = p.CENTER and a2.PERSONID = p.ID and a2.name ='DISABLED_ACCESS'
 -- Water
 LEFT JOIN PERSON_EXT_ATTRS a3
 ON a3.PERSONCENTER = p.CENTER and a3.PERSONID = p.ID and a3.name ='WATER'
 -- Specific center
 -- select * from PERSON_EXT_ATTRS
 WHERE e.IDENTITY is not null
 and (
 p.status in (1)
 or (p.status in (0) and p.PERSONTYPE in (2))
 )
 and p.BLACKLISTED in (0,2)
 and p.center in (:scope)
