select
bk.*,
to_char(eclub2.longtodate(bk.STARTTIME), 'YYYY-MM-DD HH24:MI') as START_TIME,
to_char(eclub2.longtodate(bk.STOPTIME), 'YYYY-MM-DD HH24:MI') as STOP_TIME
from eclub2.bookings bk
where
bk.CENTER = 510
and
bk.STARTTIME > (:To_date + 24*3600*1000)