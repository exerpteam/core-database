-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
 distinct
    p.center ||'p'|| p.id                      AS PersonID,
    ca.center                                  AS companycenter,
    ca.id                                      AS companyid,
    ca.center ||'p'|| ca.id ||'rpt'|| ca.subid AS agreementid,
    c.lastname                                 AS company ,
    ca.name                                    AS agreement,
    p.center||'p'||p.id                        AS Customer,
    p.firstname                                AS firstname,
    p.lastname                                 AS lastname,
    p.status                                   AS personStatus,
    prod.name                                  AS SubscriptionType,
    prod.GLOBALID                              AS GLOBALID,
    s.start_date                               AS StartDate,
    s.subscription_price                       AS Price,
    s.BINDING_END_DATE                         AS "Binding end date",
    --longtodate(ca.LAST_MEMBER_UPDATE)          AS Lastmemberupdate, 
    ca.STOP_NEW_DATE                           AS "Agreement SIGNUP END DATE",
    pg.SPONSORSHIP_NAME                        AS "type main",
    CASE
        WHEN pg.SPONSORSHIP_NAME = 'FULL'
        THEN TO_CHAR(s.subscription_price)
        ELSE 'no'
    END AS Companypaidmain,
    CASE
        WHEN pg.SPONSORSHIP_NAME = 'NONE'
        THEN TO_CHAR(s.subscription_price)
        ELSE 'no'
    END AS memberpaidmain,
    m.globalid,
    m.CACHED_PRODUCTNAME AS addonname,
    CASE
        WHEN sa.INDIVIDUAL_PRICE_PER_UNIT is NULL
        THEN prod2.price
        ELSE sa.INDIVIDUAL_PRICE_PER_UNIT
    END AS realaddonprice,
    CASE
        WHEN pg2.SPONSORSHIP_NAME = 'FULL'
        THEN 'FULL'
        ELSE 'NONE'
    END AS typeaddon
  --   CASE
  --      WHEN pg2.SPONSORSHIP_NAME = 'FULL'
  --      THEN TO_CHAR(prod2.price)
 --       ELSE 'no'
 --   END AS Companypaidaddon,
--    CASE
--        WHEN pg2.SPONSORSHIP_NAME = 'FULL'
--        THEN 'no'
 --       ELSE TO_CHAR(prod2.price)
 --   END AS Memberpaidaddon
    
    
 --   pg2.SPONSORSHIP_NAME as addonmemberpaid
    
   -- sa.INDIVIDUAL_PRICE_PER_UNIT,
  --  prod2.price                                   AS addonprice,
 --   (s.subscription_price-pg.SPONSORSHIP_AMOUNT) AS memberpaidmain
    
    
    -- ca.SPONSOR_PERCENTAGE as SponsorPercent
FROM
    COMPANYAGREEMENTS ca
    /* company */
JOIN
    PERSONS c
ON
    ca.CENTER = c.CENTER
AND ca.ID = c.ID
    /*company agreement relation*/
JOIN
    RELATIVES rel
ON
    rel.RELATIVECENTER = ca.CENTER
AND rel.RELATIVEID = ca.ID
AND rel.RELATIVESUBID = ca.SUBID
AND rel.RTYPE = 3
AND rel.status NOT IN (3)
    /* persons under agreement*/
JOIN
    PERSONS p
ON
    rel.CENTER = p.CENTER
AND rel.ID = p.ID
AND rel.RTYPE = 3
    /* subscriptions active and frozen of person */
 JOIN
    subscriptions s
ON
    s.OWNER_CENTER = rel.CENTER
AND s.OWNER_ID = rel.ID
AND s.STATE IN (2,4 )
    /* Link a subscription with its subscription type */
 JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
    /* Link subscription type with it's global-name */
 JOIN
    products prod
ON
    st.center = prod.center
AND st.id = prod.id
JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_CENTER = ca.CENTER
AND pg.GRANTER_ID = ca.ID
AND pg.GRANTER_SUBID = ca.SUBID
AND pg.GRANTER_SERVICE = 'CompanyAgreement'
    and pg.valid_to is null
JOIN
    PRIVILEGE_SETS ps
ON
    pg.PRIVILEGE_SET = ps.id
JOIN
    privilege_set_groups psg
ON
    ps.privilege_set_groups_id = psg.id
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    s.center = sa.SUBSCRIPTION_CENTER
AND s.id = sa.SUBSCRIPTION_id
AND sa.END_DATE > SYSDATE --or sa.END_DATE is null
AND sa.ENDING_TIME is null
LEFT JOIN
    masterproductregister m
ON
    sa.addon_product_id = m.id
    and m.globalid not in ('EXTENDED_BCA__ADGANG_') 
LEFT JOIN
    products prod2
ON
    m.GLOBALID = prod2.GLOBALID
    AND sa.CENTER_ID = prod2.CENTER
left join
PRIVILEGE_GRANTS pg2
on  
pg2.GRANTER_CENTER = ca.CENTER
AND pg2.GRANTER_ID = ca.ID
AND pg2.GRANTER_SUBID = ca.SUBID
AND pg2.GRANTER_SERVICE = 'CompanyAgreement'
    and pg2.valid_to is null
    and pg2.PRIVILEGE_SET = 3041  

--left join    
--STATE_CHANGE_LOG scl
--on
--scl.center = c.center
--and     
--scl.id = c.id
    
WHERE
    /* HERE PUT CENTER OF COMPANY */
    ca.center IN (:center)
AND p.STATUS BETWEEN 0 AND 3