WITH
    PARAMS AS materialized
    (
        SELECT
           
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1) AS cutDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    cen.EXTERNAL_ID                                                AS Cost,
    cen.ID                                                      AS CenterId,
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID                        AS PersonId,
    CAST(EXTRACT('year' FROM age(p.birthdate)) AS VARCHAR)                          AS Age,
    CASE  sub.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS
    subscription_STATE,
    CASE  sub.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 
    'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END AS
                                              SUBSCRIPTION_SUB_STATE,
    CASE  st.ST_TYPE  WHEN 0 THEN 'CASH'  WHEN 1 THEN 'EFT' END      AS St_Type,
    TO_CHAR(sub.START_DATE, 'YYYY-MM-DD')       AS start_DATE,
    TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') AS binding_END_DATE,
    TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')         AS end_DATE,
    sub.BINDING_PRICE,
    sub.EXTENDED_TO_CENTER,
    CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 
    'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE
FROM
    SUBSCRIPTIONS sub
JOIN PARAMS params ON params.CenterID = sub.CENTER
LEFT JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
AND st.ID = sub.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    CENTERS cen
ON
    sub.OWNER_CENTER = cen.ID
LEFT JOIN
    PERSONS p
ON
    sub.OWNER_CENTER = p.CENTER
AND sub.OWNER_ID = p.ID
WHERE
    sub.CENTER IN (:ChosenScope)
AND sub.END_DATE = params.cutDate
AND p.PERSONTYPE != 2
    -- AND sub.END_DATE BETWEEN From_date AND To_date
    -- AND sub.END_DATE >= TRUNC(current_date)
    -- AND sub.END_DATE < TRUNC(current_date +30)
