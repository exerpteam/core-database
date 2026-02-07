SELECT
    "ID"||'qu'||"QQID"||'an'||"AID"                     AS "QUESTIONNAIRES.ANSWER_ID",
    "ANSWER_TEXT"                                       AS "QUESTIONNAIRES.ANSWER_TEXT",
    "ID"||'qu'||"QQID"                                  AS "QUESTIONNAIRES.QUESTION_ID",
    "QUESTION_TEXT"                                     AS "QUESTIONNAIRES.QUESTION_TEXT",
    UPPER(CAST ( "QUESTION_TYPE" AS VARCHAR(255)))      AS "QUESTIONNAIRES.QUESTION_TYPE",
    CAST ( "ID" AS VARCHAR(255))                        AS "QUESTIONNAIRES.QUESTIONNAIRE_ID",
    "QUESTIONNAIRE_NAME"                                AS "QUESTIONNAIRES.QUESTIONNAIRE_NAME",
    "CREATION_DATE"                                     AS "QUESTIONNAIRES.CREATION_DATE"
FROM
    (
        SELECT
            "ID",
            "QUESTIONNAIRE_NAME",
            "CREATION_DATE",
            (xpath('//question/id/text()',xml_element))[1]                                           AS "QQID",
            (xpath('//question/questionType/text()',xml_element))[1]                                 AS "QUESTION_TYPE",
            (xpath('//question/questionText/text()',xml_element))[1]                                 AS "QUESTION_TEXT",
            (xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))[1]         AS "AID",
            (xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element))))[1] AS "ANSWER_TEXT"
        FROM
            (
                SELECT
                    Q.id                                                                              AS "ID",
                    Q.name                                                                            AS "QUESTIONNAIRE_NAME",
                    TO_CHAR(q.CREATION_TIME, 'YYYY-MM-DD')                                            AS "CREATION_DATE",
                    unnest(xpath('//question',xmlparse(document convert_from(q.QUESTIONS, 'UTF-8')))) AS xml_element
                FROM
                    QUESTIONNAIRES q) t) tmp