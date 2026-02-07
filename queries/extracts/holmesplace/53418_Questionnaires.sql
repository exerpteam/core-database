SELECT DISTINCT
	
p.CENTER || 'p' || p.ID AS PersonId,
QA.center AS "ClubId",
    QC.id AS "CampaignID",
	QC.name AS "CampaignName",
	QC.startdate AS "CampaignStart",
	QC.stopdate AS "CampaignStop",
	TO_CHAR(longtodate(QA.log_time), 'YYYY-MM-dd HH24:MI')AS "AnwerTime",
	QA.result_code AS "AnswerResultCode",
	QA.ID AS "QuestionnairAnswerID",
	qans.question_id AS "QuestionID",
	qans.answer_id AS "QuestionAnswerID",
	qans.number_answer AS "NumberAnswer",
	qans.text_answer AS "TextAnswer",
	QA.status AS "Status"
    
FROM
   questionnaire_campaigns QC
JOIN
    questionnaire_answer QA
ON
    QC.id = QA.questionnaire_campaign_id

JOIN PERSONS P
ON P.CENTER=QA.center
AND P.ID = QA.id

JOIN question_answer qans
ON QA.id= qans.id
---AND QA.subid=qans.ANSWER_SUBID---

WHERE 
QC.name=:CampiagnName
AND
QC.stopdate> :TodaysDate
