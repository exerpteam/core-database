-- This is the version from 2026-02-05
--  
SELECT
 distinct
    p.center ||'p'|| p.id                      AS PersonID,
    s.center ||'ss'|| s.id                     as SubscriptionID,
DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'TRANSFERRED',5,'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS STATUS,
    ca.center ||'p'|| ca.id ||'rpt'|| ca.subid AS agreementid,
    prod.GLOBALID                              AS GLOBALID,
    s.subscription_price                       AS Price,
rap.globalid as ADDONGLOBALID,
TO_CHAR(rap.realaddonprice) AS ADDONPRICE
      
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
left join    
PRODUCT_PRIVILEGES pp    
on ps.id = pp.PRIVILEGE_SET
and
pp.REF_GLOBALID = 'CREATION_'||prod.GLOBALID   
    
LEFT JOIN

(Select
sa.SUBSCRIPTION_CENTER,
sa.SUBSCRIPTION_ID,
sa.END_DATE,
sa.ENDING_TIME,
m.globalid,
m.CACHED_PRODUCTNAME,
CASE
        WHEN sa.INDIVIDUAL_PRICE_PER_UNIT is NULL
        THEN prod2.price
        ELSE sa.INDIVIDUAL_PRICE_PER_UNIT
    END AS realaddonprice

From
    SUBSCRIPTION_ADDON sa

LEFT JOIN
    masterproductregister m
ON
    sa.addon_product_id = m.id
    and m.globalid not in ('EXTENDED_BCA__ADGANG_', 'ADGANG___KOST_SESSION', 'FITNESS_FLEX_CENTER_2', 'HOLD_FLEX__CENTER_2_', 'HOLD_FLEX__CENTER_3_', 'PT_SESSION_1', 'TILLÆGSMEDLEMSKAB__SQUASH') 
LEFT JOIN
    products prod2
ON
    m.GLOBALID = prod2.GLOBALID
    AND sa.CENTER_ID = prod2.CENTER
where
sa.CANCELLED = 0   

) rap
    
ON
    s.center = rap.SUBSCRIPTION_CENTER
AND s.id = rap.SUBSCRIPTION_id
AND (rap.END_DATE > SYSDATE or rap.END_DATE is null)    
    
left join
PRIVILEGE_GRANTS pg2
on  
pg2.GRANTER_CENTER = ca.CENTER
AND pg2.GRANTER_ID = ca.ID
AND pg2.GRANTER_SUBID = ca.SUBID
AND pg2.GRANTER_SERVICE = 'CompanyAgreement'
    and pg2.valid_to is null
    and pg2.PRIVILEGE_SET = 3041  

left join    
STATE_CHANGE_LOG scl
on
scl.center = c.center
and     
scl.id = c.id
and ENTRY_TYPE = 3
    
WHERE
    /* HERE PUT CENTER OF COMPANY */
    ca.center IN (:center)
AND p.STATUS BETWEEN 0 AND 3










