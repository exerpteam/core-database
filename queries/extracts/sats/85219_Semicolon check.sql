SELECT
        p.fullname,
        p.center||'p'||p.id AS member_key,
        p.address1,
        p.address2,
        p.external_id,
        case p.sex when 'C' then 'COMPANY' WHEN 'M' THEN 'MALE' WHEN 'F' THEN 'FEMALE' ELSE 'OTHER' end as gender_company,
        CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,   
        p.current_person_center||'p'||p.current_person_id AS current_member_key  
   FROM
        persons p
  WHERE
        (p.fullname LIKE '%;%' or p.address1 like '%;%' or p.address2 like '%;%') 
 and p.status not in (4,7)       
        
ORDER BY
        p.last_modified DESC