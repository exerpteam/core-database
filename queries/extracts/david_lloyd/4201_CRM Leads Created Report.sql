-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                        AS center
        , datetolongc($$from_date$$:: DATE::VARCHAR,c.id)                  AS from_date_long
        , datetolongc($$to_date$$:: DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long
        , datetolongc(add_months($$from_date$$:: DATE,-3)::VARCHAR,c.id)   AS from_3_months_date_long
        , $$from_date$$:: DATE                                             AS from_date
        , $$to_date$$:: DATE                                             AS to_date
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
    , first_activity AS
    ( SELECT
        t.id                 AS task_id
        ,COUNT(tl.id)        AS activity_count
        , MIN(tl.entry_time) AS first_activity
    FROM
        task_log tl
    JOIN
        tasks t
    ON
        t.id = tl.task_id
    JOIN
        TASK_TYPES tt
    ON
        tt.id = t.type_id
    JOIN
        WORKFLOWS wf
    ON
        wf.ID = tt.WORKFLOW_ID
    JOIN
        task_actions ta
    ON
        ta.id = tl.task_action_id
    JOIN
        persons p
    ON
        p.center = t.person_center
    AND p.id = t.person_id
    WHERE
        wf.name = 'Lead Management'
    GROUP BY
        t.id
    )
    , included_subs AS
    (SELECT
        DISTINCT s.*
        ,ROW_NUMBER() over (
                        PARTITION BY
                            p.transfers_current_prs_center
                            ,p.transfers_current_prs_id
                        ORDER BY
                            (s.state IN (2,4))::INTEGER DESC
                            ,s.creation_time ASC
                            , (ppgl.product_center IS NOT NULL)::INTEGER DESC) AS rnk
    FROM
        subscriptions s
    LEFT JOIN
        product_and_product_group_link ppgl
    ON
        ppgl.product_center = s.subscriptiontype_center
    AND ppgl.product_id = s.subscriptiontype_id
    AND ppgl.product_group_id= 203
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    JOIN
        persons p
    ON
        p.center = s.owner_center
    AND p.id = s.owner_id
    )
    , not_join_quest AS
    (SELECT
        *
        , CAST(CAST((xpath('//question/id/text()',xml_element))[1] AS TEXT) AS INTEGER) AS qqid
        , CAST((xpath('//question/ questionText/text()',xml_element))[1] AS TEXT)       AS
        questionText
    FROM
        ( SELECT
            Q.id
            , Q.name
            , q.CREATION_TIME
            , q.externalid
            , unnest(xpath('//question',XMLPARSE(DOCUMENT convert_from(q.QUESTIONS, 'UTF-8')) ))
            AS xml_element
        FROM
            QUESTIONNAIRES q
        WHERE
            q.name = 'Reasons for Not Joining' ) t
    )
    , not_join_quest_ans AS
    (SELECT
        *
        , CAST(CAST((xpath('//question/id/text()',xml_element))[1] AS TEXT) AS INTEGER) AS qqid
        , CAST(CAST((xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))[
        1] AS TEXT) AS INTEGER)                                                   AS AID
        , CAST((xpath('//question/ questionText/text()',xml_element))[1] AS TEXT) AS questionText
        , CAST((xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element))
        ))[1 ] AS TEXT) AS ANSWER_TEXT
    FROM
        ( SELECT
            Q.id
            , Q.name
            , q.CREATION_TIME
            , q.externalid
            , unnest(xpath('//question',XMLPARSE(DOCUMENT convert_from(q.QUESTIONS, 'UTF-8')) ))
            AS xml_element
        FROM
            QUESTIONNAIRES q
        WHERE
            q.name = 'Reasons for Not Joining' ) t
    )
    , not_join_answer AS
    ( SELECT
        CENTER
        , ID
        ,LOG_TIME
        ,MAX(
        CASE
            WHEN questiontext = 'Please tell us more'
            THEN ANSWER_TEXT
            ELSE NULL
        END) AS tell_us_more
        ,MAX(
        CASE
            WHEN questiontext LIKE 'Why have you not joined%'
            THEN ANSWER_TEXT
            ELSE NULL
        END) AS why_not_join
    FROM
        (SELECT
            QUN.CENTER
            , QUN.ID
            ,qun.LOG_TIME
            ,not_join_quest.                                          questionText
            , COALESCE(not_join_quest_ans.ANSWER_TEXT,QA.text_answer) ANSWER_TEXT
            , ROW_NUMBER() over (
                             PARTITION BY
                                 qun.center
                                 , qun.id
                             ORDER BY
                                 qun.LOG_TIME DESC) AS rnk
        FROM
            QUESTION_ANSWER QA
        JOIN
            QUESTIONNAIRE_ANSWER QUN
        ON
            QA.ANSWER_CENTER = QUN.CENTER
        AND QA.ANSWER_ID = QUN.ID
        AND QA.ANSWER_SUBID = QUN.SUBID
        JOIN
            QUESTIONNAIRE_CAMPAIGNS QC
        ON
            QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
        JOIN
            not_join_quest
        ON
            not_join_quest.ID = QC.QUESTIONNAIRE
        AND qa.QUESTION_ID = not_join_quest.qqid
        LEFT JOIN
            not_join_quest_ans
        ON
            not_join_quest.ID = QC.QUESTIONNAIRE
        AND qa.QUESTION_ID = not_join_quest_ans.qqid
        AND qa.NUMBER_ANSWER = not_join_quest_ans.AID
        WHERE
            qun.COMPLETED = 1 )
    WHERE
        rnk = 1
    GROUP BY
        CENTER
        , ID
        ,LOG_TIME
    )
SELECT
    c.name       AS "Club"
    , a.name     AS "Region"
    , p.fullname AS "Lead Name"
    ,CASE cp.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END                                                    AS "Person Status"
    , email.txtvalue                                       AS "Email"
    , phone.txtvalue                                       AS "Telephone Number"
    ,lsm."value"                                           AS "Source"
    ,hem."value"                                           AS "How Enquired"
    , p.zipcode                                            AS "Post Code"
    , ap.fullname                                          AS "Assigned To"
    ,longtodatec(t.creation_time ,p.center)::TEXT          AS "Enquiry Originated Date and Time"
    , longtodatec(first_activity.first_activity ,p.center) AS
    "Enquiry First activity Date and Time"
    , age(longtodatec(first_activity.first_activity,p.center) , longtodatec(t.creation_time,
    p.center))                                                           AS "Time to first activity"
    , age(longtodatec(s.creation_time,p.center) , longtodatec(t.creation_time,p.center)) AS
    "Enquiry to Sale Time"
    , first_activity.activity_count          AS "Number of activities"
    , longtodatec(s.creation_time ,p.center) AS "Join Date"
    , s.start_Date                           AS "Start Date"
    , cp.external_id                          AS "Member Ref Number"
    , s.center||'ss'||s.id                   AS "Membership Number"
    , pr.name                                AS "Membership Type"
    , ts.name                                AS "Blowout  / blowout lapsed"
    , CASE
        WHEN ts.name = 'Blow Out Lapsed'
        THEN ts.name
        ELSE COALESCE( not_join_answer.why_not_join,not_join_answer.tell_us_more)
    END AS "blowout reason"
FROM
    params
JOIN
    tasks t
ON
    params.center = t.person_center
JOIN
    TASK_TYPES tt
ON
    tt.id = t.type_id
JOIN
    WORKFLOWS wf
ON
    wf.ID = tt.WORKFLOW_ID
JOIN
    persons p
ON
    p.center = t.person_center
AND p.id = t.person_id
JOIN
    centers c
ON
    c.id = p.center
JOIN
    area_centers ac
ON
    c.id = ac.center
JOIN
    areas a
ON
    a.id = ac.area
AND a.root_area = 11
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
AND p.id=email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS phone
ON
    p.center =phone.PERSONCENTER
AND p.id =phone.PERSONID
AND phone.name='_eClub_PhoneHome'
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
LEFT JOIN
    employees aemp
ON
    aemp.center = t.asignee_center
AND aemp.id = t.asignee_id
LEFT JOIN
    persons ap
ON
    ap.center = aemp.personcenter
AND ap.id = aemp.personid
LEFT JOIN
    first_activity
ON
    first_activity.task_id = t.id
LEFT JOIN
    included_subs s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.creation_time >= t.creation_time
AND s.rnk = 1
LEFT JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
LEFT JOIN
    task_steps ts
ON
    ts.id = t.step_id
AND ts.name IN ('Blow Out Lapsed'
                ,'Blow Out')
LEFT JOIN
    not_join_answer
ON
    not_join_answer.center = p.center
AND not_join_answer.id = p.id
JOIN 
    persons cp 
ON 
    cp.center = p.transfers_current_prs_center 
AND cp.id = p.transfers_current_prs_id
WHERE
    wf.name = 'Lead Management'
AND t.creation_time BETWEEN params.from_Date_long AND params.to_date_long