-- The extract is extracted from Exerp on 2026-02-08
-- EC-10363
WITH
    params AS MATERIALIZED
    (   SELECT
            TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')-interval '90 days' AS toDate,
            TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')-interval '2 years' AS fromDate,
            c.id                                                         AS centerid,
            c.name
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
    ,
    pmp_xml AS MATERIALIZED
    (   SELECT
            qu.id,
            CAST(convert_from(qu.questions, 'UTF-8') AS XML) AS pxml
        FROM
            questionnaires qu
        WHERE
            qu.id = 1
    )
    ,
    second_Table AS MATERIALIZED
    (   SELECT
            px.id,
            UNNEST(xpath('questionnaire/question/options/option',px.pxml))::TEXT AS test
        FROM
            pmp_xml px
    )
SELECT
    t.fullname       AS "Full name",
    t.external_id    AS "Member ID",
t.pid AS "Person ID",
    t.end_date       AS "Last end date",
    t.leaving_reason AS "Reason for leaving",
    t.center         AS "Center"
FROM
    (   SELECT
            p.fullname,
            p.external_id,
p.center ||'p'|| p.id AS "pid",
            sub.end_date,
            quan.answer_text   AS leaving_reason,
            quan.number_answer AS leaving_reason_id,
            par.name           AS center
        FROM
            persons p
        JOIN
            (   SELECT
                    DISTINCT op.current_person_center,
                    op.current_person_id,
                    s.end_date,
                    RANK() over (
                             PARTITION BY
                                 op.current_person_center,
                                 op.current_person_id
                             ORDER BY
                                 s.end_date DESC) ranking
                FROM
                    persons op
                JOIN
                    subscriptions s
                ON
                    s.owner_center = op.center
                AND s.owner_id = op.id
                WHERE
                    s.state = 3) sub
        ON
            sub.current_person_center = p.center
        AND sub.current_person_id = p.id
        AND sub.ranking = 1
        JOIN
            params par
        ON
            par.centerId = p.center
        LEFT JOIN
            (   SELECT
                    qp.current_person_center,
                    qp.current_person_id,
                    que.answer_text,
                    qa.number_answer,
                    RANK() over (
                             PARTITION BY
                                 qp.current_person_center,
                                 qp.current_person_id
                             ORDER BY
                                 qua.log_time DESC) ranking
                FROM
                    persons qp
                JOIN
                    questionnaire_answer qua
                ON
                    qua.center = qp.center
                AND qua.id = qp.id
                JOIN
                    question_answer qa
                ON
                    qa.answer_center = qua.center
                AND qa.answer_id = qua.id
                AND qa.answer_subid = qua.subid
                JOIN
                    (   SELECT
                            st.id                                               AS questionnaire_id,
                            trim(split_part(split_part(test, '<id>', 2),'<',1))::INT   AS answer_id,
                            trim(split_part(split_part(st.test, '<optionText>', 2),'<',1)) AS
                            answer_text
                        FROM
                            second_table st ) que
                ON
                    que.questionnaire_id = qua.questionnaire_campaign_id
                AND que.answer_id = qa.number_answer
                WHERE
                    qua.questionnaire_campaign_id = 1 ) quan
        ON
            quan.current_person_center = p.center
        AND quan.current_person_id = p.id
        AND quan.ranking = 1
        WHERE
            p.status = 2
        AND sub.end_date BETWEEN par.fromDate AND par.toDate
        AND NOT EXISTS
            (   SELECT
                    1
                FROM
                    tasks ta
                WHERE
                    ta.status IN ('OPEN',
                                  'UNASSIGNED',
                                  'OVERDUE')
                AND ta.person_center = p.center
                AND ta.person_id = p.id) )t
WHERE
    ( 
        t.leaving_reason_id NOT IN (2,3,4,5,10) 
    OR  t.leaving_reason_id IS NULL)