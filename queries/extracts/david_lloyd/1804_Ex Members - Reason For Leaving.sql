-- The extract is extracted from Exerp on 2026-02-08
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
SELECT
    DISTINCT p.external_id    AS "Person Id"
    , p.center || 'p' || p.id AS "Member Id"
    , CASE
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
WHERE
    p.center IN ($$scope$$)
AND p.status = 2