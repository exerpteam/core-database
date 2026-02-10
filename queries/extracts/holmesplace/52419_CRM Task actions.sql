-- The extract is extracted from Exerp on 2026-02-08
-- in progess. duplicate entries when step and status are changed by an action... hard to choose which one to keep - probably step is better. 

SELECT DISTINCT
c.shortname AS "Club",
emp.fullname AS "AssignedTO",
t.title AS "Title",
t.status AS "Status",
TO_CHAR(longtodateC(t.CREATION_TIME,T.center), 'dd-mm-yyyy') AS "CreationDate",
p.fullname AS "PersonName",
t.center || 'p' || p.id AS "PersonId",
t.follow_up AS "FollowupDate",
--t.creator_center || 'p' || t.creator_id AS "CreatedById",--
cr.fullname AS "CreatedBy",
TO_CHAR(longtodateC(t.last_update_time,T.center), 'dd-mm-yyyy') AS "LastUpdate",
ta.name AS "TaskActionName",
--ta.status AS "ActionStatus",--
--ta.id AS "TaskActionId",--
tl.employee_center || 'p' ||tl.employee_id AS "ActionById",
actemp.fullname AS "ActionBy",
--tl.task_status AS "TaskLogStatus",--
--tl.employee_center AS "EmpCeter",--
tld.type AS "TaskLogDetType",
--tld.name AS "TaskLogDet",--
tld.value AS "TaskLogValue",
 
TO_CHAR(longtodateC(tl.entry_time,T.center), 'dd-mm-yyyy') AS "entrytime",


CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARY INACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    								END AS "PersonStatus"



FROM
                    task_actions ta
                JOIN
                    task_log tl
                ON
                    ta.ID = tl.task_action_id

				lEFT JOIN
   				 	task_log_details tld
				ON
   					 tl.id = tld.task_log_id
				LEFT JOIN
					tasks t
				ON
					t.id = tl.task_id

                JOIN
                    persons p
                ON
                    p.center = t.PERSON_CENTER
                AND p.id = t.person_id
                LEFT JOIN
                    persons emp
                ON
                    emp.center = t.ASIGNEE_CENTER
                AND emp.id = t.ASIGNEE_ID
				
				LEFT JOIN
					Centers c
				ON
					c.id=t.center

				LEFT JOIN persons cr
				ON
				cr.id=t.creator_id
				AND cr.center = t.creator_center

				LEFT JOIN persons actemp
				ON
				actemp.center = tl.employee_center
				AND actemp.id = tl.employee_id


                WHERE
                    
                t.center IN (:scope)
				AND TYPE_ID = 400
				AND p.STATUS NOT IN (5,7,8) --Dup Deleted Anon--
                --AND t.STATUS IN ('CLOSED')--
				
