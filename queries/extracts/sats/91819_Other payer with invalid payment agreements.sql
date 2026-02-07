SELECT distinct
    r.relativecenter || 'p' || r.relativeid      AS MemberId,
    CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
    prod.name as "Subscription name",
    s.subscription_price,
     ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID    AS PaidBy,
    cl.name as "Clearing house name",
    CASE pa.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS "Clearing house state"
    
 
 
FROM
    ACCOUNT_RECEIVABLES ar

Join PAYMENT_ACCOUNTS pacc
ON
    ar.CENTER = pacc.CENTER
    AND ar.ID = pacc.ID    

join PAYMENT_AGREEMENTS pa
ON
    pacc.ACTIVE_AGR_CENTER = pa.CENTER
    AND pacc.ACTIVE_AGR_ID = pa.ID
    AND pacc.ACTIVE_AGR_SUBID = pa.SUBID

join clearinghouses cl
on
cl.id = pa.clearinghouse    
   
    
JOIN
    persons p
ON
    p.center = ar.customercenter
    and p.id = ar.customerid    	
JOIN
    relatives r
ON
    r.center = ar.customercenter
    AND r.id = ar.customerid
    AND r.rtype = 12
    AND r.status < 3
join subscriptions s
on
s.owner_center = r.relativecenter
and 
s.owner_id = r.relativeid  
JOIN SubscriptionTypes st 
ON 
s.SubscriptionType_Center =  st.Center 
AND  s.SubscriptionType_ID=  st.ID

JOIN Products prod
ON st.Center = Prod.Center AND  st.Id = prod.Id
    

WHERE
    pa.state not in (1,2,4) and
     r.relativecenter IN ($$Scope$$)
    	AND p.sex != 'C'
    	and s.state in (2,4)
