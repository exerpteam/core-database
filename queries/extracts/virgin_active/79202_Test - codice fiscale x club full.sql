-- The extract is extracted from Exerp on 2026-02-08
--  
 select
 p.center||'p'||p.id as MEMBER_ID,
 p.ssn AS MEMBER_SSN,
 case  p.status  when 0 then 'Lead'  when 1 then 'Active'  when 2 then 'Inactive'  when 3 then 'Temporary Inactive'  when 4 then 'Transfered'  when 5 then 'Duplicate'  when 6 then 'Prospect'  when 7 then 'Deleted' when 8 then  'Anonymized'  when 9 then  'Contact'  else 'Unknown' end as "Person status"
 from persons p
 where p.status in ($$PersonStatus$$) and p.center = :centerId
