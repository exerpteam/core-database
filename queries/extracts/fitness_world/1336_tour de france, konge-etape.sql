-- The extract is extracted from Exerp on 2026-02-08
--  
select part.center, to_char(longtodate(part.START_TIME), 'IW') as WEEK, count(*) as NB, to_char(round(sum (case when pd.GLOBALID is not null then 1 else 0 end) * 100 / count(*), 2), '90.00') || ' %' as TDF
from fw.participations part
join fw.BOOKINGS book on book.center=part.BOOKING_CENTER and book.id=part.BOOKING_ID
join fw.SUBSCRIPTIONS sub on sub.OWNER_CENTER=part.PARTICIPANT_CENTER and sub.OWNER_ID=part.PARTICIPANT_ID
left join fw.PRODUCTS pd on pd.CENTER=sub.SUBSCRIPTIONTYPE_CENTER and pd.id=sub.SUBSCRIPTIONTYPE_ID 
and pd.GLOBALID='EVENT_TOURDEFRANCE'
--and pd.GLOBALID='EFT_NORMAL'
where
part.START_TIME between :startdate and (:enddate + 24 * 3600 * 1000) 
and part.STATE = 'PARTICIPATION'
and book.NAME like 'Tour%'
group by part.center,  to_char(longtodate(part.START_TIME), 'IW')
order by 1,2