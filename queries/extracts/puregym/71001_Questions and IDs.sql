-- The extract is extracted from Exerp on 2026-02-08
--  
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
    WHERE q1.ID in (3801, 4201)	

