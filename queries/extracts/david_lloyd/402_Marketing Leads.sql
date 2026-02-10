-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                         AS center
        , datetolongc($$from_date$$::DATE::VARCHAR,c.id)                  AS from_date_long
        , datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long
        , $$from_date$$::DATE                                             AS from_date
        , $$to_date$$::DATE                                             AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , pea_map AS
    (SELECT
        CAST((xpath('//attribute/@id',xml_element))[1] AS                    TEXT) AS attribute_name
        , CAST(unnest((xpath('//attribute/possibleValues/possibleValue/@id',xml_element))) AS TEXT
        ) AS option_id
        ,CAST(unnest( (xpath('//attribute/possibleValues/possibleValue/text()',xml_element))) AS
        TEXT) AS "value"
    FROM
        ( SELECT
            s.id
            , s.scope_type
            , s.scope_id
            , unnest(xpath('//attribute',XMLPARSE(DOCUMENT convert_from(s.mimevalue, 'UTF-8')) ))
            AS xml_element
        FROM
            systemproperties s
        WHERE
            s.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
        AND s.mimetype = 'text/xml') t
    )
    
SELECT
    p.external_id                      AS "External ID"
    ,longtodate(t.creation_time)::DATE AS "Created Date"
    ,CASE p.STATUS
        WHEN 0
        THEN 'Lead'
        WHEN 1
        THEN 'Active'
        WHEN 2
        THEN 'Inactive'
        WHEN 3
        THEN 'TemporaryInactive'
        WHEN 4
        THEN 'Transferred'
        WHEN 5
        THEN 'Duplicate'
        WHEN 6
        THEN 'Prospect'
        WHEN 7
        THEN 'Deleted'
        WHEN 8
        THEN 'Anonymized'
        WHEN 9
        THEN 'Contact'
        ELSE 'Undefined'
    END          AS "Status"
    ,tc.name     AS "Category"
    , ts.name    AS "Step"
    ,lsm."value" AS "Lead Source"
    ,hem."value" AS "How Enquired"
FROM
    params,TASKS t
LEFT JOIN
    PERSONS p
ON
    p.center = t.PERSON_CENTER
AND p.id = t.PERSON_ID
LEFT JOIN
    task_categories tc
ON
    tc.id = t.task_category_id
LEFT JOIN
    task_steps ts
ON
    ts.id = t.step_id
LEFT JOIN
    person_ext_attrs he
ON
    he.personcenter = p.center
AND he.personid = p.id
AND he.name = 'HOWENQ'
LEFT JOIN
    pea_map hem
ON
    hem.option_id = he.txtvalue
AND hem.attribute_name= he.name
LEFT JOIN
    person_ext_attrs ls
ON
    ls.personcenter = p.center
AND ls.personid = p.id
AND ls.name = 'LEADSOURCE'
LEFT JOIN
    pea_map lsm
ON
    lsm.option_id = ls.txtvalue
AND lsm.attribute_name= ls.name
WHERE
    t.creation_time BETWEEN params.from_date_long AND params.to_date_long
AND p.center IN ($$scope$$)