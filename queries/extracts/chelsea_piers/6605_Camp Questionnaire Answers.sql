SELECT
    QA.ID                                     AS "ID",
    QA.question_id 							AS "Question_ID",
    qun.center||'p'||qun.id||'qa'||qun.SUBID AS "SUBMISSION_ID",
    qun.LOG_TIME                              AS "ENTRY_DATETIME",
    QA.text_answer,
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END                                                 AS "PERSON_ID",
    q.id||'qu'|| qa.QUESTION_ID||'an'||qa.NUMBER_ANSWER AS "ANSWER_ID",
    qun.center                                          AS "CENTER_ID",
    qun.EXPIRATION_DATE                                 AS "EXPIRATION_DATE",
    qun.LOG_TIME                                        AS "ETS"
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
    QUESTIONNAIRES Q
ON
    q.ID = QC.QUESTIONNAIRE
JOIN
    PERSONS p
ON
    QUN.CENTER = P.CENTER
    AND QUN.ID = P.ID
WHERE
    p.sex != 'C' 
	AND qun.COMPLETED = 1
    -- AND qa.NUMBER_ANSWER IS NOT NULL
    AND Q.id in (601, 801)