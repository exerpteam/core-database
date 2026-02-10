-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT


c.personcenter || 'p' || c.personid  AS "PERSONKEY",
p.external_id AS "External id",
p.fullname AS "Member name",
pea.txtvalue as "Allow email",
TO_CHAR(longtodateC(c.start_datetime,c.center), 'dd-mm-yyyy') AS "Debt case Start" ,
CASE WHEN CURRENTSTEP_TYPE = 0 THEN 'MESSAGE' WHEN CURRENTSTEP_TYPE = 1 THEN 'REMINDER' WHEN CURRENTSTEP_TYPE = 2 THEN 'BLOCK' WHEN CURRENTSTEP_TYPE = 3 THEN 'REQUESTANDSTOP' WHEN CURRENTSTEP_TYPE = 4 THEN 'CASHCOLLECTION' WHEN CURRENTSTEP_TYPE = 5 THEN 'CLOSE' WHEN CURRENTSTEP_TYPE = 6 THEN 'WAIT' WHEN CURRENTSTEP_TYPE = 7 THEN 'REQUESTBUYOUTANDSTOP' WHEN CURRENTSTEP_TYPE = 8 THEN 'PUSH' ELSE 'Undefined' END AS "Current debt step",
c.currentstep_date AS "Date current step set"


FROM 

persons p

INNER JOIN
cashcollectioncases c

ON

p.center = c.personcenter
AND
p.id = c.personid

Join 
person_ext_attrs pea
on
p.center = pea.personcenter
and
p.id = pea.personid

WHERE

c.closed = false
and
pea.name = '_eClub_AllowedChannelEmail'
and
pea.txtvalue = 'false'
and
c.currentstep_type != '-1'

