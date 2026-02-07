select
pa.*,
to_char(longtodate(pa.START_TIME), 'YYYY-MM-DD HH24:MI') as START_TIME,
to_char(longtodate(pa.STOP_TIME), 'YYYY-MM-DD HH24:MI') as STOP_TIME
from PARTICIPATIONS pa

where
pa.PARTICIPANT_CENTER = 510
and
pa.START_TIME > (:To_date + 24*3600*1000)