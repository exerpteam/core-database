-- This is the version from 2026-02-05
--  
WITH
    leave_quest AS
    (SELECT
        *
        , CAST(CAST((xpath('//question/id/text()',xml_element))[1] AS TEXT) AS INTEGER) AS qqid
        , CAST(CAST((xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))[
        1] AS TEXT) AS INTEGER) AS AID
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
            q.name = 'Reason for Leaving'-- Reason for Leaving
        ) t
    )
    , leave_reason_answer AS
    ( SELECT
        *
    FROM
        (SELECT
            QUN.CENTER
            , QUN.ID
            ,qun.LOG_TIME
            , leave_quest.ANSWER_TEXT
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
            leave_quest
        ON
            leave_quest.ID = QC.QUESTIONNAIRE
        AND qa.QUESTION_ID = leave_quest.qqid
        AND qa.NUMBER_ANSWER = leave_quest.AID
        WHERE
            qun.COMPLETED = 1)
    WHERE
        rnk = 1
    )
    , scStop AS
    (SELECT
        *
    FROM
        (SELECT
            scStop.*
            ,ROW_NUMBER() over (
                            PARTITION BY
                                scStop.OLD_SUBSCRIPTION_CENTER
                                , scStop.OLD_SUBSCRIPTION_ID
                            ORDER BY
                                scStop.CHANGE_TIME DESC) AS rnk
        FROM
            SUBSCRIPTION_CHANGE scStop -- The newly introduced join to fetch lesser rows
        WHERE
            scStop.TYPE = 'END_DATE' )
    WHERE
        rnk =1
    )
SELECT
    c.id                   AS "Center ID"
    ,c.name                AS "Center Name"
    ,p.external_id         AS "External ID"
    ,p.center||'p'||p.id   AS "Member ID"
    ,pr.name               AS "Subscription Name"
    , s.end_Date           AS "Subscription end date"
    , scStopstaff.fullname AS "Staff who cancelled the subscription"
    ,CASE
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
            hobaddebt.last_edit_time) = hobaddebt.last_edit_time
        THEN hobaddebt.txtvalue
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
            hobaddebt.last_edit_time) = reasonforleaving.last_edit_time
        THEN reasonforleaving.txtvalue
        ELSE leave_reason_answer.answer_text
    END AS "Reason For Leaving"
FROM
    persons p
JOIN
    subscriptions s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
AND s.state IN (1,2,3,4,7,8)
JOIN
    centers c
ON
    c.id = p.center
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
LEFT JOIN
    leave_reason_answer
ON
    leave_reason_answer.center = p.center
AND leave_reason_answer.id = p.id
LEFT JOIN
    PERSON_EXT_ATTRS hobaddebt
ON
    p.center=hobaddebt.PERSONCENTER
AND p.id=hobaddebt.PERSONID
AND hobaddebt.name='HOBADDEBT'
LEFT JOIN
    PERSON_EXT_ATTRS reasonforleaving
ON
    p.center=reasonforleaving.PERSONCENTER
AND p.id=reasonforleaving.PERSONID
AND reasonforleaving.name='REASONFORLEAVING'
LEFT JOIN
    scStop
ON
    scStop.old_subscription_center = s.center
AND scStop.old_subscription_id = s.id
LEFT JOIN
    employees escStopEmp
ON
    escStopEmp.center = scStop.EMPLOYEE_CENTER
AND escStopEmp.id = scStop.EMPLOYEE_ID
LEFT JOIN
    persons scStopstaff
ON
    escStopEmp.PERSONCENTER = scStopstaff.center
AND escStopEmp.PERSONID =scStopstaff.id
WHERE
    s.end_DAte IS NOT NULL
AND s.end_Date != (date_trunc('month',s.end_Date) + interval '1 month' - interval '1 day')::DATE
and s.end_Date between  $$from_date$$ and $$to_date$$
and s.center in ($$scope$$)
AND NOT EXISTS
    (SELECT
        1
    FROM
        product_and_product_group_link ppgl
    WHERE
        ppgl.product_center = st.center
    AND ppgl.product_id = st.id
    AND ppgl.product_group_id IN ( 341))--gymflex ,GYMFLEX (C),trial