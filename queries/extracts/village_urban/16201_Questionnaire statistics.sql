select 
    qc.name as questionnaire_campaign,
    qa.QUESTIONNAIRE_CAMPAIGN_ID,
    --q.name,
    --qaa.answer_center,
   -- c.name,
    qaa.question_id,    
    qaa.number_answer as number_answer,
   -- qaa.TEXT_ANSWER,
    qa.center ||'p'|| qa.id as personid,
pea.txtvalue as email 
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
left join 
PERSON_EXT_ATTRS PEA
 ON PEA.PERSONCENTER = qa.center
AND PEA.PERSONID = qa.id 
AND PEA.NAME = '_eClub_Email' 

where
 qaa.answer_center in (:scope)
and qa.log_time >= :StartDate 
and qa.log_time <= :EndDate+1
and qa.QUESTIONNAIRE_CAMPAIGN_ID = 602
and qaa.question_id = 5
and qaa.number_answer = 1


order by
    personid, 
    qc.name,
    q.name,
    qaa.answer_center,
    c.name,
    qaa.question_id,    
    qaa.number_answer,
qa.QUESTIONNAIRE_CAMPAIGN_ID
