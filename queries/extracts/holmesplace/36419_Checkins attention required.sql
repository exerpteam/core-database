Select distinct
longtodate(c.checkin_time) as checkin_time,
p.center ||'p'|| p.id as memberid,
 CASE c.CHECKIN_RESULT WHEN 0 THEN 'Undefined' WHEN 1 THEN 'accessGranted' WHEN 2 THEN 'presenceRegistered' WHEN 3 THEN 'accessDenied' END AS "CHECKIN_RESULT",
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
ccc.amount as "Total Debt",
CASE WHEN ms.DELIVERYCODE = 0 THEN 'UNDELIVERED MESSAGE' WHEN ms.DELIVERYCODE = 1 THEN 'STAFF' WHEN ms.DELIVERYCODE = 2 THEN 'EMAIL' WHEN ms.DELIVERYCODE = 3 THEN 'EXPIRED' WHEN ms.DELIVERYCODE = 4 THEN 'KIOSK' WHEN ms.DELIVERYCODE = 5 THEN 'WEB' WHEN DELIVERYCODE = 6 THEN 'SMS' WHEN ms.DELIVERYCODE = 7 THEN 'CANCELED' WHEN ms.DELIVERYCODE = 8 THEN 'LETTER' WHEN ms.DELIVERYCODE = 9 THEN 'FAILED' WHEN ms.DELIVERYCODE = 10 THEN 'UNCHARGABLE' WHEN ms.DELIVERYCODE = 11 THEN 'UNDELIVERABLE' WHEN ms.DELIVERYCODE = 12 THEN 'MOBILE_API' WHEN ms.DELIVERYCODE = 13 THEN 'APP_NOTIFICATION' WHEN ms.DELIVERYCODE = 14 THEN 'SCHEDULED' ELSE 'Nothing undelivered' END AS "message status",
t1.expiration_date AS healthcertificate_experirationdate,
CASE p.BLACKLISTED WHEN 0 THEN 'NONE' WHEN 1 THEN 'BLACKLISTED' WHEN 2 THEN 'SUSPENDED' WHEN 3 THEN 'BLOCKED' END AS BLACKLISTED

From checkins c

join persons p
on c.PERSON_CENTER = p.center
and
c.PERSON_ID = p.id
left join CASHCOLLECTIONCASES ccc
on
ccc.PERSONCENTER = p.center
and
ccc.PERSONID = p.id
and ccc.closed = 0
and ccc.amount is not NULL

left join MESSAGES ms
on
ms.center = p.center
and
ms.id = p.id
and ms.DELIVERYCODE = 0
and ms.deliverymethod in (3,4)

left join 
( SELECT
                    p.center AS center,
                    p.id     AS id,
                    je.expiration_date,  
                    je.state,                                                                                            
                    rank() over (partition BY je.person_center, je.person_id ORDER BY je.expiration_date DESC) AS rnk
                FROM
                    persons p
                JOIN
                    journalentries je
                ON
                    je.person_center = p.center
                    AND je.person_id = p.id
                    AND je.jetype = 31
                     
         )t1
on
t1.center = p.center
and
t1.id = p.id
and t1.rnk = 1

where
c.checkin_time between :fromdate and :todate+( 86400 * 1000)-1
and p.center in (:scope)
and( (ccc.amount is not NULL) or  (ms.DELIVERYCODE = 0) or (p.blacklisted = 1) or (t1.state not in ('ACTIVE')) )
