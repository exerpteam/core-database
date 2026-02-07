WITH
    params AS materialized
    (
        SELECT
            id                                                                     AS center_id,
            CAST(datetolongc(TO_CHAR(to_date(:From_Date,'YYYY-MM-DD'),'YYYY-MM-DD'),id) AS BIGINT) AS from_Date,
            CAST(datetolongc(TO_CHAR(to_date(:To_Date,'YYYY-MM-DD'),'YYYY-MM-DD'),id) AS BIGINT) + 24*3600*1000 AS  to_date
        FROM
            centers
        WHERE 
            id in (:Scope)            
    )
, pt_subs AS
    (   SELECT
            s.center,
            p.external_id     AS "Member ID",
            p.fullname           AS "Member Name",
            s.center||'ss'||s.id AS ptsubid,
            pr.name              AS "PT Subscription Name",
            s.start_date,
            s.subscription_price,
            s.owner_center,
            s.owner_id,
            sp.fullname,
            TO_CHAR(longtodatec(s.creation_time,s.center),'MM/DD/YYYY') as sales_created
        FROM
            subscriptions s
        JOIN
            params
        ON
            s.center = params.center_id
            AND s.creation_time >= params.from_date
            AND s.creation_time < params.to_date                            
        JOIN
            subscriptiontypes st
        ON
            s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id
        AND st.st_type = 2
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        JOIN
            persons p
        ON
            p.center = s.owner_center
        AND p.id = s.owner_id
        LEFT JOIN
            persons sp
        ON
            s.creator_center = sp.center
            AND s.creator_id = sp.id            
     )
SELECT 
    pt.center AS "Center",
    pt."Member ID",
    pt."Member Name",
    pt."PT Subscription Name", 
    TO_CHAR(pt.start_date, 'MM/DD/YYYY') AS  "PT Start Date",
    pt.sales_created  AS "PT Created at",
    pr2.name AS "Other Subscription",
    pt.fullname AS "Sales Created By" 
FROM 
    pt_subs pt
JOIN
    subscriptions s2
ON
    pt.owner_center = s2.owner_center
    AND pt.owner_id = s2.owner_id
    AND pt.ptsubid <> s2.center||'ss'||s2.id
    AND s2.state in (2,4,8)    
JOIN
    subscriptiontypes st2
ON 
    s2.subscriptiontype_center = st2.center
    AND s2.subscriptiontype_id = st2.id
    AND st2.st_type < 2
JOIN
    products pr2
ON
    pr2.center = st2.center
    AND pr2.id = st2.id         
