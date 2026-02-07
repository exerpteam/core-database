select 
pcl.person_center ||'p'|| pcl.person_id as personid,
pcl.change_source,
pcl.change_attribute,
longtodateC(pcl.entry_time, pcl.person_center) as entry_time,
pcl.employee_center || 'emp' || pcl.employee_id as employeeid

from goodlife.person_change_logs pcl 
where 
pcl.person_center in (:scope)
and pcl.change_attribute IN ('LAST_NAME','FIRST_NAME')
and pcl.entry_time between (:startdate) and (:enddate)