-- The extract is extracted from Exerp on 2026-02-08
-- For 3-club non-plus trial
 WITH PARAMS AS MATERIALIZED
 (
         SELECT
                 dateToLongC(TO_CHAR(TRUNC(:FromDate),'YYYY-MM-DD HH24:MI'), c.ID) AS FROM_DATE,
                 dateToLongC(TO_CHAR(TRUNC(:ToDate)+ 1,'YYYY-MM-DD HH24:MI'), c.ID) - 1 AS TO_DATE,
                 c.ID AS CENTER_ID
         FROM
                 CENTERS c
                 WHERE
                                 c.ID IN (:Scope)
 )
 SELECT
         TO_CHAR(longToDateC(sa.CREATION_TIME, sa.CENTER_ID), 'YYYY-MM-DD HH24:MI') AS ADDON_CREATION_TIME,
         sa.SUBSCRIPTION_CENTER || 'ss' || sa.SUBSCRIPTION_ID AS SUBSCRIPTION_ID,
         sa.CENTER_ID AS ADDON_CENTER,
         sa.EMPLOYEE_CREATOR_CENTER || 'emp' || sa.EMPLOYEE_CREATOR_ID AS EMPLOYEE_ID,
         sa.CANCELLED,
         mpr.CACHED_PRODUCTNAME,
         mpr.GLOBALID,
         sa.ID AS ADDON_KEY,
         sa.START_DATE,
         sa.END_DATE
 FROM
         SUBSCRIPTION_ADDON sa
 JOIN
         PARAMS par ON par.CENTER_ID = sa.CENTER_ID
 JOIN
         MASTERPRODUCTREGISTER mpr ON sa.ADDON_PRODUCT_ID = mpr.ID
 WHERE
         mpr.CACHED_PRODUCTNAME = 'BodyTrack'
         AND sa.CREATION_TIME BETWEEN par.FROM_DATE AND par.TO_DATE
