-- The extract is extracted from Exerp on 2026-02-08
-- Braze Freeze Data
 SELECT DISTINCT
        P.EXTERNAL_ID  AS "EXTERNAL_ID",
        SFP.START_DATE AS "FREEZE_START_DATE",
        SFP.END_DATE   AS "FREEZE_END_DATE",
        SFP.TYPE       AS "FREEZE_TYPE"
 FROM
     SUBSCRIPTION_FREEZE_PERIOD sfp
 JOIN
     SUBSCRIPTIONS s
 ON
     sfp.SUBSCRIPTION_CENTER = s.center
 AND sfp.SUBSCRIPTION_ID = s.id
 AND s.STATE = 4
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = st.ID
 JOIN
     (
         SELECT
             sfp2.SUBSCRIPTION_CENTER,
             sfp2.SUBSCRIPTION_ID,
             MAX(sfp2.START_DATE) START_DATE
         FROM
             SUBSCRIPTION_FREEZE_PERIOD sfp2
         WHERE
             sfp2.STATE <> 'CANCELLED'
             AND sfp2.START_DATE <= current_date
             AND sfp2.END_DATE+1 >= current_date
         GROUP BY
             sfp2.SUBSCRIPTION_CENTER,
             sfp2.SUBSCRIPTION_ID
     ) current_freeze
 ON
     current_freeze.SUBSCRIPTION_CENTER = sfp.SUBSCRIPTION_CENTER
         AND current_freeze.SUBSCRIPTION_ID = sfp.SUBSCRIPTION_ID
         AND sfp.START_DATE = current_freeze.START_DATE
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
 AND p.id = s.OWNER_ID
 WHERE
     sfp.STATE = 'ACTIVE'
 AND s.OWNER_CENTER IN (:center)
