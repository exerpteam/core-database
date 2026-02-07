SELECT DISTINCT
	--comp.CENTER || 'p' || comp.ID as "Company ID",
    --comp.LASTNAME AS "Company",
    --ca.NAME AS "Company Agreement",
    --c.NAME AS "Club",
    p.CENTER || 'p' || p.ID as "Person Id"
    --p.FIRSTNAME,
    --p.LASTNAME,
	--S.ID as "Sub ID",
    --pr.NAME "Subscription",
    --s.START_DATE as "Subscription Start Date",
    --s.END_DATE as "Subscription End Date",
    --DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect') AS "Subscription Type",
    --DECODE (s.state, 2,'Active', 3,'Ended', 4,'Frozen', 7,'Window', 8,'Created','Unknown') AS "Subscription State",
	/*
    (CASE
        WHEN TRUNC(FROM_DATE, 'MONTH')= FROM_DATE AND LAST_DAY(FROM_DATE)=TO_DATE THEN
                il.TOTAL_AMOUNT
        ELSE
                (il.TOTAL_AMOUNT/(il.TOTAL_AMOUNT+nvl(spons_il.TOTAL_AMOUNT,0)))*spp.SUBSCRIPTION_PRICE
    END) AS "Member Monthly Fee",
    (CASE
        WHEN TRUNC(FROM_DATE, 'MONTH')= FROM_DATE AND LAST_DAY(FROM_DATE)=TO_DATE THEN
                nvl(spons_il.TOTAL_AMOUNT,0)
        ELSE
                (nvl(spons_il.TOTAL_AMOUNT,0)/(nvl(spons_il.TOTAL_AMOUNT,0)+il.TOTAL_AMOUNT))*spp.SUBSCRIPTION_PRICE
    END) AS "Member fee sponsored",
    
    s.BINDING_END_DATE "Expiry Date"
    */
FROM PERSONS p 
JOIN CENTERS c ON p.CENTER=c.ID and p.CENTER = 59 and p.ID = 4153
JOIN SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID AND s.STATE IN ($$subState$$)
JOIN SUBSCRIPTIONTYPES st ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID --AND st.ST_TYPE NOT IN (0)
/*
JOIN PRODUCTS pr ON st.CENTER = pr.CENTER AND st.ID = pr.ID
JOIN RELATIVES r ON r.CENTER = s.OWNER_CENTER AND r.id = s.owner_ID AND r.RTYPE IN (3) AND r.STATUS<3
JOIN COMPANYAGREEMENTS ca ON ca.CENTER = r.RELATIVECENTER AND ca.ID = r.RELATIVEID AND ca.SUBID = r.RELATIVESUBID
JOIN PERSONS comp ON comp.center = ca.CENTER AND comp.id=ca.ID
LEFT JOIN SUBSCRIPTIONPERIODPARTS spp ON spp.CENTER=s.CENTER AND spp.ID=s.ID AND spp.FROM_DATE<=sysdate AND spp.TO_DATE>=sysdate-1 and SPP_STATE NOT IN (2)
JOIN SPP_INVOICELINES_LINK sppl ON sppl.PERIOD_CENTER=spp.CENTER AND sppl.PERIOD_ID=spp.ID AND sppl.PERIOD_SUBID=spp.SUBID
JOIN INVOICELINES il ON il.CENTER = sppl.INVOICELINE_CENTER AND il.ID=sppl.INVOICELINE_ID AND il.SUBID=sppl.INVOICELINE_SUBID
JOIN INVOICES i on i.center= il.center and i.id = il.id
JOIN PRODUCTS pd on pd.center = il.PRODUCTCENTER and pd.id = il.PRODUCTID 
JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl on pgl.PRODUCT_CENTER = pd.CENTER and pgl.PRODUCT_ID = pd.id 
JOIN PRODUCT_GROUP pg on pg.ID = pgl.PRODUCT_GROUP_ID 
--and pg.name in ('Corporate','Partnership','Corporate Funded')

LEFT JOIN INVOICES spons_i on spons_i.center = i.SPONSOR_INVOICE_CENTER and spons_i.ID = i.SPONSOR_INVOICE_ID
LEFT JOIN INVOICELINES spons_il on spons_il.center = spons_i.center and  spons_il.id = spons_i.id and spons_il.subid = il.SPONSOR_INVOICE_SUBID

WHERE
	spp.SUBSCRIPTION_PRICE > 0
    AND p.STATUS IN (1,3)
    AND p.PERSONTYPE = 4


ORDER BY 
	comp.LASTNAME
*/
