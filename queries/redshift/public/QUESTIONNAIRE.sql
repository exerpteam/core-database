SELECT
    tmp."ID",
    "NAME",
    "CREATION_DATE",
    tmp."ID"||'qu'||"QQID"                         AS "QUESTION_ID",
    UPPER(CAST ( "QUESTION_TYPE" AS VARCHAR(255))) AS "QUESTION_TYPE",
    CAST ( "QUESTION_TEXT" AS VARCHAR(255))           "QUESTION_TEXT",
    CASE
        WHEN "AID" IS NULL
        THEN NULL
        ELSE tmp."ID"||'qu'||"QQID"||'an'||"AID"
    END AS                                "ANSWER_ID",
    CAST ( "ANSWER_TEXT" AS VARCHAR(255)) "ANSWER_TEXT",
    "EXTERNAL_ID",
     tmp2."STATUS" AS "QUESTIONNAIRE_STATUS",
     CASE WHEN UPPER(CAST("REQUIRED" AS VARCHAR)) = 'TRUE' THEN true
     ELSE false
    END AS "REQUIRED"
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
            ] AS "ANSWER_TEXT",
			(xpath('//question/required/text()',xml_element))[1]                      AS "REQUIRED"
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
            NULL                                                     AS "AID",
            NULL                                                     AS "ANSWER_TEXT",
			(xpath('//question/required/text()',xml_element))[1]     AS "REQUIRED"
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
JOIN
    (
        SELECT
            t1.qid AS "ID",
            CASE
                WHEN SUM(Q_Status) > 0
                THEN 'ACTIVE'
                WHEN SUM(Q_Status) = 0
                THEN 'INACTIVE'
                ELSE 'NEW'
            END AS "STATUS"
        FROM
            (
                SELECT
                    q.id AS qid,
                    q.name,
                    CASE
                        WHEN qc.stopdate >= CURRENT_DATE
                        AND qc.startdate <= CURRENT_DATE
                        THEN 1
                        WHEN qc.startdate IS NULL
                        THEN NULL
                        ELSE 0
                    END AS Q_Status
                FROM
                    QUESTIONNAIRES Q
                LEFT JOIN
                    QUESTIONNAIRE_CAMPAIGNS QC
                ON
                    q.ID = QC.QUESTIONNAIRE ) t1
        GROUP BY
            t1.qid,
            t1.name ) tmp2
ON
    tmp2."ID" = tmp."ID"