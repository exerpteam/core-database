SELECT DISTINCT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS memberid,
    p.FULLNAME,
DECODE(pa2.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,
    'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,
    'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,
    'Agreement not needed (invoice payment)',14,'Agreement information incomplete') AS
                "Payment Agreement State",
    ch2.NAME  AS "Clearing house",
    DECODE(p.persontype,0,'Private',1,'Student',2,'Staff',3,'Friend',4,'Corporate',5,'Onemancorporate',6,'Family',7,'Senior',8,'Guest',9,'Child',10,'External_Staff','Undefined') AS PersonType, 
    DECODE(s.state,2,'Active',3,'Ended',4,'Frozen',7,'Window',8,'Created','Undefined') AS SubscriptionState
   
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.center = ar.center
AND pa.id = ar.id
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
AND pac.id = ar.id
JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = pac.ACTIVE_AGR_CENTER
AND pa2.id = pac.ACTIVE_AGR_ID
AND pa2.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    CLEARINGHOUSES ch
ON
    pa.CLEARINGHOUSE = ch.id
JOIN
    CLEARINGHOUSES ch2
ON
    pa2.CLEARINGHOUSE = ch2.id
JOIN
    persons p
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
join subscriptions s
on
p.center = s.owner_center
and
p.id = s.owner_id
WHERE
    (ar.CUSTOMERCENTER,ar.CUSTOMERID) in (:memberid)