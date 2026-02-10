-- The extract is extracted from Exerp on 2026-02-08
-- Extract used to find subscription product overrides that have 'Use contract' and the contract template is set to Default
select 

c.SHORTNAME,
mpr.CACHED_PRODUCTNAME,
longtodateC(mpr.last_modified,47)AS LAST_MODIFIED,
mpr.STATE

from MASTERPRODUCTREGISTER mpr

join CENTERS c on mpr.SCOPE_ID = c.ID

join PRODUCTS p on mpr.GLOBALID = p.GLOBALID and p.CENTER = mpr.SCOPE_ID

where mpr.USE_CONTRACT_TEMPLATE =1 and mpr.CONTRACT_TEMPLATE_ID is null and mpr.CACHED_PRODUCTTYPE in (10,5) and mpr.SCOPE_TYPE = 'C'