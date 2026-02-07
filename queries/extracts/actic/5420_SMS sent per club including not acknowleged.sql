SELECT 
s.center, country, count(*) as SMSCount
 FROM SMS s
join centers on centers.id = s.center 
left join sms_splits sp on s.center=sp.sms_center and s.id=sp.sms_id
join messages m on m.center=s.message_center and m.id=s.message_id and m.subid=s.message_sub_id
left join PERSON_EXT_ATTRS pea on pea.PERSONCENTER = m.CENTER and pea.PERSONID = m.id and pea.name = '_eClub_PhoneSMS'
WHERE 
(sp.OK = 1 or (sp.SMS_CENTER is null and s.STATE = 2))
AND 
m.senttime between :from_date AND
:to_date + 86400000 -1
group by 
country, s.center
order by s.center