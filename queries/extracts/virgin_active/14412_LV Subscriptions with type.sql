select 

pr.center as Center,
ce.SHORTNAME as Center_Name,
pr.name as Subcription_Name,
pr.GLOBALID as Subscription_Global_ID,
pg.name as ProductGroup,
DECODE(st.ST_TYPE,0,'CASH',1,'EFT','UNDEFINED') as Deduction

from 

PRODUCTS pr

JOIN PRODUCT_GROUP pg

ON pr.PRIMARY_PRODUCT_GROUP_ID = pg.ID

JOIN CENTERS ce

ON pr.CENTER = ce.ID

JOIN
    SUBSCRIPTIONTYPES st
ON
    pr.CENTER = st.CENTER
    AND pr.ID = st.ID

where

pr.PTYPE=10

and

pr.center = 4

and
st.st_type = 0
