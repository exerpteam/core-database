-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
 qa.CENTER || 'p' || qa.ID AS "PersonId",
 qc.NAME as "Questionnaire",
 qa.RESULT_CODE as "Answers",
 DECODE(p.STATUS, 0,'Lead', 1,'Active', 3,'Temporary Inactive', 9, 'Contact') as "Person status"
FROM VA.QUESTIONNAIRES q
JOIN VA.QUESTIONNAIRE_CAMPAIGNS qc ON qc.QUESTIONNAIRE = q.ID
JOIN VA.QUESTIONNAIRE_ANSWER qa ON qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
JOIN VA.PERSONS p ON qa.CENTER = p.CENTER AND qa.ID = p.ID
WHERE 
 q.ID IN ($$questionnaire$$)
AND qa.CENTER = 9
AND p.BLACKLISTED IN ($$is_suspended$$)
AND p.STATUS IN ($$personStatus$$)