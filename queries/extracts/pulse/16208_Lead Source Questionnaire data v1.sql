WITH 
     params AS materialized 
     (
      SELECT 
             c.id AS centerid,
             c.name AS center_name,
             datetolongTZ(TO_CHAR(cast(:fromDate as date), 'YYYY-MM-DD HH24:MI'),c.time_zone) AS FromDate,
             datetolongTZ(TO_CHAR(cast(:toDate as date), 'YYYY-MM-DD HH24:MI'),c.time_zone) + 86400000 AS ToDate
        FROM
             centers c
       where c.id in (:scope)
     )
select 
p.center||'p'||p.id as member_key, 

q.name as QuestionnaireName,
qc.name as CampaignName,
qc.startdate as StartDate,
qc.stopdate as StopDate, 

longtodatetz(qa.log_time, c.time_zone) as answer_log_time,
qa.completed, 
qa.status,

-----q.questions,
qaa.question_id,
qaa.text_answer,
qaa.number_answer


/* ---out of scope:
as TotalCompleted,
as TotalAsked
*/

from questionnaire_campaigns qc
join questionnaires q on qc.questionnaire = q.id
join questionnaire_answer qa on qc.id = qa.questionnaire_campaign_id
join question_answer qaa on qa.center = qaa.answer_center and qa.id = qaa.answer_id and qa.subid = qaa.answer_subid
join centers c on qaa.answer_center = c.id
join params on centerid = c.id  
join PERSONS p on qa.CENTER = p.CENTER and qa.ID = p.ID

where
qa.log_time >= params.FromDate
AND qa.log_time <= params.ToDate
AND q.name ilike :campaign