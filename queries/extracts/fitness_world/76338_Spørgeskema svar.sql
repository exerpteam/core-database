-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
qa.CENTER ||'p'|| qa.ID AS MemberID,
curr_p1.EXTERNAL_ID,
TO_CHAR(longtodate(qa.LOG_TIME), 'dd-MM-YYYY HH24:MI:SS') ANSWER_TIME,
SUBSTR(qa.RESULT_CODE,-4),
--null as ANSWER_TEXT
biq."ANSWER_TEXT"
FROM
QUESTIONNAIRE_ANSWER qa
JOIN QUESTIONNAIRE_CAMPAIGNS qc
ON qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
JOIN QUESTION_ANSWER qan
ON qa.CENTER = qan.ANSWER_CENTER
AND qa.ID = qan.ANSWER_ID
AND qa.SUBID = qan.ANSWER_SUBID
JOIN  (  SELECT tmp."ID",
    tmp."NAME",
    tmp."CREATION_DATE",
    ((tmp."ID" || 'qu'::text) || tmp."QQID") AS "QUESTION_ID",
    upper(((tmp."QUESTION_TYPE")::character varying(255))::text) AS "QUESTION_TYPE",
    (tmp."QUESTION_TEXT")::character varying(255) AS "QUESTION_TEXT",
        CASE
            WHEN (tmp."AID" IS NULL) THEN NULL::text
            ELSE ((((tmp."ID" || 'qu'::text) || tmp."QQID") || 'an'::text) || tmp."AID")
        END AS "ANSWER_ID",
    (tmp."ANSWER_TEXT")::character varying(255) AS "ANSWER_TEXT",
    tmp."EXTERNAL_ID",
    tmp2."STATUS" AS "QUESTIONNAIRE_STATUS",
        CASE
            WHEN (upper(((tmp."REQUIRED")::character varying)::text) = 'TRUE'::text) THEN true
            ELSE false
        END AS "REQUIRED"
   FROM (( SELECT t."ID",
            t."NAME",
            t."CREATION_DATE",
            t."EXTERNAL_ID",
            (xpath('//question/id/text()'::text, t.xml_element))[1] AS "QQID",
            (xpath('//question/questionType/text()'::text, t.xml_element))[1] AS "QUESTION_TYPE",
            (xpath('//question/questionText/text()'::text, t.xml_element))[1] AS "QUESTION_TEXT",
            (xpath('//id/text()'::text, unnest(xpath('//question/options/option'::text, t.xml_element))))[1] AS "AID",
            (xpath('//optionText/text()'::text, unnest(xpath('//question/options/option'::text, t.xml_element))))[1] AS "ANSWER_TEXT",
            (xpath('//question/required/text()'::text, t.xml_element))[1] AS "REQUIRED"
           FROM ( SELECT q.id AS "ID",
                    q.name AS "NAME",
                    q.creation_time AS "CREATION_DATE",
                    q.externalid AS "EXTERNAL_ID",
                    unnest(xpath('//question'::text, XMLPARSE(DOCUMENT convert_from(q.questions, 'UTF-8'::name) STRIP WHITESPACE))) AS xml_element
                   FROM questionnaires q) t
        UNION ALL
         SELECT t."ID",
            t."NAME",
            t."CREATION_DATE",
            t."EXTERNAL_ID",
            (xpath('//question/id/text()'::text, t.xml_element))[1] AS "QQID",
            (xpath('//question/questionType/text()'::text, t.xml_element))[1] AS "QUESTION_TYPE",
            (xpath('//question/questionText/text()'::text, t.xml_element))[1] AS "QUESTION_TEXT",
            NULL::xml AS "AID",
            NULL::xml AS "ANSWER_TEXT",
            (xpath('//question/required/text()'::text, t.xml_element))[1] AS "REQUIRED"
           FROM ( SELECT q.id AS "ID",
                    q.name AS "NAME",
                    q.creation_time AS "CREATION_DATE",
                    q.externalid AS "EXTERNAL_ID",
                    unnest(xpath('//question'::text, XMLPARSE(DOCUMENT convert_from(q.questions, 'UTF-8'::name) STRIP WHITESPACE))) AS xml_element
                   FROM questionnaires q) t
          WHERE (btrim(((xpath('//question/options/option'::text, t.xml_element))::character varying)::text, '{}'::text) = ''::text)) tmp
     JOIN ( SELECT t1.qid AS "ID",
                CASE
                    WHEN (sum(t1.q_status) > 0) THEN 'ACTIVE'::text
                    WHEN (sum(t1.q_status) = 0) THEN 'INACTIVE'::text
                    ELSE 'NEW'::text
                END AS "STATUS"
           FROM ( SELECT q.id AS qid,
                    q.name,
                        CASE
                            WHEN ((qc.stopdate >= CURRENT_DATE) AND (qc.startdate <= CURRENT_DATE)) THEN 1
                            WHEN (qc.startdate IS NULL) THEN NULL::integer
                            ELSE 0
                        END AS q_status
                   FROM (questionnaires q
                     LEFT JOIN questionnaire_campaigns qc ON ((q.id = qc.questionnaire)))) t1
          GROUP BY t1.qid, t1.name) tmp2 ON ((tmp2."ID" = tmp."ID"))) )  biq
ON (qc.QUESTIONNAIRE||'qu'||qan.QUESTION_ID||'an'||qan.NUMBER_ANSWER) = biq."ANSWER_ID"
JOIN PERSONS p1
ON qa.CENTER = p1.CENTER AND qa.ID = p1.ID
JOIN PERSONS curr_p1
ON p1.CURRENT_PERSON_CENTER = curr_p1.CENTER AND p1.CURRENT_PERSON_ID = curr_p1.ID 
WHERE qc.ID in (1002, 1202, 1402, 1602, 1802, 2002)
AND longtodate(qa.LOG_TIME) >= :FROM_DATE
AND longtodate(qa.LOG_TIME) <= :TO_DATE
ORDER BY
ANSWER_TIME