SELECT
    c.name,
    qa.center,
    qa.questionnaire_campaign_id,
    qc.name,
    count(distinct(
         (case when 
               qaa.ANSWER_CENTER is not null 
          then qaa.ANSWER_CENTER || '-' || qaa.ANSWER_ID || '-' ||qaa.ANSWER_SUBID 
          else null end))) as min_one_reply,
    count(distinct(qa.center || '-' || qa.id || '-' || qa.subid)) as TOTAL_SENT
FROM
    questionnaire_campaigns qc
join
    questionnaires q
    on qc.questionnaire = q.id
join
    questionnaire_answer qa
    on qc.id = qa.questionnaire_campaign_id
join
    centers c
    on qa.center = c.id
left join
    question_answer qaa
    on qa.center = qaa.answer_center
    and qa.id = qaa.answer_id
    and qa.subid = qaa.answer_subid
    and (qaa.TEXT_ANSWER is not null or qaa.NUMBER_ANSWER is not null)
WHERE
    qa.center in (:scope)
    and qa.log_time >= :StartDate 
    and qa.log_time <= :EndDate+1
group by
    c.name,
    qa.center,
    qc.name,
    qa.questionnaire_campaign_id