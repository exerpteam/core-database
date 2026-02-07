select 
    report_key as report,
    employee_center||'p'||employee_id as employee,
    eclub2.longtodate(time) as use_time
from 
    eclub2.report_usage
where
    employee_center in (:scope)
order by
    time,
    employee_center,
    employee_id,
    report_key