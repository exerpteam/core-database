SELECT 
to_char(longtodate(m.senttime), 'YYYY-MM-DD') as SentDate
, sum(case when sp.ok is not null and sp.ok = 1 then 1 else 0 end) as ACK
, sum(case when sp.ok is not null and sp.ok = 1 then 0 else 1 end) as NOT_ACK
, count(*) as SMSCount
, count (distinct m.center || 'a' || m.id || 'b' || m.subid) as MESS_CNT
 FROM SMS s
join centers on centers.id = s.center 
left join sms_splits sp on s.center=sp.sms_center and s.id=sp.sms_id
join messages m on m.center=s.message_center and m.id=s.message_id and m.subid=s.message_sub_id
WHERE 
(sp.OK = 1 or (sp.SMS_CENTER is null and s.STATE = 2))
and m.senttime between :from_date AND
:to_date + 86400000 -1
--and m.center = 1
group by 
to_char(longtodate(m.senttime), 'YYYY-MM-DD')
order by 1