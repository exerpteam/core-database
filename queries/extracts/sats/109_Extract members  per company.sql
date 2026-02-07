SELECT ca.center as companycenter, ca.id as companyid, ca.subid as agreementid,
 c.lastname as company , ca.name as agreement, p.center as memberCenter, p.id as
memberId,
p.firstname as firstname, p.lastname as lastname, p.status as personStatus, 
prod.name as SubscriptionType, 
s.start_date as StartDate, s.subscription_price as Price, ca.SPONSOR_TYPE as
SponsorType, 
ca.SPONSOR_AMOUNT as SponsorAmount, ca.SPONSOR_PERCENTAGE as SponsorPercent

FROM COMPANYAGREEMENTS ca 
/* company */
JOIN PERSONS c ON ca.CENTER = c.CENTER AND ca.ID = c.ID
 /*company agreement relation*/
JOIN RELATIVES rel ON rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID
= ca.ID AND rel.RELATIVESUBID = ca.SUBID  AND rel.RTYPE = 3 
/* persons under agreement*/
JOIN PERSONS p ON rel.CENTER = p.CENTER AND rel.ID = p.ID  AND rel.RTYPE = 3
/* subscriptions active and frozen of person */
LEFT JOIN subscriptions s  ON s.OWNER_CENTER = rel.CENTER AND s.OWNER_ID
= rel.ID AND s.STATE IN (2,4 )
/* Link a subscription with its subscription type */
LEFT JOIN subscriptiontypes st ON  s.subscriptiontype_center = st.center
and s.subscriptiontype_id = st.id
/* Link subscription type with it's global-name */
LEFT JOIN products prod ON  st.center = prod.center and st.id = prod.id
WHERE

/* HERE PUT CENTER OF COMPANY */
ca.CENTER =  :center_id
/* HERE PUT ID OF COMPANY */
AND ca.ID = :company_id

AND p.STATUS BETWEEN 0 AND 3
