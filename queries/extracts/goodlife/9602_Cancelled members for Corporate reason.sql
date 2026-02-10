-- The extract is extracted from Exerp on 2026-02-08
--  


select  distinct
qa.answer_center || 'p' || qa.answer_id As PersonID,
p.firstname || ' ' || p.lastname As PersonName, 
longtodate(qas.log_time) as datelogtime,
je.name As NoteName,
ENCODE(je.big_text, 'escape')  As NoteDetail --ENCODE function coverts a bytea datatype to text in Postgresql

from Questionnaire_answer qas
	join question_answer qa
		on qas.center = qa.answer_center
			and qas.id = qa.answer_id
			and qas.subid = qa.answer_subid
	
	join Persons p
		on p.center = qa.answer_center
		and p.id = qa.answer_id

	left join journalentries je
			on je.person_center = qa.answer_center
			and je.person_id = qa.answer_id
   	
where qa.number_answer=7
	and qas.questionnaire_campaign_id=1201
	and je.jetype=3
   
and TO_CHAR(longtodateC(je.creation_time, 100), 'YYYY-MM-dd') = TO_CHAR(longtodateC(qas.log_time, 100), 'YYYY-MM-dd')

--order by qa.answer_center, qa.answer_id

