 SELECT DISTINCT
  --q.ANSWER_DATE,
  --PR.Name,
  --S.End_date,
  qa.CENTER || 'p' || qa.ID AS "PersonId",
  --qc.NAME as "Questionnaire",
  --qc.id,
  --to_char(to_timestamp(qa.log_time) AT TIME ZONE 'Europe/London', 'YYYY-MM-DD HH24:MI:SS'),
  to_timestamp(qa.log_time / 1000) AT TIME ZONE 'Europe/London',
  qa.RESULT_CODE as "Answers",
   CASE qa.result_code 
	WHEN 'CGEX' THEN 'Change to group exercise ' 
	WHEN 'CHS' THEN 'Cleanliness/Hygiene is not up to standard '
	WHEN 'CTB' THEN 'Club too busy '
	WHEN 'C' THEN 'Competitor'
	WHEN 'CS' THEN 'Customer Service is not up to standard'
	WHEN 'FS' THEN 'Facilities arent up to standard'
	WHEN 'F' THEN 'Financial'
	WHEN 'HR' THEN 'Health Related'
	WHEN 'WFH' THEN 'I am working from home/not at my office'
	WHEN 'WTE' THEN 'Learnt/want to exercise in a different way '
	WHEN 'LLA' THEN 'Location/Left Area'
	WHEN 'NUG' THEN 'Not currently using the gym'
	WHEN 'NUM' THEN 'Not going to use membership enough'
	WHEN 'O' THEN 'Other'
	WHEN 'VFM' THEN 'Value for money'
	END AS "Answer",
	
  CASE p.STATUS  WHEN 0 THEN 'Lead'  WHEN 1 THEN 'Active' WHEN 2 THEN 'Inactive'  WHEN 3 THEN 'Temporary Inactive'  WHEN 9 THEN  'Contact' END as "Person status"
 FROM QUESTIONNAIRES q
 JOIN QUESTIONNAIRE_CAMPAIGNS qc ON qc.QUESTIONNAIRE = q.ID
 JOIN QUESTIONNAIRE_ANSWER qa ON qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
 JOIN PERSONS p ON qa.CENTER = p.CENTER AND qa.ID = p.ID
 JOIN subscriptions s ON S.OWNER_CENTER = P.CENTER AND S.OWNER_ID = P.ID
 JOIN PRODUCTS pr ON pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND pr.id = s.SUBSCRIPTIONTYPE_ID
 WHERE
	qa.CENTER IN (:scope)
AND 
	qc.ID = '7801'
AND 
	to_timestamp(qa.log_time / 1000) AT TIME ZONE 'Europe/London' >= '2025-05-01'::timestamp
AND
	P.status = '2'
