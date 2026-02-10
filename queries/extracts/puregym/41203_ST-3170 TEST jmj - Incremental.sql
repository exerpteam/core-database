-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    any_club_in_scope AS
    (
        SELECT id 
          FROM centers 
         WHERE id IN ($$scope$$)
           AND rownum = 1
    )
    , params AS
    (
        SELECT
            /*+ materialize  */
            datetolongC(TO_CHAR(TRUNC(SYSDATE)-5, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
            datetolongC(TO_CHAR(TRUNC(SYSDATE+1), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE,
			'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
			'Europe/London'         TZFORMAT
        FROM
            dual
        CROSS JOIN any_club_in_scope
    )
SELECT
    cp.EXTERNAL_ID   AS "EXTERNALID",
	Q.id AS "QUESTIONNAIREID",
    Q.questionid AS "QUESTIONID",
    decode(Q.NAME, 'Segmentation Questionnaire 3', ' Welcome Goals', q.name) AS "SOURCE",
    replace(replace(Q.questiontext, chr(10), ''), chr(13), '') AS "QUESTIONTEXT",
    replace(replace(Q.answertext, chr(10), ''), chr(13), '') AS "ANSWERTEXT",
TO_CHAR(longtodatetz(QUN.LOG_TIME,TZFORMAT),DATETIMEFORMAT) AS "LOGTIME"
FROM
    QUESTION_ANSWER QA
JOIN
    (
    SELECT CENTER
         , ID
         , SUBID
         , QUESTIONNAIRE_CAMPAIGN_ID
         , LOG_TIME
         , MAX(LOG_TIME) OVER (PARTITION BY CENTER, ID, QUESTIONNAIRE_CAMPAIGN_ID) MAX_LOG_TIME
    FROM QUESTIONNAIRE_ANSWER
    WHERE COMPLETED = 1 
    ) QUN
ON
    QA.ANSWER_CENTER = QUN.CENTER
    AND QA.ANSWER_ID = QUN.ID
    AND QA.ANSWER_SUBID = QUN.SUBID
    AND QUN.LOG_TIME = QUN.MAX_LOG_TIME
JOIN
    PUREGYM.QUESTIONNAIRE_CAMPAIGNS QC
ON
    QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
JOIN
    (
	SELECT q1.ID
         , q1.NAME
         , x.questionid
         , x.questiontext
         , y.answerid
         , y.answertext
    FROM   QUESTIONNAIRES q1,
           XMLTABLE('//question'
                    passing xmltype(UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(q1.QUESTIONS, 2000,1), 'UTF8') || UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(q1.QUESTIONS, 2000,2001), 'UTF8') )
                    columns questionid VARCHAR2(10) PATH 'id',
                            questiontext VARCHAR2(100) PATH 'questionText',
                            answer XMLTYPE PATH './options/option')x,
           XMLTABLE('option'
                    passing x.answer
                    columns 
                    answerid VARCHAR2(10) PATH 'id',
                    answertext VARCHAR2(30) PATH 'optionText'
                    )y
    WHERE q1.NAME in ('Segmentation Questionnaire 3', 'Marketing Questionnaire', 'Marketing Questionnaire 2')		 
	) Q
ON
    q.ID = QC.QUESTIONNAIRE
	AND QA.QUESTION_ID = Q.questionid
	AND QA.NUMBER_ANSWER = Q.answerid    
JOIN
    PUREGYM.PERSONS p
ON
    QUN.CENTER = P.CENTER
    AND QUN.ID = P.ID
    AND p.sex !='C' 
JOIN
    PUREGYM.PERSONS cp
ON
    p.CURRENT_PERSON_CENTER = cp.CENTER
    AND p.CURRENT_PERSON_ID = cp.ID
CROSS JOIN PARAMS
WHERE
    QUN.CENTER in ($$scope$$)
    AND QUN.LOG_TIME >= PARAMS.FROMDATE
    AND QUN.LOG_TIME < PARAMS.TODATE 