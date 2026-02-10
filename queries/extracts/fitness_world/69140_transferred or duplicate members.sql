-- The extract is extracted from Exerp on 2026-02-08
--  
select
p.CENTER ||'p'|| p.ID AS "Old member ID",
p.CURRENT_PERSON_CENTER ||'p'|| p.CURRENT_PERSON_ID AS "Current member ID",
decode(p.status,0,'Lead',1,'Active',2,'Inactive',3,'TemporaryInactive',4,'Transferred',5,'Duplicate',6,'Prospect',7,'Deleted',8,'Anonymized',9,'Contact','Undefined') AS "Person status"
from persons p
where
p.status in (4,5)
AND p.CURRENT_PERSON_CENTER in (:scope)
Order by
p.CURRENT_PERSON_CENTER,
p.CURRENT_PERSON_ID