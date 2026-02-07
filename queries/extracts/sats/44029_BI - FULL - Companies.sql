select 
    c.COMPANY_ID
  , c.HOME_CENTER_ID
  , c.NAME
  , c.COUNTRY_ID
  , c.POSTAL_CODE
  , c.CITY
  , c.ACCOUNT_MANAGER_ID
  , c.STATUS 
from BI_COMPANIES c
where c.HOME_CENTER_ID in ($$Scope$$)