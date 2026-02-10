-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
m.center||'p'||m.id as member,
 longtodateC(m.last_modified, m.center)    last_mod,
  longtodateC(m.senttime, m.center)    sent_time,
 m.subject
    
FROM
    messages m
WHERE
m.message_type_id = 38
and m.subject in ( 'Your GoodLife Fitness Subscription Confirmation') 
and m.center in (:scope)
and m.senttime between datetolongC(:startdate , m.center) and datetolongC('12-12-10124 11:45:50', m.center)