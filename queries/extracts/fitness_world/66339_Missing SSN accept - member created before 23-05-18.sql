-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.center || 'p' || p.id as "Membership number",
-- pea.TXTVALUE AS "SSN accept",
staffp.fullname as "Last change to SSNGDPRACCEPT set by",
case p.status when 0 then 'Lead' when 1 then 'Active' when 2 then 'Inactive' when 3 then 'TemporaryInactive' when 4 then 'Transferred' when 5 then 'Duplicate' when 6 then 'Prospect' when 7 then 'Deleted' when 8 then 'Anonymized' when 9 then 'Contact' else 'Undefined' end AS "Member state",
longtodate(pcl.ENTRY_TIME) as "Date of last change to SSNGDPRACCEPT",
-- p.FIRST_ACTIVE_START_DATE as "Subscription creation date",
TO_DATE(peac.TXTVALUE,'YYYY-MM-DD') AS "Person creation date",
longtodate(s.CREATION_TIME) AS "Subscription creation time"

FROM
Persons p

JOIN
SUBSCRIPTIONS s
ON	p.CENTER = s.OWNER_CENTER
AND	p.ID = s.OWNER_ID

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

AND p.STATUS NOT IN (4,5,8)
AND
TO_DATE(peac.TXTVALUE,'YYYY-MM-DD') > TO_DATE('2023-01-01','YYYY-MM-DD')

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

