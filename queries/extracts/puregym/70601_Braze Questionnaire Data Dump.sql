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
 SELECT
     cp.EXTERNAL_ID   AS "EXTERNALID",
         Q.id AS "QUESTIONNAIREID",
     Q.questionid AS "QUESTIONID",
     case Q.NAME  when 'Segmentation Questionnaire 3' then  'Welcome Goals'  else q.name end AS "SOURCE",
     replace(replace(Q.questiontext, chr(10), ''), chr(13), '') AS "QUESTIONTEXT",
     replace(replace(Q.answertext, chr(10), ''), chr(13), '') AS "ANSWERTEXT",
 TO_CHAR(longtodatetz(QUN.LOG_TIME,'Europe/London'),'yyyy-MM-dd HH24:MI:SS') AS "LOGTIME",
 QA.NUMBER_ANSWER AS "SELECTEDOPTIONID"
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
     QUESTIONNAIRE_CAMPAIGNS QC
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
                     passing XMLType(q1.QUESTIONS,871)
                     columns questionid VARCHAR2(10) PATH 'id',
                             questiontext VARCHAR2(100) PATH 'questionText',
                             answer XMLTYPE PATH './options/option')x,
            XMLTABLE('option'
                     passing x.answer
                     columns
                     answerid VARCHAR2(10) PATH 'id',
                     answertext VARCHAR2(50) PATH 'optionText'
                     )y
     WHERE q1.NAME in ('Segmentation Questionnaire 3', 'Marketing Questionnaire', 'Marketing Questionnaire 2', 'Onboarding Questionnaire', 'Onboarding Questionnaire 2021')
         ) Q
 ON
     q.ID = QC.QUESTIONNAIRE
         AND QA.QUESTION_ID = Q.questionid
         AND QA.NUMBER_ANSWER = Q.answerid
 JOIN
     PERSONS p
 ON
     QUN.CENTER = P.CENTER
     AND QUN.ID = P.ID
     AND p.sex !='C'
 JOIN
     PERSONS cp
 ON
     p.CURRENT_PERSON_CENTER = cp.CENTER
     AND p.CURRENT_PERSON_ID = cp.ID
 WHERE
     QUN.CENTER in ($$scope$$)
     AND QUN.LOG_TIME >= $$fromDate$$
     AND QUN.LOG_TIME < $$toDate$$
