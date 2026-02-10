-- The extract is extracted from Exerp on 2026-02-08
-- Add which scope the addon is linked to and create an ID for conversion. Getting less here than in addon standard report, but here you get the product name instead of global. Add global here? Why am I missing some?
SELECT DISTINCT
c.shortname AS CLUB,
p2.EXTERNAL_ID,
p2.center||'p'||p2.id AS MemberID,
p.center||'p'||p.id AS OldMemberID,
    s.CENTER||'ss'||s.id AS Subscription_ID,
    pr.NAME              AS Addon,
	--pd.scope_selection  AS Scope,--
CASE sa.USE_INDIVIDUAL_PRICE
                WHEN 0
                THEN pr.PRICE
                WHEN 1
                THEN sa.INDIVIDUAL_PRICE_PER_UNIT
            END AS addonPrice,
pr.PRICE as ProdPrice,
    sa.START_DATE,
    sa.END_DATE,
CASE s.STATE
      WHEN 2 THEN 'ACTIVE'
      WHEN 3 THEN 'ENDED'
      WHEN 4 THEN 'FROZEN'
      WHEN 7 THEN 'WINDOW'
      WHEN 8 THEN 'CREATED'
      ELSE 'UNKNOWN'
   END AS MAINSUBS_STATE,
p2.FULLNAME AS MemberName
    
FROM
    HP.SUBSCRIPTION_ADDON sa
JOIN
    HP.SUBSCRIPTIONS s
ON
    sa.SUBSCRIPTION_CENTER=s.CENTER
    AND sa.SUBSCRIPTION_ID = s.id
JOIN
    HP.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID

JOIN
    HP.PERSONS emp
ON
    emp.CENTER = sa.EMPLOYEE_CREATOR_CENTER
    AND emp.id = sa.EMPLOYEE_CREATOR_ID
JOIN
    HP.MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    HP.PRODUCTS pr
ON
    pr.GLOBALID = mpr.GLOBALID
    AND pr.CENTER = sa.CENTER_ID

JOIN
	add_on_product_definition pd
ON
	pd.id = sa.ADDON_PRODUCT_ID

JOIN
    HP.PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID

JOIN
    HP.PERSONS p2
ON
    p2.CENTER = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID

JOIN
    CENTERS c
ON
    c.id = p.CURRENT_PERSON_CENTER
WHERE
    s.STATE !=5
    AND p2.STATUS NOT IN (7,8)
    AND p2.PERSONTYPE != 2
    AND sa.CANCELLED = 0
AND p2.center IN (:center)