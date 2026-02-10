-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT DISTINCT
        P.EXTERNAL_ID  AS "EXTERNAL_ID",
        SFP.START_DATE AS "FREEZE_START_DATE",
        SFP.END_DATE   AS "FREEZE_END_DATE",
        SFP.TYPE       AS "FREEZE_TYPE",
SFP.*
 FROM
     SUBSCRIPTION_FREEZE_PERIOD sfp
 JOIN
     SUBSCRIPTIONS s
 ON
     sfp.SUBSCRIPTION_CENTER = s.center
 AND sfp.SUBSCRIPTION_ID = s.id
 AND s.STATE = 4
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
 AND p.id = s.OWNER_ID
 WHERE
     sfp.STATE = 'ACTIVE'
 AND sfp.START_DATE <= current_date
 AND sfp.END_DATE+1 >= current_date
 AND s.OWNER_CENTER IN (:center)
 AND p.EXTERNAL_ID = '638939'