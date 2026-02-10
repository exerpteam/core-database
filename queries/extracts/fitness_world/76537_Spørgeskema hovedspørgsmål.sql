-- The extract is extracted from Exerp on 2026-02-08
--  
select utl_raw.cast_to_varchar2(dbms_lob.substr(QUESTIONS, 2000, 1)) from QUESTIONNAIRES q
JOIN QUESTIONNAIRE_CAMPAIGNS qc ON
qc.QUESTIONNAIRE = q.ID
WHERE qc.ID = '1002'