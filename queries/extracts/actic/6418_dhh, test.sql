select 
	longtodate(bo.starttime),
	bo.name
from
    bookings bo
where
   bo.center = 515
and longtodate(bo.starttime) > to_date(sysdate-21,'YYYY-MM-dd')