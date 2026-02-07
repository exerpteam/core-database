-- This is the version from 2026-02-05
--  
select pa.center, pa.state,  count(*)
from payment_agreements pa
join ECLUB2.PAYMENT_ACCOUNTS acc on acc.ACTIVE_AGR_CENTER = pa.center and acc.ACTIVE_AGR_ID = pa.id and acc.ACTIVE_AGR_SUBID = pa.SUBID
join ECLUB2.ACCOUNT_RECEIVABLES ar on ar.center = pa.center and ar.id = pa.id
JOIN PERSONS P ON ar.CUSTOMERCENTER = p.center and ar.CUSTOMERID = p.id
group by pa.center, pa.state
order by pa.center, pa.state