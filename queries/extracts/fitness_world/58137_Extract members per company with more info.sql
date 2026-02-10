-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.center ||'p'|| p.id as PersonID, ca.center as companycenter, ca.id as companyid, ca.center ||'p'|| ca.id ||'rpt'|| ca.subid as agreementid,
 c.lastname as company , ca.name as agreement, p.center||'p'||p.id as Customer,
p.firstname as firstname, p.lastname as lastname, p.status as personStatus, 
prod.name as SubscriptionType, 
prod.GLOBALID as GLOBALID,
s.start_date as StartDate, s.subscription_price as Price,
s.BINDING_END_DATE as "Binding end date",
ca.STOP_NEW_DATE as "Agreement SIGNUP END DATE",
pg.SPONSORSHIP_NAME as "type main",
CASE
     WHEN pg.SPONSORSHIP_NAME = 'FULL'
     THEN to_char(s.subscription_price)
      ELSE 'no'
      END AS Companypaidmain,
CASE
     WHEN pg.SPONSORSHIP_NAME = 'NONE'
     THEN to_char(s.subscription_price)
    ELSE 'no'
     END AS memberpaidmain,
m.globalid,
m.CACHED_PRODUCTNAME as addonname,
sa.INDIVIDUAL_PRICE_PER_UNIT,
prod.price as addonprice,
(s.subscription_price-pg.SPONSORSHIP_AMOUNT) as memberpaidmain


-- ca.SPONSOR_PERCENTAGE as SponsorPercent
FROM COMPANYAGREEMENTS ca 
/* company */
JOIN PERSONS c ON ca.CENTER = c.CENTER AND ca.ID = c.ID
 /*company agreement relation*/
JOIN  RELATIVES rel ON rel.RELATIVECENTER = ca.CENTER AND rel.RELATIVEID
= ca.ID AND rel.RELATIVESUBID = ca.SUBID  AND rel.RTYPE = 3 and rel.status not in (3)
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
JOIN PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
    AND pg.GRANTER_SERVICE = 'CompanyAgreement'
    --and pg.valid_to is null
JOIN PRIVILEGE_SETS ps
ON
    pg.PRIVILEGE_SET = ps.id             
join privilege_set_groups psg
    on
     ps.privilege_set_groups_id = psg.id
left join
SUBSCRIPTION_ADDON sa
on
s.center = sa.SUBSCRIPTION_CENTER
and
s.id = sa.SUBSCRIPTION_id
and
sa.END_DATE > sysdate

JOIN
    masterproductregister m
ON
    sa.addon_product_id = m.id

join
products prod
ON
    sa.addon_product_id = prod.id
   

WHERE

/* HERE PUT CENTER OF COMPANY */
ca.center in (:center) and
 p.STATUS BETWEEN 0 AND 3