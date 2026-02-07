SELECT
 qa.CENTER AS ClubId, CENTERS.ShortName AS "Club",
 qa.CENTER || 'p' || qa.ID AS "PersonId",
 q.NAME as "Questionnaire",
 qa.RESULT_CODE as "AnswerCode",
DECODE( qa.RESULT_CODE,'CB', 'Club too busy', 'C', 'Competitor', 'D', 'Deceased', 'F', 'Financial', 'PF', 'Facilities not up to standard', 'LA', 'Left area', 'LU', 'Low usage', 'M', 'Medical', 'MC', 'Member change', 'VM', 'Value for money', 'CC', 'Club closure') AS "AnswerText",
to_date('19700101', 'YYYYMMDD') + ( 1 / 24 / 60 / 60 / 1000) * qa.LOG_TIME AS "AnswerDate",
DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',
4,'TRANSFERED',
5,'DUPLICATE',
6,'PROSPECT',
7,'DELETED',
9,'CONTACT')  as "Person status",
DECODE(p.BLACKLISTED,0,'No',2,'YES') AS "Is Blacklisted?"
FROM VA.QUESTIONNAIRES q
JOIN VA.QUESTIONNAIRE_CAMPAIGNS qc ON qc.QUESTIONNAIRE = q.ID
JOIN VA.QUESTIONNAIRE_ANSWER qa ON qa.QUESTIONNAIRE_CAMPAIGN_ID = qc.ID
JOIN VA.PERSONS p ON qa.CENTER = p.CENTER AND qa.ID = p.ID
JOIN CENTERS ON qa.CENTER = CENTERS.ID
WHERE 
 q.ID IN ($$questionnaire$$)
AND qa.CENTER IN (:scope)
AND p.BLACKLISTED IN ($$is_suspended$$)
AND p.STATUS IN ($$personStatus$$)
