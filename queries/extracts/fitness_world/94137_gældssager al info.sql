-- This is the version from 2026-02-05
--  
select
personcenter ||'p'|| personid,
longtodate(ccc.closed_datetime)as closed,
longtodate(ccc.start_datetime) as opened,
*
from cashcollectioncases ccc


where 
startdate = '2022-04-04'