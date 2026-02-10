-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT ca.center as companycenter, ca.id as companyid, ca.subid as agreementid,
  c.lastname as company , ca.name as agreement, p.center as memberCenter, p.id as
 memberId,
 p.firstname as firstname, p.lastname as lastname,
 p.ssn as SSN,
 p.status as personStatus,
 prod.name as SubscriptionType,
 s.end_date as EndDate, s.subscription_price as Price,
 Emails.TxtValue as Email
 FROM COMPANYAGREEMENTS ca
 /* company */
 JOIN PERSONS c ON ca.CENTER = c.CENTER AND ca.ID = c.ID
  /*company agreement relation*/
 JOIN RELATIVES rel ON rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID
 = ca.ID AND rel.RELATIVESUBID = ca.SUBID  AND rel.RTYPE = 3  and rel.status=1
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
 LEFT JOIN Person_Ext_Attrs Emails ON p.center = Emails.PersonCenter
 AND  p.id = Emails.PersonId
 AND Emails.Name = '_eClub_Email'
 WHERE
 (c.center,c.id) in (:companies)
 and p.persontype = 4 /*corporate*/
 AND p.STATUS BETWEEN 0 AND 3
