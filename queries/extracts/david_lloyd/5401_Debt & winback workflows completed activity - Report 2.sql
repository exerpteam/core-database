-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED (
  SELECT
      c.id AS center,
      c.name as name,
      datetolongc(:from_date ::date::varchar, c.id) AS from_date_long,
      datetolongc(:to_date ::date::varchar, c.id)   AS to_date_long
  FROM centers c
)
SELECT
      pr.name as "Club",
      p.center||'p'||p.id              as "Person Id",
      p.external_id     as "External Id",
      wf.name AS "Workflow",
      tld.value AS "Tasks",
      employee.fullname as "User",
      longtodatec(tl.entry_time,pr.center) ::date as "Date of Call"           
  FROM task_log tl
  JOIN tasks t
    ON t.id = tl.task_id
  JOIN
       task_actions ta
    ON
       ta.id = tl.task_action_id and ta.name='Call'
  JOIN task_types tt
    ON tt.id = t.type_id
  JOIN workflows wf
    ON wf.id = tt.workflow_id
  JOIN persons p
    ON p.center = t.person_center
   AND p.id     = t.person_id
  JOIN task_log_details tld
    ON tld.task_log_id = tl.id
   AND tld.name = 'RequirementType.USER_CHOICE'
  JOIN params pr
    ON pr.center = p.center AND 
    tl.entry_time >= pr.from_date_long
   AND tl.entry_time <=  pr.to_date_long 
  left join persons employee
   On  tl.employee_id=employee.id and tl.employee_center=employee.center
  WHERE wf.name IN ('Winback', 'Debt')
    AND (
      (wf.name = 'Winback' AND tld.value IN ('Accepted - 1 Month','Accepted - 2 Months','Accepted no offer','Declined','Follow Up'))
      OR
      (wf.name = 'Debt'    AND tld.value IN ('Debt Paid','Debt Paid & Direct Debit','Debt Not Paid','Follow Up','No Contact'))
    )
    order by p.id