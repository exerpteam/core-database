-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
Q.name, x.questionid,x.questiontext,y.answerid,y.answertext
      from   PUREGYM.QUESTIONNAIRES Q,
           XMLTABLE('//question'
                    passing xmltype(UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(q.QUESTIONS, 4000,1)))
                    columns questionid VARCHAR2(10) PATH 'id',
                            questiontext VARCHAR2(100) PATH 'questionText',
                            answer XMLTYPE PATH './options/option')x,
           XMLTABLE('option'
                    passing x.answer
                    columns 
                    answerid VARCHAR2(10) PATH 'id',
                    answertext VARCHAR2(30) PATH 'optionText'
                    )y

WHERE
    Q.NAME IN ('Segmentation Questionnaire 1')