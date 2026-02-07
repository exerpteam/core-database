-- This is the version from 2026-02-05
--  
SELECT
p.center || 'p' || p.id as "Membership number",
-- pea.TXTVALUE AS "SSN accept",
staffp.fullname as "Last change to SSNGDPRACCEPT set by",
decode(p.status,0,'Lead',1,'Active',2,'Inactive',3,'TemporaryInactive',4,'Transferred',5,'Duplicate',6,'Prospect',7,'Deleted',8,'Anonymized',9,'Contact','Undefined') AS "Member state",
longtodate(pcl.ENTRY_TIME) as "Date of last change to SSNGDPRACCEPT",
-- p.FIRST_ACTIVE_START_DATE as "Subscription creation date",
TO_CHAR(to_date(peac.TXTVALUE,'YYYY-MM-DD'),'dd-MM-yyyy') AS "Person creation date"



FROM
Persons p
JOIN
   Person_Ext_Attrs pea
ON
 p.center = pea.personcenter
AND
p.id = pea.personid

join
PERSON_CHANGE_LOGS pcl
on
p.center = pcl.person_center
and
p.id = pcl.person_id
and
pea.name = pcl.CHANGE_ATTRIBUTE

left join
 Person_Ext_Attrs peac
ON
 p.center = peac.personcenter
AND
p.id = peac.personid
and peac.name = 'CREATION_DATE'

LEFT JOIN employees staff
ON
    pcl.EMPLOYEE_CENTER = staff.center
    AND pcl.EMPLOYEE_ID = staff.id
LEFT JOIN persons staffp
ON
    staff.personcenter = staffp.center
    AND staff.personid = staffp.id

WHERE
pea.name = 'SSNGDPRACCEPT'
and
pea.TXTVALUE is not NULL
and
pea.TXTVALUE = 'false'

and p.center in (:scope)

and p.ssn is not null

AND NOT EXISTS 
 (
        SELECT
            *
FROM
PERSON_CHANGE_LOGS pcl

WHERE
p.center = pcl.person_center
and
p.id = pcl.person_id
and
pea.name = pcl.CHANGE_ATTRIBUTE
and
pcl.PREVIOUS_ENTRY_ID is not null)

