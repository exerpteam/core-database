select 
creation_time/(24*3600*1000) + TO_DATE('01-01-1970','dd-mm-yyyy ') as BookedTime,
USER_INTERFACE_TYPE,
participant_center || 'p'||Participant_id as MemberId,
state,
START_TIMe/(24*3600*1000) + TO_DATE('01-01-1970','dd-mm-yyyy ') as StartTime,
Showup_Time/(24*3600*1000) + TO_DATE('01-01-1970','dd-mm-yyyy ') as ShowUp,
BOOKING_CENTER,
BOOKING_ID,
PRIVILEGE_SOURCE_REF_CENTER,
PRIVILEGE_SOURCE_REF_ID,
cancelation_time/(24*3600*1000) + TO_DATE('01-01-1970','dd-mm-yyyy ') as CancelTime,
cancelation_reason,
creation_time/(24*3600*1000) + TO_DATE('01-01-1970','dd-mm-yyyy ') as BookedTime,
MOVED_UP_TIME/(24*3600*1000) + TO_DATE('01-01-1970','dd-mm-yyyy ') as MOVEDUPTIME
FROM
Participations Pa
where 
pa.booking_center>:centerfrom
and
pa.booking_center<=:centerto
and
start_time >:from
and
start_time <=:to and
state='CANCELLED'
order by StartTime

