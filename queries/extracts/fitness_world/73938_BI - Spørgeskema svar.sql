-- This is the version from 2026-02-05
--  
SELECT DISTINCT
qa.CENTER ||'p'|| qa.ID AS "MEMBERID",
curr_p1.EXTERNAL_ID  AS "EXTERNAL_ID",
TO_CHAR(longtodate(qa.LOG_TIME), 'dd-MM-YYYY HH24:MI:SS') AS "ANSWER_TIME",
RIGHT(qa.RESULT_CODE,4) AS "RESULT_CODE",
null as "ANSWER_TEXT"
--biq.ANSWER_TEXT
FROM
QUESTIONNAIRE_ANSWER qa
JOIN QUESTIONNAIRE_CAMPAIGNS qc
ON qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
JOIN QUESTION_ANSWER qan
ON qa.CENTER = qan.ANSWER_CENTER
AND qa.ID = qan.ANSWER_ID
AND qa.SUBID = qan.ANSWER_SUBID
JOIN
(
SELECT
    "ID",
    "NAME",
    "CREATION_DATE",
    "ID"||'qu'||"QQID"                             AS "QUESTION_ID",
    UPPER(CAST ( "QUESTION_TYPE" AS VARCHAR(255))) AS "QUESTION_TYPE",
    CAST ( "QUESTION_TEXT" AS VARCHAR(255))           "QUESTION_TEXT",
    CASE WHEN "AID" is null THEN null
         ELSE "ID"||'qu'||"QQID"||'an'||"AID"   
    END     AS                "ANSWER_ID",
    CAST ( "ANSWER_TEXT" AS VARCHAR(255))             "ANSWER_TEXT",
    "EXTERNAL_ID"
FROM
    (
        SELECT
            "ID",
            "NAME",
            "CREATION_DATE",
            "EXTERNAL_ID",
            (xpath('//question/id/text()',xml_element))[1]                      AS "QQID",
            (xpath('//question/questionType/text()',xml_element))[1]             AS "QUESTION_TYPE",
            (xpath('//question/questionText/text()',xml_element))[1]             AS "QUESTION_TEXT",
            (xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))[1] AS
            "AID",
            (xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element))))[1
            ] AS "ANSWER_TEXT"
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
                    QUESTIONNAIRES q) t
        UNION ALL
        SELECT
            "ID",
            "NAME",
            "CREATION_DATE",
            "EXTERNAL_ID",
            (xpath('//question/id/text()',xml_element))[1]           AS "QQID",
            (xpath('//question/questionType/text()',xml_element))[1] AS "QUESTION_TYPE",
            (xpath('//question/questionText/text()',xml_element))[1] AS "QUESTION_TEXT",
            null                                                       AS "AID",
            null                                                       AS "ANSWER_TEXT"
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
                    QUESTIONNAIRES q) t
        WHERE
            btrim(CAST(xpath('//question/options/option',xml_element) AS VARCHAR),'{}') = '' ) tmp
) AS biq
ON (qc.QUESTIONNAIRE||'qu'||qan.QUESTION_ID||'an'||qan.NUMBER_ANSWER) = biq."ANSWER_ID"
JOIN PERSONS p1
ON qa.CENTER = p1.CENTER AND qa.ID = p1.ID
JOIN PERSONS curr_p1
ON p1.CURRENT_PERSON_CENTER = curr_p1.CENTER AND p1.CURRENT_PERSON_ID = curr_p1.ID 
WHERE qc.ID in (1002, 1202, 1402, 1602, 1802, 2002)
AND longtodate(qa.LOG_TIME) >= current_date - 30
AND longtodate(qa.LOG_TIME) < current_date -1
ORDER BY
"ANSWER_TIME"