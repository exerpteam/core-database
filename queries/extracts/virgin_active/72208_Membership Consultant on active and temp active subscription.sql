-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct
s.center ||'ss'|| s.id as "subscription ID",
longtodate(s.creation_time) as "subscription creation date",
emp3.fullname as "subscription sales person name",
emp3.center ||'p'|| emp3.id as "person ID sales person",
p.center ||'p'|| p.id as "person ID",
pea.txtvalue as "current membership consultant ID",
emp.fullname as "current membership Consultant Name",
pcl.new_value as "membership consultant ID record change to",
emp2.fullname as "membership Consultant Name record change to",
longtodate(pcl.entry_time) as "records creation datetime",
emp4.center ||'p'|| emp4.id as "person ID of the person inserting the record",
pcl.entry_time as "ETS"


from subscriptions s

join persons p
on
s.owner_center = p.center
and
s.owner_id = p.id
and p.status in (1,3)

join person_ext_attrs pea
on
pea.personcenter = p.center
and
pea.personid = p.id
and pea.name = 'MC_IT'
and s.creation_time < pea.last_edit_time
and p.status in (1,3)
and pea.txtvalue is not null

join person_change_logs pcl
on
pcl.person_center = pea.personcenter
and
pcl.person_id = pea.personid
and
pea.name = pcl.change_attribute
and
pea.last_edit_time > pcl.entry_time
and (s.creation_time)-86400000 < pcl.entry_time
and pcl.change_attribute = 'MC_IT'
and ((longtodate(pcl.entry_time) <= s.end_date) or ( s.end_date is null))  



join persons emp
on
emp.center ||'p'|| emp.id = pea.txtvalue

left join employees empid2
on
empid2.center = pcl.employee_center
and
empid2.id = pcl.employee_id


left join persons emp4
on
emp4.center = empid2.personcenter
and
emp4.id = empid2.personid


left join persons emp2
on
emp2.center ||'p'|| emp2.id = pcl.new_value

left join employees empid
on
empid.center = s.creator_center
and
empid.id = s.creator_id


left join persons emp3
on
emp3.center = empid.personcenter
and
emp3.id = empid.personid

where 
s.state in (2,4,8)  
and p.center in (:scope)