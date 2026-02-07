SELECT 
ca.center as companycenter, 
ca.id as companyid, 
ca.subid as agreementid,
c.lastname as company , 
ca.name as agreement, 
COUNT(p.CENTER) as number, 
p.status as personStatus,
ca.state as agreement state

FROM ECLUB2.COMPANYAGREEMENTS ca 
/* company */
JOIN ECLUB2.PERSONS c ON ca.CENTER = c.CENTER AND ca.ID = c.ID
 /*company agreement relation*/
JOIN  ECLUB2.RELATIVES rel ON rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID
= ca.ID AND rel.RELATIVESUBID = ca.SUBID  AND rel.RTYPE = 3 
/* persons under agreement*/
JOIN ECLUB2.PERSONS p ON rel.CENTER = p.CENTER AND rel.ID = p.ID  AND rel.RTYPE = 3
/* subscriptions active and frozen of person */
LEFT JOIN ECLUB2.subscriptions s  ON s.OWNER_CENTER = rel.CENTER AND s.OWNER_ID
= rel.ID AND s.STATE IN (2,4 )
/* Link a subscription with its subscription type */
LEFT JOIN ECLUB2.subscriptiontypes st ON  s.subscriptiontype_center = st.center
and s.subscriptiontype_id = st.id
/* Link subscription type with it's global-name */
LEFT JOIN ECLUB2.products prod ON  st.center = prod.center and st.id = prod.id
 LEFT JOIN eclub2.Person_Ext_Attrs Emails ON p.center = Emails.PersonCenter  
AND  p.id = Emails.PersonId 
AND Emails.Name = '_eClub_Email'  
 
WHERE
p.STATUS = 2
and p.persontype = 4 /*corporate*/
and rel.status <3
and ca.state = 2
