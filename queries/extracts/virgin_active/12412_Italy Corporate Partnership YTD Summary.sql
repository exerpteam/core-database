with params as (
        select $$start_date$$ as DATE_P from dual
)
SELECT DISTINCT
    comp.CENTER || 'p' || comp.ID as "Company ID",
    comp.LASTNAME AS "Company",
    ca.NAME AS "Company Agreement",
    c.NAME AS "Club", 
    (CASE 
        WHEN pg.NAME in ('Partnership') THEN
                'PARTNERSHIP'
        WHEN pg.NAME in ('Corporate') THEN
                'SPONSORED'
        ELSE 
                'MISSING'
    END) AS "Type",   
    count(*) AS "Subscription Count",
    sum((CASE
        WHEN TRUNC(FROM_DATE, 'MONTH')= FROM_DATE AND LAST_DAY(FROM_DATE)=TO_DATE THEN
                il.TOTAL_AMOUNT
        ELSE
                (il.TOTAL_AMOUNT/(il.TOTAL_AMOUNT+nvl(spons_il.TOTAL_AMOUNT,0)))*spp.SUBSCRIPTION_PRICE
    END)) AS "Member Monthly Fee",
    sum((CASE
        WHEN TRUNC(FROM_DATE, 'MONTH')= FROM_DATE AND LAST_DAY(FROM_DATE)=TO_DATE THEN
                nvl(spons_il.TOTAL_AMOUNT,0)
        ELSE
                (nvl(spons_il.TOTAL_AMOUNT,0)/(nvl(spons_il.TOTAL_AMOUNT,0)+il.TOTAL_AMOUNT))*spp.SUBSCRIPTION_PRICE
    END)) AS "Member fee sponsored"
FROM PERSONS p 
JOIN CENTERS c ON p.CENTER=c.ID
JOIN SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID AND s.STATE IN ($$subType$$)
JOIN SUBSCRIPTIONTYPES st ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID AND st.ST_TYPE NOT IN (0)
JOIN PRODUCTS pr ON st.CENTER = pr.CENTER AND st.ID = pr.ID
JOIN RELATIVES r ON r.CENTER = s.OWNER_CENTER AND r.id = s.owner_ID AND r.RTYPE IN (3) AND r.STATUS<3
JOIN COMPANYAGREEMENTS ca ON ca.CENTER = r.RELATIVECENTER AND ca.ID = r.RELATIVEID AND ca.SUBID = r.RELATIVESUBID
JOIN PERSONS comp ON comp.center = ca.CENTER AND comp.id=ca.ID

LEFT JOIN SUBSCRIPTIONPERIODPARTS spp ON spp.CENTER=s.CENTER AND spp.ID=s.ID AND spp.FROM_DATE<=sysdate AND spp.TO_DATE>=sysdate-1 and SPP_STATE NOT IN (2)
JOIN SPP_INVOICELINES_LINK sppl ON sppl.PERIOD_CENTER=spp.CENTER AND sppl.PERIOD_ID=spp.ID AND sppl.PERIOD_SUBID=spp.SUBID
JOIN INVOICELINES il ON il.CENTER = sppl.INVOICELINE_CENTER AND il.ID=sppl.INVOICELINE_ID AND il.SUBID=sppl.INVOICELINE_SUBID
JOIN INVOICES i on i.center= il.center and i.id = il.id
join PRODUCTS pd on pd.center = il.PRODUCTCENTER and pd.id = il.PRODUCTID 
join PRODUCT_AND_PRODUCT_GROUP_LINK pgl on pgl.PRODUCT_CENTER = pd.CENTER and pgl.PRODUCT_ID = pd.id 
join PRODUCT_GROUP pg on pg.ID = pgl.PRODUCT_GROUP_ID and pg.name in ('Corporate','Partnership')

left join INVOICES spons_i on spons_i.center = i.SPONSOR_INVOICE_CENTER and spons_i.ID = i.SPONSOR_INVOICE_ID
left join INVOICELINES spons_il on spons_il.center = spons_i.center and  spons_il.id = spons_i.id and spons_il.subid = il.SPONSOR_INVOICE_SUBID
CROSS JOIN
        PARAMS
WHERE
        p.CENTER IN ($$scope$$)
        AND  p.STATUS IN (1,3)
        AND p.PERSONTYPE = 4
        AND s.START_DATE >= TRUNC(PARAMS.DATE_P,'YEAR')
        AND s.START_DATE <= PARAMS.DATE_P
group by comp.CENTER, comp.ID, comp.LASTNAME, ca.NAME, c.NAME, pg.NAME
order by comp.LASTNAME

