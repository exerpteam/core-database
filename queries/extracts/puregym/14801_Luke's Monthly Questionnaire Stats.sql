-- The extract is extracted from Exerp on 2026-02-08
-- Luke's Monthly Questionnaire Stats
select 
    qc.name as questionnaire_campaign,
    q.name,
    qaa.answer_center,
    c.name,
    qaa.question_id,    
    decode(qaa.number_answer,1,'1',2,'2',3,'3',4,'4',5,'5',6,'6',7,'7',8,'8',9,'9',10,'10',11,'11',12,'12',13,'13',14,'14',15,'15',16,'16',17,'17',18,'18',19,'19',20,'20',null,'free text') as number_answer,
    count(qa.subid) as number_replies
from 
    questionnaire_campaigns qc
join
    questionnaires q
    on qc.questionnaire = q.id
join
    questionnaire_answer qa
    on qc.id = qa.questionnaire_campaign_id
join
    question_answer qaa
    on qa.center = qaa.answer_center
    and qa.id = qaa.answer_id
    and qa.subid = qaa.answer_subid
join
    centers c
    on qaa.answer_center = c.id
where
 qaa.answer_center in (:scope)
and qa.log_time >= datetolong('2015-06-01 00:00')
and qa.log_time <= datetolong('2015-07-01 00:00')
group by
    qc.name,
    q.name,
    qaa.answer_center,
    c.name,
    qaa.question_id,    
    qaa.number_answer
order by
    qc.name,
    q.name,
    qaa.answer_center,
    c.name,
    qaa.question_id,    
    qaa.number_answer