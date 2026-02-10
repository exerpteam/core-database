-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-6248
WITH PARAMS AS
(
        SELECT
				/*+ materialize */
                TRUNC(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD HH24:MI')) AS todaysDate,
                c.id AS center_id
        FROM
                CENTERS c
		WHERE
				c.ID in (:Scope)
)
SELECT
        t1.*
FROM
(
        SELECT
                p.EXTERNAL_ID AS Member_External_ID,
                p.CENTER || 'p' || p.ID AS Member_ID,
                (CASE
                       WHEN sub_ext.CENTER IS NOT NULL THEN sub_ext.START_DATE
                       ELSE s.START_DATE
                END) AS Subscription_Start_Date,
                pr.name AS Subscription_Name,
                pr.GLOBALID AS Subscription_Global_ID,
                s.center || 'ss' || s.id AS Subscription_ID,
                s.END_DATE AS Subscription_End_Date,
                s.SUBSCRIPTION_PRICE,
                pr.PRICE AS Product_Price,
                sfp.END_DATE AS Current_Subscription_Freeze_Period_Ends,
                sfp.TYPE AS Current_Subscription_Freeze_Period_Type,
                srp.END_DATE AS Current_Subscription_Free_Period_Ends,
                srp.TYPE AS Current_Subscription_Free_Period_Type,
                (CASE 
                        WHEN r.CENTER IS NOT NULL THEN payer.EXTERNAL_ID
                        ELSE NULL
                END) AS Other_Payer_External_ID,
                sp.PRICE AS Next_Future_Price_Update_Price,
                sp.FROM_DATE AS Next_Future_Price_Update_Date,  
                (  
                        SELECT
                                DISTINCT 1 
                        FROM SUBSCRIPTION_FREEZE_PERIOD sfp_future
                        WHERE
                                sfp_future.SUBSCRIPTION_CENTER = s.CENTER
                                AND sfp_future.SUBSCRIPTION_ID = s.ID
                                AND sfp_future.START_DATE > par.todaysDate
                                AND sfp.STATE = 'ACTIVE'
                ) AS Has_Future_Freeze_Period,
                (  
                        SELECT
                                DISTINCT 1 
                        FROM SUBSCRIPTION_REDUCED_PERIOD srp_future
                        WHERE
                                srp_future.SUBSCRIPTION_CENTER = s.CENTER
                                AND srp_future.SUBSCRIPTION_ID = s.ID
                                AND srp_future.START_DATE > par.todaysDate
                                AND srp_future.STATE = 'ACTIVE'
                                AND srp_future.TYPE NOT IN ('FREEZE')
                ) AS Has_Future_Free_Period,
                CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSON_TYPE,
                (CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 4 THEN 'FROZEN' END) AS Subscription_State,
                rank() over (partition BY s.center,s.id ORDER BY sp.FROM_DATE ASC) AS RNK
        FROM PERSONS p
        JOIN SUBSCRIPTIONS s 
                ON p.center = s.OWNER_CENTER
                AND p.id = s.OWNER_ID
        JOIN PARAMS par
                ON par.center_id = s.CENTER
        JOIN SUBSCRIPTIONTYPES st
                ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
                AND s.SUBSCRIPTIONTYPE_ID = st.ID
        JOIN PRODUCTS pr
                ON st.CENTER = pr.CENTER
                AND st.ID = pr.ID
        LEFT JOIN SUBSCRIPTIONS sub_ext
                ON sub_ext.EXTENDED_TO_CENTER = s.CENTER
                AND sub_ext.EXTENDED_TO_ID = s.ID
        LEFT JOIN SUBSCRIPTION_FREEZE_PERIOD sfp
                ON sfp.SUBSCRIPTION_CENTER = s.CENTER
                AND sfp.SUBSCRIPTION_ID = s.ID
                AND sfp.START_DATE <= par.todaysDate
                AND sfp.END_DATE >= par.todaysDate
                AND sfp.STATE = 'ACTIVE'
        LEFT JOIN SUBSCRIPTION_REDUCED_PERIOD srp
                ON srp.SUBSCRIPTION_CENTER = s.CENTER
                AND srp.SUBSCRIPTION_ID = s.ID
                AND srp.START_DATE <= par.todaysDate
                AND srp.END_DATE >= par.todaysDate
                AND srp.STATE = 'ACTIVE'
                AND srp.TYPE NOT IN ('FREEZE')
        LEFT JOIN RELATIVES r
                ON r.RTYPE = 12
                AND r.RELATIVECENTER = p.CENTER
                AND r.RELATIVEID = p.ID
                AND r.STATUS < 2
        LEFT JOIN PERSONS payer
                ON r.CENTER = payer.CENTER
                AND r.ID = payer.ID
        LEFT JOIN SUBSCRIPTION_PRICE sp
                ON s.CENTER = sp.SUBSCRIPTION_CENTER
                AND s.ID = sp.SUBSCRIPTION_ID
                AND sp.CANCELLED = 0
                AND sp.FROM_DATE > par.todaysDate
        WHERE
                -- Only Active and Temporary Inactive Members
                p.STATUS IN (1,3)
                -- Only ACTIVE or FROZEN
                AND s.STATE IN (2,4)
                -- Exclude CASH subscriptions
                AND st.ST_TYPE NOT IN (0)
                --AND p.center = 159 
                -- Subscription start date < 01.09.2022
                --AND s.START_DATE < TO_DATE('2022-09-01','YYYY-MM-DD')
                -- Subscription Global ID not like PLUS_%399%
                AND pr.GLOBALID NOT LIKE 'PLUS_%399%'
                -- Subscription Global ID not = PLUS_FRIEND Subscription Global ID not = EFT_NORMAL_BUDDY
                AND pr.GLOBALID NOT IN ('PLUS_FRIEND','EFT_NORMAL_BUDDY')           
) t1
WHERE
        t1.Subscription_Start_Date < TO_DATE('2022-11-13','YYYY-MM-DD')
        AND t1.rnk = 1