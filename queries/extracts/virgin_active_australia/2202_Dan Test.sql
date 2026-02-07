-- This is the version from 2026-02-05
--  
SELECT
    /*+ NO_BIND_AWARE */
    centre.SHORTNAME AS club,
    TO_CHAR(sub.start_date, 'DD-MM-YYYY') AS start_date,
    CASE
        WHEN soldbyOverride.CENTER IS NOT NULL
             AND (soldbyOverride.CENTER <> salesperson.CENTER
                  OR soldbyOverride.ID <> salesperson.ID)
        THEN soldbyOverride.FULLNAME
        WHEN salesperson.FULLNAME = 'VA Api' THEN 'Online Join'
        ELSE salesperson.FULLNAME
    END AS sales_person,
    CASE 
        WHEN soldbyOverride.CENTER IS NOT NULL 
             AND (soldbyOverride.CENTER <> salesperson.CENTER
                  OR soldbyOverride.ID <> salesperson.ID)
        THEN salesperson.FULLNAME
        ELSE NULL 
    END AS orig_sales_person,
    TO_CHAR(longtodateC(sub.CREATION_TIME, sub.center), 'DD-MM-YYYY') AS date_joined,
    TO_CHAR(longtodateC(sub.CREATION_TIME, sub.center), 'HH24:MI') AS time_joined,
    owner.CENTER || 'p' || owner.ID AS member_id,
    owner.External_ID,
    owner.FULLNAME AS member_name,
    prod.NAME AS MEMBERSHIP
FROM SUBSCRIPTION_SALES ss
JOIN SUBSCRIPTIONS sub
  ON sub.CENTER = ss.SUBSCRIPTION_CENTER
 AND sub.ID = ss.SUBSCRIPTION_ID
JOIN SUBSCRIPTIONTYPES stype
  ON ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER
 AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
JOIN PRODUCTS prod
  ON stype.CENTER = prod.CENTER
 AND stype.ID = prod.ID
JOIN PERSONS owner
  ON owner.CENTER = sub.OWNER_CENTER
 AND owner.ID = sub.OWNER_ID
JOIN CENTERS centre
  ON owner.CENTER = centre.ID
JOIN STATE_CHANGE_LOG SCL1
  ON SCL1.CENTER = sub.CENTER
 AND SCL1.ID = sub.ID
 AND SCL1.ENTRY_TYPE = 2
 AND SCL1.STATEID IN (2,4,8)
 AND SCL1.ENTRY_START_TIME >=
     EXTRACT(EPOCH FROM (
         DATE_TRUNC('month', CURRENT_DATE)::TIMESTAMP
         AT TIME ZONE 'Australia/Sydney'
     )) * 1000
 AND (
     SCL1.ENTRY_END_TIME IS NULL
     OR SCL1.ENTRY_END_TIME <
     EXTRACT(EPOCH FROM (
         (CURRENT_DATE::TIMESTAMP + INTERVAL '1 day')
         AT TIME ZONE 'Australia/Sydney'
     )) * 1000
 )
LEFT JOIN SUBSCRIPTION_ADDON addon
  ON sub.CENTER = addon.SUBSCRIPTION_CENTER
 AND sub.ID = addon.SUBSCRIPTION_ID
 AND addon.CANCELLED = 0
LEFT JOIN MASTERPRODUCTREGISTER mp
  ON addon.ADDON_PRODUCT_ID = mp.ID
LEFT JOIN EMPLOYEES emp
  ON ss.EMPLOYEE_CENTER = emp.CENTER
 AND ss.EMPLOYEE_ID = emp.ID
LEFT JOIN PERSONS salesperson
  ON salesperson.CENTER = emp.PERSONCENTER
 AND salesperson.ID = emp.PERSONID
LEFT JOIN PERSON_EXT_ATTRS soldby
  ON owner.CENTER = soldby.PERSONCENTER
 AND owner.ID = soldby.PERSONID
 AND soldby.NAME = 'SoldBy'
LEFT JOIN PERSONS soldbyOverride
  ON soldbyOverride.CENTER || 'p' || soldbyOverride.ID = soldby.TXTVALUE
WHERE ss.SUBSCRIPTION_CENTER IN ($$Scope$$)

-- ✅ Month-to-date creation time (Sydney)
AND sub.CREATION_TIME >=
    EXTRACT(EPOCH FROM (
        DATE_TRUNC('month', CURRENT_DATE)::TIMESTAMP
        AT TIME ZONE 'Australia/Sydney'
    )) * 1000
AND sub.CREATION_TIME <
    EXTRACT(EPOCH FROM (
        (CURRENT_DATE::TIMESTAMP + INTERVAL '1 day')
        AT TIME ZONE 'Australia/Sydney'
    )) * 1000

AND prod.NAME NOT IN ('Toddlz','Club V 3-12','Club V 13-15')
AND ss.SUBSCRIPTION_CENTER <> '999'

AND NOT EXISTS (
    SELECT 1
    FROM STATE_CHANGE_LOG SCLCHECK
    WHERE SCLCHECK.CENTER = sub.CENTER
      AND SCLCHECK.ID = sub.ID
      AND SCLCHECK.ENTRY_TYPE = 2
      AND SCLCHECK.STATEID IN (2,3,4,8)
      AND SCLCHECK.SUB_STATE IN (3,4,5,6,7,8)
      AND SCLCHECK.ENTRY_START_TIME >=
          EXTRACT(EPOCH FROM (
              DATE_TRUNC('month', CURRENT_DATE)::TIMESTAMP
              AT TIME ZONE 'Australia/Sydney'
          )) * 1000
      AND (
          SCLCHECK.ENTRY_END_TIME IS NULL
          OR SCLCHECK.ENTRY_END_TIME <
          EXTRACT(EPOCH FROM (
              (CURRENT_DATE::TIMESTAMP + INTERVAL '1 day')
              AT TIME ZONE 'Australia/Sydney'
          )) * 1000
      )
)

AND EXISTS (
    SELECT 1
    FROM PRODUCT_AND_PRODUCT_GROUP_LINK pgl
    WHERE pgl.PRODUCT_CENTER = prod.CENTER
      AND pgl.PRODUCT_ID = prod.ID
      AND pgl.PRODUCT_GROUP_ID = 203
)
GROUP BY
    sub.start_date,
    centre.SHORTNAME,
    salesperson.FULLNAME,
    salesperson.CENTER,
    salesperson.ID,
    soldbyOverride.CENTER,
    soldbyOverride.ID,
    soldbyOverride.FULLNAME,
    sub.CREATION_TIME,
sub.center,
    owner.CENTER,
    owner.ID,
    owner.External_ID,
    owner.FULLNAME,
    prod.NAME
ORDER BY
    sub.CREATION_TIME,
    salesperson.FULLNAME;
