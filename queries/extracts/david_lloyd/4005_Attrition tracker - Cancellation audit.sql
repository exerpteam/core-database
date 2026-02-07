-- This is the version from 2026-02-05
-- members who do have a stop date a different date than last of the month. EC-10559
WITH sc_stop AS (
    SELECT *
    FROM (
        SELECT
            sc.*,
            ROW_NUMBER() OVER (
                PARTITION BY sc.old_subscription_center, sc.old_subscription_id
                ORDER BY sc.change_time DESC
            ) AS rnk
        FROM subscription_change sc
        WHERE sc.type = 'END_DATE'
          AND sc.cancel_time IS NULL
    ) t
    WHERE t.rnk = 1
),
leave_quest AS (
    SELECT
        t.*,
        CAST(CAST((xpath('//question/id/text()', xml_element))[1] AS text) AS integer) AS qqid,
        CAST(
            CAST(
                (xpath('//id/text()', unnest(xpath('//question/options/option', xml_element))))[1]
                AS text
            ) AS integer
        ) AS aid,
        CAST(
            (xpath('//optionText/text()', unnest(xpath('//question/options/option', xml_element))))[1]
            AS text
        ) AS answer_text
    FROM (
        SELECT
            q.id,
            q.name,
            q.creation_time,
            q.externalid,
            unnest(xpath('//question', xmlparse(document convert_from(q.questions, 'UTF-8')))) AS xml_element
        FROM questionnaires q
        WHERE q.name = 'Reason for Leaving'
    ) t
),
leave_reason_answer AS (
    SELECT *
    FROM (
        SELECT
            qun.center,
            qun.id,
            qun.log_time,
            leave_quest.answer_text,
            ROW_NUMBER() OVER (
                PARTITION BY qun.center, qun.id
                ORDER BY qun.log_time DESC
            ) AS rnk
        FROM question_answer qa
        JOIN questionnaire_answer qun
          ON qa.answer_center = qun.center
         AND qa.answer_id     = qun.id
         AND qa.answer_subid  = qun.subid
        JOIN questionnaire_campaigns qc
          ON qc.id = qun.questionnaire_campaign_id
        JOIN leave_quest
          ON leave_quest.id = qc.questionnaire
         AND qa.question_id = leave_quest.qqid
         AND qa.number_answer = leave_quest.aid
        WHERE qun.completed
    ) t
    WHERE rnk = 1
),
result AS (
    SELECT
        p.center || 'p' || p.id AS "Member ID",
        COALESCE(p.external_id, person_ext_id.txtvalue) AS "External ID",
        s.end_date AS "Stop date of subscription",
        employee.fullname AS "Employee who added stop date",

        CASE
            WHEN GREATEST(
                     reasonforleaving.last_edit_time,
                     leave_reason_answer.log_time,
                     hobaddebt.last_edit_time
                 ) = hobaddebt.last_edit_time
             AND hobaddebt.txtvalue = 'YES'
                THEN 'HOBADDEBT'

            WHEN GREATEST(
                     reasonforleaving.last_edit_time,
                     leave_reason_answer.log_time,
                     hobaddebt.last_edit_time
                 ) = reasonforleaving.last_edit_time
                THEN reasonforleaving.txtvalue

            ELSE leave_reason_answer.answer_text
        END AS "Reason For Cancellation",
        prod.name       AS "Package Description",
        c.name          AS "Club"
        
    FROM persons p
    JOIN subscriptions s
      ON s.owner_center = p.center
     AND s.owner_id     = p.id
     AND p.status       = 1
     AND (s.end_date + INTERVAL '1 day')
         <> date_trunc('month', s.end_date) + INTERVAL '1 month'
    JOIN sc_stop
      ON s.center = sc_stop.old_subscription_center
     AND s.id     = sc_stop.old_subscription_id
    JOIN products prod
      ON prod.center = s.subscriptiontype_center 
     AND prod.id = s.subscriptiontype_id 
    JOIN employees e
      ON sc_stop.employee_id     = e.id
     AND sc_stop.employee_center = e.center
    JOIN CENTERS C
      ON P.CENTER = C.ID
    LEFT JOIN persons employee
      ON employee.id     = e.personid
     AND employee.center = e.personcenter
    LEFT JOIN person_ext_attrs person_ext_id
      ON p.id     = person_ext_id.personid
     AND p.center = person_ext_id.personcenter
     AND person_ext_id.name = '_eClub_OldSystemPersonId'
    LEFT JOIN leave_reason_answer
      ON leave_reason_answer.center = p.center
     AND leave_reason_answer.id     = p.id
    LEFT JOIN person_ext_attrs hobaddebt
      ON p.center = hobaddebt.personcenter
     AND p.id     = hobaddebt.personid
     AND hobaddebt.name     = 'HOBADDEBT'
     AND hobaddebt.txtvalue = 'YES'
    LEFT JOIN person_ext_attrs reasonforleaving
      ON p.center = reasonforleaving.personcenter
     AND p.id     = reasonforleaving.personid
     AND reasonforleaving.name = 'REASONFORLEAVING'
     AND reasonforleaving.txtvalue IS NOT NULL
     WHERE NOT EXISTS
        (
                SELECT 1
                FROM subscriptions s2
                WHERE
                     s2.owner_center = p.center
                AND s2.owner_id = p.id
                AND s2.id <> s.id                          -- another subscription
                AND (
                -- still active after the report stop date OR no end date
                s2.end_date IS NULL
                -- or a new subscription that starts in the future
                OR s2.start_date > s.end_date --+ INTERVAL '4 months'
        )     ) 
)
SELECT *
FROM result
WHERE "Reason For Cancellation" NOT IN ('Banned', 'Deseased') or "Reason For Cancellation" is null;