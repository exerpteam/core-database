-- The extract is extracted from Exerp on 2026-02-08
--  
select 
     MemberID, SubscriptionName,Globalid, productprice, PromoCode, 
     case when NormalPrice is null
     then INITIALPRICE 
     ELSE NormalPrice
     end as NormalPrice, 
     Case when (CampaignPrice is null and Prorataprice is null)
     then INITIALPRICE
     when (CampaignPrice is null and Prorataprice is not null)
     then Prorataprice
     Else CampaignPrice
     end as CampaignPrice,
     case when ProRataPeriodStart is null
     then InitialPriceStart
     ELSE ProRataPeriodStart 
     END as ProRataPeriodStart,
     case when  
     periodpart2 is null
     then periodpart1
     else periodpart2        
     end as ProRataPeriodEnd,
     case when (CampaignPeriodStart is null and ProRataPeriodStart is null)
     then InitialPriceStart
     when (CampaignPeriodStart is null and ProRataPeriodStart is not null)  
     then ProRataPeriodStart
     Else  CampaignPeriodStart
     end as CampaignPeriodStart,
     Case when (CampaignPeriodEnd is null and ProrataPeriodEnd2 is null)
     then InitialPriceEnd
     when (CampaignPeriodEnd is null and ProrataPeriodEnd2 is not null)
     then ProrataPeriodEnd2
     Else CampaignPeriodEnd
     end as CampaignPeriodEnd,
     Case when NormalPriceStart is NULL
     then InitialPriceStart
     Else NormalPriceStart
     End as NormalPriceStart,
     
     NormalPriceEnd, BindingEndDate, CampaignName, CampaignPublicDescription,
     "AddOnName","AddOnPrice", "AddOnId", "subid", 
     
     Case WHEN ptype = 12
     THEN 'rest of this month main subscription'
     when ptype = 10 
     THEN 'next month main subscription'
     WHEN ptype = 5
     THEN 'Joining Fee'
     WHEN ptype = 13
     THEN 'add-on first period'
     Else Null END as DeductionType, 
     SUM("totalinvoiceamount") as TOTAL_AMOUNT from (
SELECT
 
    p.center ||'p'|| p.id AS MemberID,
    p.external_id,
    s.center ||'ss'||  s.id AS SubscriptionID,
    pr.name            AS SubscriptionName,
    pr.globalid        AS Globalid,
	cd.CODE			   AS PromoCode,
    pr.price            as productprice,
    spnor.PRICE           as NormalPrice,
    spit.PRICE            as INITIALPRICE,
    spit.type as           initype,
    spcam.price   AS CampaignPrice,
    sppro.price   as Prorataprice,
    s.center ||'ss'|| s.id as "subid",
    sppro.FROM_DATE    AS ProRataPeriodStart,
    spp2.TO_DATE        AS periodpart2,
    spp.TO_DATE        AS periodpart1,
    sppro.TO_DATE      AS ProrataPeriodEnd2,
    spcam.FROM_DATE    AS CampaignPeriodStart,
    spcam.TO_DATE      AS CampaignPeriodEnd,
    spnor.FROM_DATE    AS NormalPriceStart,
    spnor.TO_DATE      AS NormalPriceEnd,
    s.BINDING_END_DATE AS BindingEndDate,
    spit.FROM_DATE     AS InitialPriceStart,
    spit.TO_DATE       AS InitialPriceEnd,
    COALESCE(rg.name, stc.name) as CampaignName,
    prodad.name         AS "AddOnName",
    prodad.price        AS "AddOnPrice",
    sa.ADDON_PRODUCT_ID AS "AddOnId",
    il.TOTAL_AMOUNT     AS "totalinvoiceamount",
    pil.ptype,
    COALESCE(stc.WEB_TEXT, rg.WEB_TEXT) as CampaignPublicDescription

FROM
    Subscriptions s
JOIN
    persons p
ON
    s.owner_center = p.current_person_center
AND s.owner_id = p.current_person_id
JOIN
    SubscriptionTypes st
ON
    s.SubscriptionType_Center = st.Center
AND s.SubscriptionType_ID = st.ID
JOIN
    Products pr
ON
    st.Center = pr.Center
AND st.Id = pr.Id
JOIN
    SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = s.center
AND ss.SUBSCRIPTION_ID = s.id
JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    ss.SUBSCRIPTION_CENTER = spp.CENTER
AND ss.SUBSCRIPTION_id = spp.id
and spp.spp_type in (8,9)
and spp.SUBID = 1

JOIN
    INVOICE_LINES_MT il
ON
    s.INVOICELINE_CENTER = il.center
AND s.INVOICELINE_ID = il.id
left JOIN
    SUBSCRIPTIONPERIODPARTS spp2
ON
    ss.SUBSCRIPTION_CENTER = spp2.CENTER
AND ss.SUBSCRIPTION_id = spp2.id
and spp2.spp_type in (8,9)
and spp2.SUBID = 2
and spp.SYNC_DATE = spp2.SYNC_DATE

LEFT JOIN
    products pil
ON
    il.PRODUCTCENTER = pil.center
AND il.PRODUCTID = pil.id
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.center
AND sa.SUBSCRIPTION_ID = s.id
LEFT JOIN
    masterproductregister m
ON
    sa.addon_product_id = m.id
LEFT JOIN
    products prodad
ON
    m.globalid = prodad.globalid
LEFT JOIN
    SUBSCRIPTION_PRICE sppro
ON
    sppro.SUBSCRIPTION_CENTER = s.center
AND sppro.SUBSCRIPTION_ID = s.id
AND sppro.type = 'PRORATA'
LEFT JOIN
    SUBSCRIPTION_PRICE spcam
ON
    spcam.SUBSCRIPTION_CENTER = s.center
AND spcam.SUBSCRIPTION_ID = s.id
AND spcam.type = 'CAMPAIGN'


LEFT JOIN
    SUBSCRIPTION_PRICE spnor
ON
    spnor.SUBSCRIPTION_CENTER = s.center
AND spnor.SUBSCRIPTION_ID = s.id
AND spnor.type = 'NORMAL'

LEFT JOIN
    SUBSCRIPTION_PRICE spit
ON
    spit.SUBSCRIPTION_CENTER = s.center
AND spit.SUBSCRIPTION_ID = s.id
AND spit.type = 'INITIAL'


LEFT JOIN
   PRIVILEGE_USAGES pu          
ON
   pu.TARGET_SERVICE = 'InvoiceLine'
   AND pu.TARGET_CENTER = il.CENTER
   AND pu.TARGET_ID = il.ID
   AND pu.TARGET_SUBID = il.SUBID
LEFT JOIN
    PRIVILEGE_GRANTS pgr
ON
    pgr.ID = pu.GRANT_ID
    AND pgr.GRANTER_SERVICE in ('StartupCampaign','ReceiverGroup')
LEFT JOIN
    startup_campaign stc
ON 
    pgr.GRANTER_SERVICE = 'StartupCampaign'
    AND stc.ID = pgr.GRANTER_ID    
left join PRIVILEGE_RECEIVER_GROUPS rg
ON 
    pgr.GRANTER_SERVICE = 'ReceiverGroup'
    AND rg.ID = pgr.GRANTER_ID
LEFT JOIN
	CAMPAIGN_CODES cd
ON cd.ID = pu.CAMPAIGN_CODE_ID
WHERE
    /* Only active subscriptions */
     s.state IN (2,4,8)
  AND    p.center ||'p'|| p.id in (:member_id)
   
GROUP BY
p.center ||'p'|| p.id,
   p.external_id,
    s.center ||'ss'|| s.id,
    pr.name,
pr.price,
    pr.globalid,
	cd.CODE,
    sppro.FROM_DATE,
    sppro.TO_DATE,
    spcam.FROM_DATE,
    spcam.TO_DATE,
    spnor.FROM_DATE,
    spnor.TO_DATE,
    s.BINDING_END_DATE,
    stc.name,
    ss.price_initial,
    ss.price_initial_discount,
    prodad.name,
    prodad.price,
    sa.ADDON_PRODUCT_ID,
    pil.ptype,
    il.TOTAL_AMOUNT,
    spnor.PRICE,
    stc.WEB_TEXT,
    sppro.price,
    spcam.price,
    rg.name,
    rg.WEB_TEXT,
    spp2.TO_DATE,
    spp.TO_DATE,
    spit.PRICE,
    spit.FROM_DATE,
    spit.type,
    spit.TO_DATE
    
    
    ) t1
    group by MemberID, external_id, SubscriptionID, SubscriptionName,Globalid, PromoCode, CampaignPrice, ProRataPeriodStart,productprice,
     CampaignPeriodStart,CampaignPeriodEnd,NormalPriceStart,NormalPriceEnd, BindingEndDate, CampaignName, initype,
     "AddOnName","AddOnPrice", "AddOnId", "subid", ptype, NormalPrice, CampaignPublicDescription, ProrataPeriodEnd2, Prorataprice, periodpart1, periodpart2, INITIALPRICE, InitialPriceStart, InitialPriceEnd

ORDER BY
MemberID
