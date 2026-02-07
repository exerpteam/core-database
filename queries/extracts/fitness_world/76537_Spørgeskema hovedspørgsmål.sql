-- This is the version from 2026-02-05
--  
select utl_raw.cast_to_varchar2(dbms_lob.substr(QUESTIONS, 2000, 1)) from QUESTIONNAIRES q
JOIN QUESTIONNAIRE_CAMPAIGNS qc ON
qc.QUESTIONNAIRE = q.ID
WHERE qc.ID = '1002'