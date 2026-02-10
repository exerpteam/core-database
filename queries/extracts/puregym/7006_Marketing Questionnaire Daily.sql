-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    op.EXTERNAL_ID   AS "External ID",
    qa.QUESTION_ID   AS "Question ID",
    qa.NUMBER_ANSWER AS "Question Answer"
FROM
    QUESTION_ANSWER QA
JOIN
    QUESTIONNAIRE_ANSWER QUN
ON
    QA.ANSWER_CENTER = QUN.CENTER
    AND QA.ANSWER_ID = QUN.ID
    AND QA.ANSWER_SUBID = QUN.SUBID
JOIN
    PUREGYM.QUESTIONNAIRE_CAMPAIGNS QC
ON
    QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
JOIN
    PUREGYM.QUESTIONNAIRES Q
ON
    q.ID = QC.QUESTIONNAIRE
JOIN
    PUREGYM.PERSONS p
ON
    QUN.CENTER = P.CENTER
    AND QUN.ID = P.ID
JOIN
    PUREGYM.PERSONS op
ON
    p.CURRENT_PERSON_CENTER = op.CENTER
    AND p.CURRENT_PERSON_ID = op.ID
JOIN
    (
        SELECT
            op.EXTERNAL_ID,
            MAX(qun.LOG_TIME) LOG_TIME
        FROM
            QUESTION_ANSWER QA
        JOIN
            QUESTIONNAIRE_ANSWER QUN
        ON
            QA.ANSWER_CENTER = QUN.CENTER
            AND QA.ANSWER_ID = QUN.ID
            AND QA.ANSWER_SUBID = QUN.SUBID
        JOIN
            PUREGYM.QUESTIONNAIRE_CAMPAIGNS QC
        ON
            QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
        JOIN
            PUREGYM.QUESTIONNAIRES Q
        ON
            q.ID = QC.QUESTIONNAIRE
        JOIN
            PUREGYM.PERSONS p
        ON
            QUN.CENTER = P.CENTER
            AND QUN.ID = P.ID
        JOIN
            PUREGYM.PERSONS op
        ON
            p.CURRENT_PERSON_CENTER = op.CENTER
            AND p.CURRENT_PERSON_ID = op.ID
        WHERE
            Q.NAME = 'Marketing Questionnaire'
            AND p.sex !='C'
            AND qun.COMPLETED = 1
            AND qun.LOG_TIME > dateToLong(TO_CHAR(SYSDATE - 30, 'YYYY-MM-dd HH24:MI'))
        GROUP BY
            op.EXTERNAL_ID ) max_q
ON
    max_q.LOG_TIME = qun.LOG_TIME
    AND op.EXTERNAL_ID = max_q.EXTERNAL_ID
WHERE
    Q.NAME = 'Marketing Questionnaire'
    AND p.sex !='C'
    AND qun.COMPLETED = 1
    AND qun.LOG_TIME > dateToLong(TO_CHAR(SYSDATE - 30, 'YYYY-MM-dd HH24:MI'))