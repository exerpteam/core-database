select 
    qc.name as questionnaire_campaign,
    q.name,
    qaa.answer_center,
    c.name,
    qaa.question_id,    
    decode(qaa.number_answer,1,'1',2,'2',3,'3',4,'4',5,'5',6,'6',7,'7',8,'8',9,'9',10,'10',11,'11',12,'12',13,'13',14,'14',15,'15',16,'16',17,'17',18,'18',19,'19',20,'20',null,'free text') as number_answer,
    count(qa.subid) as number_replies
from 
    sats.questionnaire_campaigns qc
join
    sats.questionnaires q
    on qc.questionnaire = q.id
join
    sats.questionnaire_answer qa
    on qc.id = qa.questionnaire_campaign_id
join
    sats.question_answer qaa
    on qa.center = qaa.answer_center
    and qa.id = qaa.answer_id
    and qa.subid = qaa.answer_subid
join
    sats.centers c
    on qaa.answer_center = c.id
where
 qaa.answer_center in (:scope)
and qa.log_time >= :StartDate 
and qa.log_time <= :EndDate+1
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
