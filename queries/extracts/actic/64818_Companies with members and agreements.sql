-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    (person.center::text || 'p' || person.id::text) AS customer,
    (person.firstname || ' ' || person.lastname)    AS person_name,
     mob.txtvalue as mobile,
   ca.center                           AS company_center,
    ca.id                               AS company_id,
    comp.fullname                    AS company,
    ca.name                             AS aggreement,
    grants.sponsorship_name             AS sponsor_level,
   -- ps.name,
    s.subscription_price,
   /*
    CASE
    WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
        THEN 'GRATIS'
        WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
        THEN 'FAST PRIS' ||' '|| pp.PRICE_MODIFICATION_AMOUNT ||' kr.'
        WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
        THEN pp.PRICE_MODIFICATION_AMOUNT ||' kr.'
        WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
        THEN pp.PRICE_MODIFICATION_AMOUNT*100 ||'%'
        ELSE 'INGEN'
        END AS "Rabat",*/
    CASE ca.state
        WHEN 0 THEN 'Under target'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Stop new'
        WHEN 3 THEN 'Old'
        WHEN 4 THEN 'Awaiting activation'
        WHEN 5 THEN 'Blocked'
        WHEN 6 THEN 'Deleted'
    END                                 AS agreement_state
/*    CASE person.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        ELSE 'UNKNOWN'
    END                                 AS person_status,
    grants.**/
FROM persons AS person
JOIN relatives AS companyagrrel
  ON person.center = companyagrrel.center
 AND person.id     = companyagrrel.id
 AND companyagrrel.rtype  = 3
 AND companyagrrel.status = 1
JOIN companyagreements AS ca
  ON ca.center = companyagrrel.relativecenter
 AND ca.id     = companyagrrel.relativeid
 AND ca.subid  = companyagrrel.relativesubid
JOIN persons AS comp
  ON comp.center = ca.center
 AND comp.id     = ca.id
JOIN privilege_grants AS grants
  ON ca.center = grants.granter_center
 AND ca.id     = grants.granter_id
 AND ca.subid  = grants.granter_subid
 join privilege_sets ps
 on ps.id = grants.privilege_set
 JOIN
       PRODUCT_PRIVILEGES pp
ON
        pp.PRIVILEGE_SET = ps.ID

  join subscriptions s 
  ON
     person.center = s.owner_center
 AND person.id = s.owner_id
left JOIN SubscriptionTypes st
                 ON 
                 s.SubscriptionType_Center =  st.Center
                 AND  S.SubscriptionType_ID=  St.ID
 
                 JOIN Products prod2
                 ON st.Center = prod2.Center AND  st.Id = Prod2.Id


 LEFT JOIN Person_Ext_Attrs mob
 ON
     person.center = mob.PersonCenter
 AND person.id = mob.PersonId
 AND mob.Name = '_eClub_PhoneSMS' 
 
WHERE
    person.center in (:scope)              -- $1 forventes at være en array-parameter (fx int[])
AND person.persontype = 4
and person.status in (1,3)
AND person.sex != 'C'
AND grants.granter_service  = 'CompanyAgreement'
and s.state in (2,4)