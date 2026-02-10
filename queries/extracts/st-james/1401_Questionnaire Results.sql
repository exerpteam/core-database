-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-10222
WITH cancellation_quest AS materialized
(
        SELECT
            "ID",
            "NAME",
            "CREATION_DATE",
            "EXTERNAL_ID",
            (xpath('//question/id/text()',xml_element))[1]::TEXT                      AS "QQID",
            (xpath('//question/questionType/text()',xml_element))[1]             AS "QUESTION_TYPE",
            (xpath('//question/questionText/text()',xml_element))[1]             AS "QUESTION_TEXT",
            (xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))[1]::TEXT AS "AID",
            (xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element))))[1] AS "ANSWER_TEXT"
        FROM
            (
                SELECT
                    Q.id            AS "ID",
                    Q.name          AS "NAME",
                    q.CREATION_TIME AS "CREATION_DATE",
                    q.externalid    AS "EXTERNAL_ID" ,
                    unnest(xpath('//question',xmlparse(document convert_from(q.QUESTIONS, 'UTF-8'))
                    )) AS xml_element
                FROM
                    QUESTIONNAIRES q
                 ) t
        UNION ALL
        SELECT
            "ID",
            "NAME",
            "CREATION_DATE",
            "EXTERNAL_ID",
            (xpath('//question/id/text()',xml_element))[1]::TEXT           AS "QQID",
            (xpath('//question/questionType/text()',xml_element))[1] AS "QUESTION_TYPE",
            (xpath('//question/questionText/text()',xml_element))[1] AS "QUESTION_TEXT",
            NULL                                                     AS "AID",
            NULL                                                     AS "ANSWER_TEXT"
            FROM
            (
                SELECT
                    Q.id            AS "ID",
                    Q.name          AS "NAME",
                    q.CREATION_TIME AS "CREATION_DATE",
                    q.externalid    AS "EXTERNAL_ID" ,
                    unnest(xpath('//question',xmlparse(document convert_from(q.QUESTIONS, 'UTF-8'))
                    )) AS xml_element
                FROM
                    QUESTIONNAIRES q
                ) t
        WHERE
            btrim(CAST(xpath('//ques/options/option',xml_element) AS VARCHAR),'{}') = '' 
)
,
params AS
 (   SELECT
            CAST(datetolongTZ(TO_CHAR(to_date($$fromdate$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS BIGINT) AS fromDate,
            CAST(datetolongTZ(TO_CHAR(to_date($$todate$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS BIGINT) AS toDate,
            c.id                    AS centerid
        FROM
            centers c
        WHERE 
            ID in ($$Scope$$)    
)
SELECT
    p.center||'p'||p.id AS "MemberID",
    p.center AS "ClubID",
    q.name "Questionaire Name",
    cq."QUESTION_TEXT" AS "Question", 
    cq."ANSWER_TEXT" AS "Answer",
    CASE WHEN qun.COMPLETED THEN 'Completed'
      ELSE 'Incomplete' 
    END AS "Completion Status",
    longtodateC(qun.LOG_TIME, p.center)  AS "Date and Time" ,
    s.center||'ss'||s.id AS "Cancelled MembershipID",
    s.end_date  AS "Subscription End Date",
    pr.name AS "Cancelled Membership",
    emp.fullname AS "Submitted by Employee"
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
    params
ON
    Params.centerid = p.center        
LEFT JOIN
    cancellation_quest cq
ON      
    cq."QQID" = qa.question_id::TEXT
    AND cq."AID" = qa.number_answer::TEXT
LEFT JOIN 
    journalentries je
ON 
    je.person_center = p.center 
    AND je.person_id = p.id 
    AND je.jetype = 18      
    AND je.creation_time BETWEEN qun.LOG_TIME - 30000 AND  qun.LOG_TIME + 30000 
LEFT JOIN
    subscriptions s
ON
    s.center = je.ref_center
    AND s.id = je.ref_id
LEFT JOIN 
    products pr
ON
    s.subscriptiontype_center = pr.center
    AND s.subscriptiontype_id = pr.id    
LEFT JOIN
    employees e
ON
    je.creatorcenter = e.center    
    AND je.creatorid = e.id
LEFT JOIN
    persons emp
ON
    e.personcenter = emp.center
    AND e.personid = emp.id                
WHERE
    p.sex != 'C'
    AND cq."ID" = 2
    AND qun.LOG_TIME >= params.fromdate
    AND qun.LOG_TIME < params.todate    
