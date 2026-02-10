-- The extract is extracted from Exerp on 2026-02-08
-- Working with Gibbo  on this one for Covid-19 PT by DD refunds
SELECT 
			p.CENTER || 'p' || p.id  member_id,
            p.CENTER  Person_Club,
			sa.center_id Addon_Club,
			TO_CHAR(SA.start_date, 'DD-MM-YYYY') Sub_Start_Date,
			TO_CHAR(SA.End_Date, 'DD-MM-YYYY') Sub_End_Date,
			mpr.CACHED_PRODUCTNAME  add_on_type,
			sa.INDIVIDUAL_PRICE_PER_UNIT
FROM
    SUBSCRIPTION_ADDON sa
left join 
	centers sa_c 
	on sa_c.id = sa.CENTER_ID
JOIN
    SUBSCRIPTIONS s
    ON s.CENTER = sa.SUBSCRIPTION_CENTER
    AND s.ID = sa.SUBSCRIPTION_ID
JOIN
    PERSONS p
    ON p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    MASTERPRODUCTREGISTER mpr
    ON mpr.ID = sa.ADDON_PRODUCT_ID
WHERE 
	mpr.CACHED_PRODUCTNAME like '%PT%'
AND
	P.Center in (
	'76',
'29',
'30',
'437',
'33',
'34',
'35',
'27',
'36',
'421',
'405',
'38',
'438',
'40',
'39',
'47',
'48',
'12',
'51',
'9',
'955',
'56',
'954',
'57',
'59',
'415',
'2',
'60',
'61',
'422',
'452',
'15',
'6',
'68',
'69',
'410',
'16',
'71',
'75',
'953',
'425',
'408')