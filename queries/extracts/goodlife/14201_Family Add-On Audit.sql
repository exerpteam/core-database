/*

Audit Active Family Add-On Memberships where member does not have privilege for discount.

*/

select

s.owner_center||'p'||s.owner_id AS "Person_ID",
p.name AS "Product Name",
sp.price AS "Price",
to_timestamp(s.creation_time /1000 + 86400) as "Created Date"
	--Added 86400 as the Creation date was off by one day.


from 
products p, subscriptions s, subscription_price sp

where

p.id = s.subscriptiontype_id
and p.center = s.subscriptiontype_center
and s.state in (2,4,8) --membership is active
and sp.subscription_id = s.id
and sp.subscription_center = s.center
--current price of membership - allows check if the price changed to reflect loss of privilege
and sp.to_date is null
and sp.cancelled_entry_time is null

and(
--Membership is one of Family Add-On Membership products listed below
p.GLOBALID = 'PAP_MTHLY_MULTI_ATLANTIC_FAMIL'
or p.GLOBALID = 'PAP_BW_MULTI_ATLANTIC_FAMILY'
or p.GLOBALID = 'PAP_BIWEEKLY_ULTIMATE_FAMILY'
or p.GLOBALID = 'PAP_MONTHLY_ULTIMATE_FAMILY'
or p.GLOBALID = 'PAP_BW_2_YEARS_MULTI_SASK_FAMI'
or p.GLOBALID = 'PAP_MTHLY_2_YR_MULTI_SASK_FAMI'
or p.GLOBALID = 'PAP_BW_ULTI_FAMILY_NC'
or p.GLOBALID = 'PAP_MTHLY_ULTI_FAMILY_NC'
or p.GLOBALID = 'PAP_BW_MULTI_MANITOBA_FAMILY'
or p.GLOBALID = 'PAP_12_MTH_ULTIMATE_FAMILY_BW'
or p.GLOBALID = 'PAP_12_MTH_ULTIMATE_FAMILY_MTH'
--or p.GLOBALID = 'PAP_BW_1_CLUB_NC_ZONE_C_FAMILY'
--or p.GLOBALID = 'PAP_BW_1_CLUB_NC_ZONE_B_FAMILY'
--or p.GLOBALID = 'PAP_MTHLY_1_CLUB_NC_ZONE_B_FAM'
--or p.GLOBALID = 'PAP_BW_1_CLUB_NC_FAMILY'
--or p.GLOBALID = 'PAP_MTHLY_1_CLUB_NC_ZONE_D_FAM'
--or p.GLOBALID = 'PAP_MTHLY_1_CLUB_NC_FAMILY'
--or p.GLOBALID = 'PAP_BW_1_CLUB_NC_ZONE_D_FAMILY'
--or p.GLOBALID = 'PAP_MTHLY_1_CLUB_NC_ZONE_C_FAM'
or p.GLOBALID = 'PAP_BW_MULTI_SASKATCHEWAN_FAMI'
--or p.GLOBALID = 'PIF_MULTI_MANITOBA_FAMILY'
or p.GLOBALID = 'PAP_MTHLY_MULTI_MANITOBA_FAMIL'
--or p.GLOBALID = 'PIF_MONTHLY_MULTI_MANITOBA_FAM'
or p.GLOBALID = 'PAP_BW_ULT_FAMILY_NC_PRESALES'
or p.GLOBALID = 'PAP_MTHLY_MULTI_SASK_FAMILY'
or p.GLOBALID = 'PAP_MTHLY_ULT_FAMILY_NC_PRE')

--Below is from family add-on target group - checking to see if members with family add-on memberships are not in the target group - i.e. do not have privilege
and not exists (
select 1 from 
(
SELECT p_eligible.center, p_eligible.id
FROM
RELATIVES rel_family,
SUBSCRIPTIONS s,
PRODUCT_AND_PRODUCT_GROUP_LINK ppgl,
PERSONS p_eligible,
RELATIVES rel_payer
WHERE
p_eligible.center = rel_family.center
AND p_eligible.id = rel_family.id
AND rel_family.RTYPE = 4 
AND rel_family.STATUS in (0,1)
AND s.OWNER_CENTER = rel_family.RELATIVECENTER
AND s.OWNER_ID = rel_family.RELATIVEID
AND s.state in (2,4,8)
AND s.SUBSCRIPTIONTYPE_CENTER = ppgl.PRODUCT_CENTER
AND s.SUBSCRIPTIONTYPE_ID = ppgl.PRODUCT_ID
AND (ppgl.PRODUCT_GROUP_ID = 603
or ppgl.PRODUCT_GROUP_ID = 2209)
AND p_eligible.PERSONTYPE = 6
AND rel_payer.RTYPE = 12
AND rel_payer.relativecenter = p_eligible.center
AND rel_payer.relativeid = p_eligible.id 
AND rel_payer.STATUS = 1  
UNION ALL
SELECT p_eligible.center, p_eligible.id
FROM
RELATIVES rel_payer,
RELATIVES rel_family,
SUBSCRIPTIONS s,
PRODUCT_AND_PRODUCT_GROUP_LINK ppgl,
PERSONS subs,
PERSONS payer,
PERSONS p_eligible
WHERE 
rel_payer.RTYPE = 12  -- other payer
AND rel_payer.STATUS = 1 --active
AND rel_family.RTYPE = 4  -- family
AND rel_family.STATUS in (0,1) --active
AND rel_family.id = payer.id
AND rel_family.center = payer.center
and rel_family.relativecenter = subs.center
and rel_family.relativeid = subs.id
AND s.OWNER_CENTER = subs.center
AND s.OWNER_ID =  subs.id
AND s.state in (2,4,8)  
AND s.SUBSCRIPTIONTYPE_CENTER = ppgl.PRODUCT_CENTER
AND s.SUBSCRIPTIONTYPE_ID = ppgl.PRODUCT_ID
AND (ppgl.PRODUCT_GROUP_ID = 603
or ppgl.PRODUCT_GROUP_ID = 2209)
AND rel_payer.id = payer.id
AND rel_payer.center = payer.center
AND rel_payer.relativecenter = p_eligible.center
AND rel_payer.relativeid = p_eligible.id 
) a

where
a.center = s.owner_center AND a.ID = s.owner_id


)