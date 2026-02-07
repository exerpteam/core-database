SELECT country,
SMS_CENTER, ok,
count(*) as SMSCount
 FROM sms_splits sp
join centers on centers.id = sp.SMS_CENTER
join SMS s on s.center=sp.sms_center and s.id=sp.sms_id
join messages m on m.center=s.message_center and m.id=s.message_id and m.subid=s.message_sub_id
WHERE 
m.senttime between :from_date AND
:to_date + 86400000 -1
group by 
country, ok, SMS_CENTER 
order by SMS_CENTER 