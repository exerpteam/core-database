-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id AS CENTER_ID,
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolongtz(TO_CHAR(CURRENT_DATE- $$offset$$ , 'YYYY-MM-DD HH24:MI'),
                    c.time_zone)
            END                                                                      AS FROM_DATE,
            datetolongtz(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    op.EXTERNAL_ID                                      AS "PERSON_ID",
    CAST ( QA.ID AS VARCHAR(255))             AS "ANSWER_SUBMISSIONS.ANSWER_SUBMISSION_ID",
    qun.center||'p'||qun.id||'sub'||qun.SUBID           AS "ANSWER_SUBMISSIONS.SUBMISSION_ID",
    q.id||'qu'|| qa.QUESTION_ID||'an'||qa.NUMBER_ANSWER        AS "ANSWER_SUBMISSIONS.ANSWER_ID",
    TO_CHAR(longtodateC(qun.LOG_TIME,qun.CENTER),'YYYY-MM-DD')   AS "ANSWER_SUBMISSIONS.ENTRY_DATE",
    TO_CHAR(longtodateC(qun.LOG_TIME,qun.CENTER),'hh24:mi')      AS "ANSWER_SUBMISSIONS.ENTRY_TIME",
    TO_CHAR(longToDateC(qun.LOG_TIME, p.CENTER), 'dd.MM.yyyy HH24:MI:SS') AS
                  "ANSWER_SUBMISSIONS.ENTRY_DATETIME",
    qun.center   AS "ANSWER_SUBMISSIONS.CENTER_ID",
    qun.LOG_TIME AS "ANSWER_SUBMISSIONS.ETS"
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
JOIN
    PERSONS op
ON
    p.TRANSFERS_CURRENT_PRS_CENTER = op.CENTER
AND p.TRANSFERS_CURRENT_PRS_ID = op.ID
    -- Needed to get the home center's country ID of the subscription owner to limit the scope of
    -- the data synchronization
JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
JOIN
    params
ON
    params.CENTER_ID = cen.id
WHERE
    -- Exclude companies
p.SEX != 'C'
    -- Exclude Transferred
AND p.center = p.TRANSFERS_CURRENT_PRS_CENTER
AND p.id = p.TRANSFERS_CURRENT_PRS_ID
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)
AND qun.COMPLETED = 1
AND qa.NUMBER_ANSWER IS NOT NULL 
    -- Only subscriptions updated in the last 24 hours
AND qun.LOG_TIME > params.FROM_DATE