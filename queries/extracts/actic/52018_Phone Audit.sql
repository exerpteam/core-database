-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT --count(*) as count
    pea.personcenter||'p'||pea.personid as member, pea.name as field, txtvalue as phone,    
    CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS STATUS

    
FROM
    PERSON_EXT_ATTRS pea
    
    
    join persons p on pea.personcenter = p.center and pea.personid = p.id
    
WHERE

pea.name in ('_eClub_PhoneSMS','_eClub_PhoneWork')
and txtvalue is not null
--and txtvalue like '&+46'
--and txtvalue like '0000%'
and txtvalue in ('+46700000')
--and p.status not in (4,5,7,8) --4 transferred, 5 duplicated, 7 deleted, 8 anonymized
