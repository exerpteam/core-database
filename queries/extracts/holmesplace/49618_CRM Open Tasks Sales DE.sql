-- The extract is extracted from Exerp on 2026-02-08
-- All tasks not closed or deleted. Excludes tasks for people who are Duplicate, Deleted or Anonymised.
SELECT
c.shortname AS "Club",
emp.fullname AS "AssignedTO",
t.title AS "Title",
t.status AS "Status",
tg.NAME AS "Category",
ts.NAME AS "Step",
TO_CHAR(longtodateC(t.CREATION_TIME,T.center), 'dd-mm-yyyy') AS "CreationDate",
p.fullname AS "Name",
t.center || 'p' || p.id AS "PersonId",
t.follow_up AS "FollowupDate",
t.creator_center || 'p' || t.creator_id AS "CreatedById",
cr.fullname AS "CreatedBy",
TO_CHAR(longtodateC(t.last_update_time,T.center), 'dd-mm-yyyy') AS "LastUpdate",


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
                    tasks t
                JOIN
                    TASK_CATEGORIES tg
                ON
                    t.TASK_CATEGORY_ID = tg.id

				lEFT JOIN
   				 	TASK_STEPS ts
				ON
   					 ts.id = t.STEP_ID

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

                WHERE
                    
                t.center IN (:scope)
				AND TYPE_ID = 400
				
               AND
                 p.STATUS NOT IN (5,7,8) --Dup Deleted Anon--
                AND t.STATUS NOT IN ('DELETED','CLOSED')
       