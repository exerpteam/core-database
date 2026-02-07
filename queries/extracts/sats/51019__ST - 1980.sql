select  s.CENTER  || 'ss' ||  s.ID ssid, s.OWNER_CENTER || 'p' || s.OWNER_ID pid ,sa.START_DATE addon_start,s.START_DATE sub_start, sa.END_DATE addon_end_date,sa.INDIVIDUAL_PRICE_PER_UNIT,s.BILLED_UNTIL_DATE  from MASTERPRODUCTREGISTER mpr 
join SUBSCRIPTION_ADDON sa on sa.ADDON_PRODUCT_ID = mpr.ID
join SUBSCRIPTIONS s on s.CENTER = sa.SUBSCRIPTION_CENTER and s.id = sa.SUBSCRIPTION_ID
where mpr.CACHED_PRODUCTNAME in ('HiYoga city','HiYoga country','HiYoga one club','HiYoga nordic')
and (sa.END_DATE is null or sa.END_DATE < exerpsysdate())
and sa.CANCELLED = 0