SELECT 
   p.center||'p'||p.id AS PersonID, 
   p.FULLNAME          AS Name,
   DECODE(pag.STATE,13,'Not needed',14,'Incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', '') AS "Payment Agreement State",
   DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'TRANSFERRED',5,'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS PERSON_STATUS,
   DECODE(p.PERSONTYPE,0,'PRIVATE',1,'STUDENT',2,'STAFF',3,'FRIEND',4,'CORPORATE',5,'ONEMANCORPORATE',6,'FAMILY',7,'SENIOR',8,'GUEST',9,'CHILD',10,'EXTERNAL_STAFF','Undefined') AS PERSON_TYPE,
   s.center||'ss'||s.id SubscriptionID,
   pr.NAME Subscription_Name,
   DECODE(s.STATE,2,'ACTIVE',3,'ENDED',4,'FROZEN',7,'WINDOW',8,'CREATED','Undefined') as Subscription_STATE
FROM   
   PERSONS p
JOIN
   subscriptions s
ON
   s.OWNER_CENTER = p.center
   AND s.OWNER_ID = p.id   
JOIN
   PRODUCTS  pr
ON
   pr.center = s.SUBSCRIPTIONTYPE_CENTER
   AND pr.id = s.SUBSCRIPTIONTYPE_ID   
JOIN
   ACCOUNT_RECEIVABLES ar
ON 
   ar.CUSTOMERCENTER = p.CENTER and ar.CUSTOMERID = p.ID
JOIN
   PAYMENT_ACCOUNTS pac
ON 
   pac.center = ar.center AND pac.ID = ar.ID AND ar.AR_TYPE = 4
LEFT JOIN
   PAYMENT_AGREEMENTS pag
ON 
   pac.ACTIVE_AGR_CENTER = pag.center AND pac.ACTIVE_AGR_ID = pag.ID AND pac.ACTIVE_AGR_SUBID = pag.SUBID  
WHERE
    (pag.state is null OR pag.state in  (13,14)) -- Empty, Not needed, incomplete
    AND s.STATE in (2,4)
    AND p.STATUS IN (1,2,3) -- active and inactive
    AND p.center in (:Scope)