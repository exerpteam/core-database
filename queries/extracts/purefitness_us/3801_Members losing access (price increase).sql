WITH 
    RECURSIVE area_tree
    (
        id,
        NAME,
        parent
    ) 
    AS
    (   SELECT
            id,
            NAME,
            parent
        FROM
            areas
        WHERE
            id = 65 -- Access Tier
        AND parent IS NULL
         
        UNION ALL
         
        SELECT
            child.id,
            child.name,
            child.parent
        FROM
            areas child
        JOIN
            area_tree parent
        ON
            parent.id = child.parent
        WHERE
            child.blocked = 0
    )
    ,
    AREA_TREE_NAME  AS materialized
    (   SELECT
            area_tree.name,
            ac.CENTER
        FROM
            area_tree
        JOIN
            AREA_CENTERS ac
        ON
            area_tree.ID = ac.AREA
        WHERE
            area_tree.name LIKE '$%'
    )
    ,
    PARAMS  AS materialized
    (   SELECT
            DATETOLONGC(getcentertime(100),100)::bigint - 42*24*3600*1000::bigint AS WithIn42Days
    )
    ,
    ELEG_PERS AS
    (   SELECT 
            DISTINCT ch.PERSON_CENTER,
            ch.PERSON_ID
        FROM
            CHECKINS ch
        CROSS JOIN
            PARAMS
join persons p 
        on    
       ch.PERSON_CENTER = p.center
       and ch.PERSON_ID = p.id
        WHERE
            -- Step 1.4:
            -- Member with at least one checkin with result Unkown, AccessGranted or
            -- PresenceRegistered in the club
            -- selected in the parameter in the past 42 days. (Logic behind Visit Report)
            ch.CHECKIN_RESULT IN (0,1,2)
        AND ch.CHECKIN_CENTER = :center
        AND ch.CHECKIN_CENTER <> p.TRANSFERS_CURRENT_PRS_CENTER
        AND ch.CHECKIN_TIME > PARAMS.WithIn42Days
    ) 
  ,
    ELIG_SUB AS materialized
    (   SELECT
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
                    AND s.BINDING_END_DATE >= TRUNC(CURRENT_TIMESTAMP))
                THEN s.BINDING_PRICE
                ELSE s.SUBSCRIPTION_PRICE
            END) AS MemberPrice,
            pgl.PRODUCT_GROUP_ID
        FROM
            ELEG_PERS
        JOIN
           
            PERSONS p
        ON
            p.center = ELEG_PERS.PERSON_CENTER
        AND p.ID = ELEG_PERS.PERSON_ID
        JOIN
           
            PERSONS cp
        ON
            cp.CENTER = p.CURRENT_PERSON_CENTER
        AND cp.ID = p.CURRENT_PERSON_ID
        JOIN
            SUBSCRIPTIONS s
        ON
            cp.center = s.OWNER_CENTER
        AND cp.ID = s.OWNER_ID
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
        AND s.SUBSCRIPTIONTYPE_ID = st.ID
        JOIN
            PRODUCTS pr
        ON
            s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
        AND s.SUBSCRIPTIONTYPE_ID = pr.ID
        LEFT JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK pgl
        ON
            pgl.PRODUCT_CENTER = pr.CENTER
        AND pgl.PRODUCT_ID = pr.ID
       -- AND pgl.PRODUCT_GROUP_ID = 10001
        WHERE
            -- Step 1.1
            -- Exclude STAFF members.
            cp.PERSONTYPE <> 2 -- exclude staff members
            -- Step 1.2
            -- Members with a subscription in state ACTIVE, TEMPORARY INACTIVE or CREATED where 
            -- the
            -- homeclub is not the selected one in the parameter.
        AND s.STATE IN (2,4,8)
        AND cp.CENTER != :center
            -- Step 1.3:
            -- Remove subcriptions within those Product Groups
            -- Add-ons (9), Temp Access (6410)
        AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pl
                WHERE
                    pl.PRODUCT_CENTER = pr.CENTER
                AND pl.PRODUCT_ID = pr.ID
                AND pl.PRODUCT_GROUP_ID IN (11) )
            -- Step 2:
            -- Remove any members whose secondary center is defined within the parameters.
        AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    
                    PERSON_EXT_ATTRS pea
                WHERE
                    pea.PERSONCENTER = cp.CENTER
                AND pea.PERSONID = cp.ID
                AND pea.NAME = 'SECONDARY_CENTER'
                AND pea.TXTVALUE = (:center)::VARCHAR )
            --  Step 3:
            -- to only count members if their primary subscription is within any of the following
            -- subscriptions:
            -- 'Direct Debit Premium 6408 ', 'Plus Subscriptions MS 6407', 'Multi Subscriptions MS
            -- 10001
        AND EXISTS
            (   SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pl
                WHERE
                    pl.PRODUCT_CENTER = pr.CENTER
                AND pl.PRODUCT_ID = pr.ID
                AND pl.PRODUCT_GROUP_ID IN (208) )
            -- Step 4.2:
            -- Filter legacy members. PG 10001 Direct Debit Premium
            -- Remove any legacy members whose primary subscription product price (the live price
            -- of the product) is equal or higher than the ‘new price’ parameter.
        /*AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pl
                WHERE
                    pl.PRODUCT_CENTER = pr.CENTER
                AND pl.PRODUCT_ID = pr.ID
                AND pl.PRODUCT_GROUP_ID = 10001
                AND pr.PRICE >= :NEW_PRICE )*/
            -- Step 5:
            -- Filter Plus members. PG 6407 Plus Subscriptions MS
            -- Remove any plus members whose primary subscription product price (the live price of
            -- the product) is equal to or higher than the value of the ‘new price’ parameter plus
            -- 5.00.
            -- Remove any plus members whose primary subscription product price is (the live price
            -- of the product) is lower than the value of the ‘current price’ parameter plus 5.00.
        AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pl
                WHERE
                    pl.PRODUCT_CENTER = pr.CENTER
                AND pl.PRODUCT_ID = pr.ID
                AND pl.PRODUCT_GROUP_ID = 208
                AND 
                    (
                        pr.PRICE >= :NEW_PRICE + 7
                    OR  pr.PRICE < :CURRENT_PRICE + 7 ) ))
            -- Step 6:
            -- Filter Multi members. PG 6408 Multi Subscriptions
            -- Remove any multi members whose primary subscription product price (the live price 
            -- of
            -- the product) is equal to or higher than the value of the ‘new price’ parameter plus
            -- 2.00.
            -- Remove any multi members whose primary subscription product price (the live price 
            -- of
            -- the product) is lower than the value of the ‘current price’ parameter plus 2.00.
       /* AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pl
                WHERE
                    pl.PRODUCT_CENTER = pr.CENTER
                AND pl.PRODUCT_ID = pr.ID
                AND pl.PRODUCT_GROUP_ID = 6408
                AND 
                    (
                        pr.PRICE >= :NEW_PRICE + 2
                    OR  pr.PRICE < :CURRENT_PRICE + 2 ) )*/
 --   ) 
   
SELECT distinct
    es.ExternalID        AS "External ID",
    es.Pnumber           AS "P number",
    es.Subscription      AS "Subscription",
    es.Center            AS "Center",
    es.SubscriptionPrice AS "Subscription Price",
    es.MemberPrice       AS "Member Price",
    t1.NAME              AS "Access Level Price"
FROM
    ELIG_SUB es
JOIN
    AREA_TREE_NAME t1
ON
    t1.CENTER = es.CENTER
WHERE
    --es.Pnumber in ('221p11832') AND
    -- Step 4.1:
    -- Filter legacy members. PG 10001 Direct Debit Premium
    -- Remove any legacy members whose home club is scoped equal to or higher than the ‘new price’
    -- parameter within the ‘Access Tier ()’ scope.
  /*  NOT EXISTS
    (   SELECT
            1
        FROM
            AREA_TREE_NAME t1
        WHERE
            es.PRODUCT_GROUP_ID = 10001
        AND CAST((REPLACE(t1.name,'£','')) AS DOUBLE PRECISION) >= :NEW_PRICE*/
            --AND to_number(REPLACE(t1.name,'£')) >= :NEW_PRICE
  --  )
    -- Step 4.3:
    -- Filter legacy members. PG 10001 Direct Debit Premium
    -- Remove any legacy members whose home club is scoped lower than the ‘old price’
    -- parameter within the ‘Access Tier ()’ scope AND whose primary subscription product
    -- price (the live price of the product) is lower than the ‘current price’ parameter.
/*AND NOT EXISTS
    (   SELECT
            1
        FROM
            AREA_TREE_NAME t1
        WHERE
            es.PRODUCT_GROUP_ID = 10001
        AND CAST((REPLACE(t1.name,'£','')) AS DOUBLE PRECISION) < :CURRENT_PRICE*/
            --AND to_number(REPLACE(t1.name,'£')) < :CURRENT_PRICE
    /*  AND es.SubscriptionPrice < :CURRENT_PRICE*/
  --    )
      
    -- Step 7:
    -- Filter all members
    -- Remove any members where 'Access Level Price' is equal to or greater
    -- than the 'new price'
EXISTS
    (   SELECT
            1
        FROM
            AREA_TREE_NAME t1
        WHERE
            CAST((REPLACE(t1.name,'$','')) AS DOUBLE PRECISION) < :NEW_PRICE
          
    )