WITH RECURSIVE area_tree
(
        id,
        NAME,
        parent
) 
AS
(   
        SELECT
                a.id,
                a.NAME,
                a.parent
        FROM areas a
        WHERE
                parent in (6,8,11)
        UNION ALL         
        SELECT
                child.id,
                child.name,
                child.parent
        FROM areas child
        JOIN area_tree parent
                ON parent.id = child.parent
        WHERE
                child.blocked = 0
),
AREA_TREE_NAME AS MATERIALIZED
(   
        SELECT
                area_tree.name,
                CAST(substr(area_tree.name,0,position(' ' in area_tree.name)) AS DOUBLE PRECISION) as price,
                ac.CENTER
        FROM area_tree
        JOIN AREA_CENTERS ac
                ON area_tree.ID = ac.AREA
),
PARAMS AS MATERIALIZED
(   
        SELECT
                DATETOLONGC(getcentertime(100),100)::bigint - 42*24*3600*1000::bigint AS WithIn42Days
),
ELEG_PERS AS
(   
        SELECT 
                DISTINCT ch.PERSON_CENTER,
                ch.PERSON_ID
        FROM CHECKINS ch
        CROSS JOIN PARAMS
        WHERE
                -- Step 1.4:
                -- Member with at least one checkin with result Unknown, AccessGranted or
                -- PresenceRegistered in the club
                -- selected in the parameter in the past 42 days. (Logic behind Visit Report)
                ch.CHECKIN_RESULT IN (0,1,2)
                AND ch.CHECKIN_CENTER = $$center$$
                AND ch.CHECKIN_CENTER <> ch.PERSON_CENTER
                AND ch.CHECKIN_TIME > PARAMS.WithIn42Days
),
ELIG_SUB AS MATERIALIZED
(   
        SELECT
                cp.EXTERNAL_ID                  AS ExternalID,
                s.owner_center||'p'||s.OWNER_ID AS Pnumber,
                pr.name                         AS Subscription,
                cp.CENTER                       AS Center,
                pr.PRICE                        AS SubscriptionPrice,
                (
                CASE
                WHEN ( 
                        st.ST_TYPE = 1
                    AND s.BINDING_END_DATE IS NOT NULL
                    AND s.BINDING_END_DATE >= CURRENT_TIMESTAMP)
                THEN s.BINDING_PRICE
                ELSE s.SUBSCRIPTION_PRICE
                END) AS MemberPrice,
                pgl.PRODUCT_GROUP_ID
        FROM ELEG_PERS
        JOIN PERSONS p
                ON p.center = ELEG_PERS.PERSON_CENTER
                AND p.ID = ELEG_PERS.PERSON_ID
        JOIN PERSONS cp
                ON cp.CENTER = p.CURRENT_PERSON_CENTER
                AND cp.ID = p.CURRENT_PERSON_ID
        JOIN SUBSCRIPTIONS s
                ON cp.center = s.OWNER_CENTER
                AND cp.ID = s.OWNER_ID
        JOIN SUBSCRIPTIONTYPES st
                ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
                AND s.SUBSCRIPTIONTYPE_ID = st.ID
        JOIN PRODUCTS pr
                ON s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
                AND s.SUBSCRIPTIONTYPE_ID = pr.ID
		--  Step 3:
        -- Remove any members who have ineligible (single club access) subscriptions.
        -- subscriptions: 'Privs - Monthly - Plus' (202)
        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                ON pgl.PRODUCT_CENTER = pr.CENTER
                AND pgl.PRODUCT_ID = pr.ID
                AND pgl.PRODUCT_GROUP_ID = 202
        WHERE
                -- Step 1.1
                -- Exclude STAFF members.
                cp.PERSONTYPE NOT IN (2) -- exclude staff members
                -- Step 1.2
                -- Members with a subscription in state ACTIVE, TEMPORARY INACTIVE or CREATED where 
                -- the
                -- homeclub is not the selected one in the parameter.
                AND s.STATE IN (2,4,8)
                -- Step 1.3:
                -- Remove subcriptions within those Product Groups
                -- Add-ons (11)
                AND NOT EXISTS
                (   
                        SELECT
                                1
                        FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl
                        WHERE
                                pl.PRODUCT_CENTER = pr.CENTER
                                AND pl.PRODUCT_ID = pr.ID
                                AND pl.PRODUCT_GROUP_ID IN (11) 
                )
                -- Step 2:
                -- Remove any members whose secondary center is defined within the parameters.
                AND NOT EXISTS
                (   
                        SELECT
                                1
                        FROM PERSON_EXT_ATTRS pea
                        WHERE
                                pea.PERSONCENTER = cp.CENTER
                                AND pea.PERSONID = cp.ID
                                AND pea.NAME = 'SECONDARY_CENTER'
                                AND pea.TXTVALUE = ($$center$$)::VARCHAR 
                )
                -- Step 4:
                -- Filter Plus members.
                AND NOT EXISTS
                (   
                        SELECT
                                1
                        FROM    PRODUCT_AND_PRODUCT_GROUP_LINK pl
                        WHERE
                                pl.PRODUCT_CENTER = pr.CENTER
                                AND pl.PRODUCT_ID = pr.ID
                                AND pl.PRODUCT_GROUP_ID = 202
                                AND 
                                (
                                        pr.PRICE >= ($$NEW_PRICE$$ + 50)
                                        OR pr.PRICE < ($$CURRENT_PRICE$$ + 50)
                                )
                )
)
SELECT
        es.ExternalID        AS "External ID",
        es.Pnumber           AS "P number",
        es.Subscription      AS "Subscription",
        es.Center            AS "Center",
        es.SubscriptionPrice AS "Subscription Price",
        es.MemberPrice       AS "Member Price",
        t1.NAME              AS "Access Level Price"
FROM ELIG_SUB es
JOIN AREA_TREE_NAME t1
        ON t1.CENTER = es.CENTER
WHERE
        NOT EXISTS
        (   
                SELECT
                        1
                FROM AREA_TREE_NAME t1
                WHERE
                        es.PRODUCT_GROUP_ID = 202
                        AND t1.price < $$CURRENT_PRICE$$
                        AND es.SubscriptionPrice < $$CURRENT_PRICE$$
        )
        -- Step 5:
        -- Remove members whose 'Access Level Price' column returns a value larger than or equal to the 'New Price' parameter.
        AND EXISTS
        (   
                SELECT
                        1
                FROM AREA_TREE_NAME t1
                WHERE
                        t1.price < $$NEW_PRICE$$
        )