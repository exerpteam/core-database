select longtodate(eu.TIME),round(eu.time_used/60000,2) AS minutes, eu.* 
from EXTRACT_USAGE eu 
WHERE eu.EXTRACT_ID = :extract
AND longtodate(eu.TIME) > current_date-10
order by time desc