-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 OldPID.txtvalue as OlpdPersonID,
 longToDate(S.CREATION_TIME)as MEMBER_CR_DATE,
 S.START_DATE as MembershipStartDate,
 S.END_DATE as MembershipEndDate,
 S.SUB_COMMENT AS MembershipComment,
 MembTypePrice.Name as ExerpSubName,
 MembTypePrice.GLOBALID As ExerpSubGlobalID,
 SP.Price AS MembershipPrice,
 spfp.Price AS NextpriceIncrease,
 CASE st.ST_TYPE WHEN 0 THEN 'CASH' WHEN 1 THEN 'EFT' END AS MembershipDeductionType,
 S.BILLED_UNTIL_DATE,
 S.BINDING_END_DATE,
 sfp.Start_date AS FreezeFrom,
 sfp.END_date AS FreezeTo,
 mpr.CACHED_PRODUCTNAME AS AddonName1,
 CASE WHEN sa.INDIVIDUAL_PRICE_PER_UNIT IS NOT NULL THEN sa.INDIVIDUAL_PRICE_PER_UNIT ELSE prod.PRICE END AS ADDONPRICE1,
 sa.START_DATE as AddonStartdate1,
 sa.END_DATE as AddonEnddate1,
 sa.BINDING_END_DATE as AddonBindingEnddate1
 FROM
 PERSONS P
 Left JOIN SUBSCRIPTIONS s
 ON
     P.CENTER = S.OWNER_CENTER
     AND P.ID = S.OWNER_ID
 and SUB_COMMENT<> 'Dummy Subscription from the legacy system'
 left join PERSON_EXT_ATTRS OldPID
 on
    P.ID = OldPID.Personid
    and OldPID.name = '_eClub_OldSystemPersonId'
 and OldPID.personcenter = P.CENTER
 Left JOIN SUBSCRIPTION_PRICE sp
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.ID
 And SP.Binding=1
 Left JOIN SUBSCRIPTION_PRICE spfp
 ON
 spfp.SUBSCRIPTION_CENTER = s.CENTER
     AND spfp.SUBSCRIPTION_ID = s.ID
 And spfp.Binding=0
 Left JOIN PRODUCTS MembTypePrice
 ON
     MembTypePrice.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND MembTypePrice.id = s.SUBSCRIPTIONTYPE_ID
 Left JOIN SUBSCRIPTIONTYPES st
 ON
     st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND st.ID = s.SUBSCRIPTIONTYPE_ID
 Left JOIN SUBSCRIPTION_FREEZE_PERIOD sfp
 ON
     sfp.SUBSCRIPTION_CENTER = s.CENTER
     AND sfp.SUBSCRIPTION_ID = s.ID
     AND sfp.STATE = 'ACTIVE'
 LEFT JOIN SUBSCRIPTION_ADDON sa
 ON
     sa.SUBSCRIPTION_CENTER = s.CENTER
     AND sa.SUBSCRIPTION_ID = s.ID
 LEFT JOIN MASTERPRODUCTREGISTER mpr
 ON
     mpr.ID = sa.ADDON_PRODUCT_ID
 LEFT JOIN PRODUCTS prod
 ON
     prod.CENTER = sa.SUBSCRIPTION_CENTER
     AND prod.GLOBALID = mpr.GLOBALID
 WHERE p.CENTER in (75,15,9,12,6,5,22,28)
 and OldPID.txtvalue is not null
 order by OldPID.txtvalue asc
