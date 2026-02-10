-- The extract is extracted from Exerp on 2026-02-08
-- CAB: ISSUE-38825
SELECT DISTINCT

    pc.fullname AS "Company Name"
    ,ca.center||'p'||ca.id AS "Company ID"
    ,px.txtvalue AS "Company Type"
    ,accountManager.fullname AS "Key Account Manager"
    ,p.fullname AS "Member Name"
    ,p.center||'p'||p.id AS "Person ID"
    ,p.external_id AS "External ID"
    ,CASE
        WHEN r2.center IS NULL AND p.center IS NOT NULL
        THEN TEXT 'Employee'
        WHEN r2.center IS NOT NULL AND p.center IS NOT NULL
        THEN TEXT'Family'
        ELSE ''
    END AS "Corporate Relation"
    ,r2.relativecenter||'p'||r2.relativeid AS "Linked Employee"
    ,CASE
        WHEN p.status IS NULL
        THEN ''
        ELSE bi_decode_field('PERSONS', 'STATUS', p.status) 
    END AS "Member Status"
    ,CASE
        WHEN ppgl.product_center IS NOT NULL
        THEN pr.name 
        ELSE ''
    END AS "Subscription Name"
    ,CASE
        WHEN ppgl.product_center IS NOT NULL
        THEN s.start_date
        ELSE NULL
    END AS "Start date"
    ,CASE
        WHEN ppgl.product_center IS NOT NULL
        THEN s.end_date
        ELSE NULL
    END AS "End date"
    ,CASE
        WHEN ppgl.product_center IS NOT NULL
        THEN sp.price
        ELSE NULL
    END AS "Price"
    


FROM

companyagreements ca

JOIN persons pc
ON pc.center = ca.center
AND pc.id = ca.id
AND pc.sex = 'C'
AND ca.state NOT IN (3,5,6)

JOIN 
(

    SELECT

    rx.relativecenter AS center
    ,rx.relativeid AS id

    FROM
    relatives rx

    WHERE
    rx.rtype = 6 -- Subsidiary Company
    AND rx.status = 1
    AND (rx.center,rx.id) = :ID -- Main Company

    UNION

    SELECT
    
    center
    ,id

    FROM

    persons

    WHERE
    (center,id) = :ID -- Main Company


) rz
ON pc.center = rz.center
AND pc.id = rz.id


JOIN person_ext_attrs px
ON px.personcenter = pc.center
AND px.personid = pc.id
AND px.name = 'COMPANYTYPE'

JOIN relatives r
ON ca.center = r.relativecenter
AND ca.id = r.relativeid
AND ca.subid = r.relativesubid
AND r.rtype = 3
AND r.status != 3 -- Not Blocked
-- AND r.status = 1 -- Active only 

JOIN persons p
ON p.center = r.center
AND p.id = r.id

LEFT JOIN relatives r2
ON r.center = r2.center
AND r.id = r2.id
AND r2.rtype = 16
AND r2.status != 3 -- Not Blocked
-- AND r2.status = 1 -- Active only

LEFT JOIN subscriptions s
ON s.owner_center = p.center
AND s.owner_id = p.id
AND s.state IN (2,4)
-- AND px.txtvalue IN ('KAP','KAFP','CERT','CONTRA')

LEFT JOIN product_and_product_group_link ppgl
ON ppgl.product_center = s.subscriptiontype_center
AND ppgl.product_id = s.subscriptiontype_id
AND CASE
    WHEN px.txtvalue = 'CERT'
    THEN ppgl.product_group_id IN (12601,12603)
    WHEN px.txtvalue = 'CONTRA'
    THEN ppgl.product_group_id = 5801
    WHEN px.txtvalue IN ('KAP','KAFP')
    THEN ppgl.product_group_id = 4201
    ELSE false
END

LEFT JOIN products pr
ON pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id

LEFT JOIN subscription_price sp
ON sp.subscription_center = s.center
AND sp.subscription_id = s.id
AND sp.cancelled = false
AND (
        (
            sp.to_date IS NULL
            AND sp.from_date <= CURRENT_DATE
        )
        OR (
            CURRENT_DATE BETWEEN sp.from_date AND sp.to_date
        )
)

LEFT JOIN relatives relaccount
        ON relaccount.center = pc.center
           AND relaccount.id = pc.id
           AND relaccount.rtype = 10
           AND relaccount.status != 3
LEFT JOIN persons accountManager
        ON accountManager.center = relaccount.relativecenter
           AND accountManager.id = relaccount.relativeid

WHERE

s.center IS NULL
OR (s.center IS NOT NULL AND ppgl.product_group_id IS NOT NULL)