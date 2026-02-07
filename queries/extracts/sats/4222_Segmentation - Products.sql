select
pd.CENTER,
pd.ID,
DECODE(pd.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata') as PTYPE,
pd.blocked,
pd.name,
pd.COMENT,
pd.EXTERNAL_ID,
pd.price,
pd.MIN_PRICE,
pd.COST_PRICE,
pd.GLOBALID
from ECLUB2.PRODUCTS pd
where 
pd.ptype in (4,5,10) 
and 
pd.center >= :FromCenter
    and pd.center <= :ToCenter