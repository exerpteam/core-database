SELECT * FROM PERSONS p
JOIN PERSON_EXT_ATTRS ext

ON p.center = ext.personcenter 
and p.id = ext.personid 
where ext.TXTVALUE like '%anna.aahlin@gmail.com%'