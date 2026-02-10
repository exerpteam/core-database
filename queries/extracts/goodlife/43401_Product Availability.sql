-- The extract is extracted from Exerp on 2026-02-08
-- Lookup product availability by product globalid.

Approved in https://goodlifefitness.atlassian.net/browse/ISSUE-38649
WITH list AS (
SELECT DISTINCT

m.globalid
,m.cached_productname
,CASE
    WHEN pa.scope_type = 'C'
    THEN c.id
    WHEN pa.scope_type = 'A'
    THEN c2.id
    WHEN pa.scope_type = 'T'
    THEN 1
END AS Center_ID
,CASE
    WHEN pa.scope_type = 'C'
    THEN c.name
    WHEN pa.scope_type = 'A'
    THEN c2.name
    WHEN pa.scope_type = 'T'
    THEN 'System'
END AS Center_Name
,a.name AS Area_If_Scoped_by_Area
,m.state

FROM

masterproductregister m

JOIN product_availability pa

ON pa.product_master_key = m.definition_key

LEFT JOIN centers c
ON c.id = pa.scope_id
AND pa.scope_type = 'C'

LEFT JOIN areas a
ON a.id = pa.scope_id
AND pa.scope_type = 'A'

LEFT JOIN area_centers ac
ON ac.area = a.id

LEFT JOIN centers c2
ON ac.center = c2.id

WHERE

NOT (c2.name IS NULL
AND pa.scope_type = 'A')
AND m.globalid IN (:GLOBALID)
AND m.state != 'DELETED'

), types AS (


    SELECT DISTINCT

    m.globalid
    
    ,CASE 
    WHEN p.ptype = 10
    THEN CASE
        WHEN st.periodunit = 0 AND st.st_type IN (1,2)
        THEN TEXT 'Bi-Weekly'
        WHEN st.periodunit = 2 AND st.st_type IN (1,2)
        THEN TEXT 'Monthly'
        WHEN st.st_type = 0
        THEN TEXT 'PIF'
    END
    WHEN p.ptype = 4
    THEN c.clip_count||' Sessions'
    ELSE NULL
    END AS variant_type
    -- ,m.state

    FROM 
    
    list m

    JOIN products p USING (globalid)

    LEFT JOIN subscriptiontypes st
    ON st.center = p.center
    AND st.id = p.id
    AND p.ptype = 10

    LEFT JOIN clipcardtypes c 
    ON c.center = p.center
    AND c.id = p.id
    AND p.ptype = 4
    


)

SELECT

*

FROM

list

JOIN types USING (globalid)
ORDER BY 

center_name
