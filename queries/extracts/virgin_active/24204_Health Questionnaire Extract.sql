 SELECT
  qa.CENTER || 'p' || qa.ID AS "PersonId",
  qc.NAME as "Questionnaire",
  qa.RESULT_CODE as "Answers",
  CASE p.STATUS  WHEN 0 THEN 'Lead'  WHEN 1 THEN 'Active'  WHEN 3 THEN 'Temporary Inactive'  WHEN 9 THEN  'Contact' END as "Person status"
 FROM QUESTIONNAIRES q
 JOIN QUESTIONNAIRE_CAMPAIGNS qc ON qc.QUESTIONNAIRE = q.ID
 JOIN QUESTIONNAIRE_ANSWER qa ON qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
 JOIN PERSONS p ON qa.CENTER = p.CENTER AND qa.ID = p.ID
 WHERE
  q.ID IN ($$questionnaire$$)
 AND qa.CENTER IN (:scope)
 AND p.BLACKLISTED IN ($$is_suspended$$)
 AND p.STATUS IN ($$personStatus$$)
