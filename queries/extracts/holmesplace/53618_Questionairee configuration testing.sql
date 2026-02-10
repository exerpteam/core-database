-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
DISTINCT 
q.name AS "QuestionnaireName",
q.id AS "QuestionaireID",
q.headline AS "Headline",
q.externalid AS "QuestionaireExId",
q.text AS "QuestionniareText",
q.scope_id AS "ScopeID",
qc.rank AS "Rank",
qc.type AS "CampaignType",
qc.name AS "CampiaginName",
qc.id AS "CampiagnID",
qc.required AS "Required",
qc.stopdate AS "StopDate"



FROM 
     questionnaires q 
LEFT JOIN 
	questionnaire_campaigns qc
ON 
     q.id = qc.questionnaire 

JOIN
    questionnaire_answer qa
ON
    qc.id = qa.questionnaire_campaign_id

JOIN question_answer qans
ON qa.id= qans.id


where
 qc.stopdate >=(:TodaysDate)

ORDER BY 
     q.name