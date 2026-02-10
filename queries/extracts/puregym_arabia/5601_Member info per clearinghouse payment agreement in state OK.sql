-- The extract is extracted from Exerp on 2026-02-08
--  
Select
p.center||'p'|| p.id as memberid,
p.external_id,
prod.name as "subscription name",
s.subscription_price,
ch.name as "clearing house name"

FROM PAYMENT_AGREEMENTS pag
 JOIN CLEARINGHOUSES ch ON ch.ID = pag.CLEARINGHOUSE
 JOIN PAYMENT_ACCOUNTS pac ON pac.ACTIVE_AGR_CENTER = pag.CENTER AND pac.ACTIVE_AGR_ID = pag.ID AND pac.ACTIVE_AGR_SUBID = pag.SUBID
 JOIN ACCOUNT_RECEIVABLES ar ON pac.CENTER = ar.CENTER AND pac.ID = ar.ID AND ar.AR_TYPE = 4
 JOIN PERSONS p ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID
 join subscriptions s
 on s.owner_center = p.center
 and s.owner_id = p.id
 JOIN SubscriptionTypes st ON s.SubscriptionType_Center =  st.Center AND  S.SubscriptionType_ID=  st.ID
 JOIN Products prod ON st.Center = prod.Center AND  st.Id = prod.Id
 
 where
 ch.id in ( :clearinghouse)
 and p.center in (:center)
 and s.state in (2,4,8) and
 pag.state = 4