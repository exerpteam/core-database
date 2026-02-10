-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
  DISTINCT
    p.EXTERNAL_ID         AS External_ID,
    sfp.START_DATE                                                  AS Freeze_Start_Date,
    sfp.END_DATE                                                    AS Freeze_End_Date,
	sfp.Type
AS Freeze_Type
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