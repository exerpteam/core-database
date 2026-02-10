-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED (
  SELECT
      c.id AS center,
      datetolongc(:from_date ::date::varchar, c.id) AS from_date_long,
      datetolongc(:to_date ::date::varchar, c.id)   AS to_date_long
  FROM centers c
),
base AS (
  SELECT
      p.fullname,
      wf.name AS wf,
      tld.value AS activity_outcome
  FROM task_log tl
  JOIN tasks t
    ON t.id = tl.task_id
  JOIN task_types tt
    ON tt.id = t.type_id
  JOIN workflows wf
    ON wf.id = tt.workflow_id
  JOIN persons p
    ON p.center = t.asignee_center
   AND p.id     = t.asignee_id
  JOIN task_log_details tld
    ON tld.task_log_id = tl.id
   AND tld.name = 'RequirementType.USER_CHOICE'
  JOIN params pr
    ON pr.center = t.asignee_center AND 
    tl.entry_time >= pr.from_date_long
   AND tl.entry_time <=  pr.to_date_long  
  WHERE wf.name IN ('Winback', 'Debt')
    AND (
      (wf.name = 'Winback' AND tld.value IN ('Accepted - 1 Month','Accepted - 2 Months','Accepted no offer','Declined','Follow Up'))
      OR
      (wf.name = 'Debt'    AND tld.value IN ('Debt Paid','Debt Paid & Direct Debit','Debt Not Paid','Follow Up','No Contact'))
    )
)
SELECT
    fullname as "Full Name",

    -- Debt
    COUNT(*) FILTER (WHERE wf='Debt' AND activity_outcome='Debt Paid')                 AS "Debt Paid",
    COUNT(*) FILTER (WHERE wf='Debt' AND activity_outcome='Debt Paid & Direct Debit') AS "Debt paid and DD set up",
    COUNT(*) FILTER (WHERE wf='Debt' AND activity_outcome='Debt Not Paid')            AS "Declined to pay",
    COUNT(*) FILTER (WHERE wf='Debt' AND activity_outcome='Follow Up')                AS "Follow Up",
    COUNT(*) FILTER (WHERE wf='Debt' AND activity_outcome='No Contact')               AS "No Contact",
    COUNT(*) FILTER (WHERE wf='Debt')                                                 AS "Total",

    -- Winback
    COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Accepted - 1 Month')    AS "Accepted - 1 Month",
    COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Accepted - 2 Months')   AS "Accepted - 2 Months",
    COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Accepted no offer')     AS "Accepted no offer",
    COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Declined')              AS "Declined",
    COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Follow Up')             AS "Follow Up",
    COUNT(*) FILTER (WHERE wf='Winback')                                              AS "Total",
    (COUNT(*) FILTER (WHERE wf='Winback') + COUNT(*) FILTER (WHERE wf='Debt'))        AS "Total of both workflows",
    (
      COUNT(*) FILTER (WHERE wf='Debt'    AND activity_outcome='Debt Paid')
      + 2 * COUNT(*) FILTER (WHERE wf='Debt' AND activity_outcome='Debt Paid & Direct Debit')
      + COUNT(*) FILTER (WHERE wf='Debt'    AND activity_outcome='Debt Not Paid')
      + COUNT(*) FILTER (WHERE wf='Debt'    AND activity_outcome='Follow Up')
      + COUNT(*) FILTER (WHERE wf='Debt'    AND activity_outcome='No Contact')
      + COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Accepted - 1 Month')
      + 3 * COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Accepted - 2 Months')
      + 2 * COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Accepted no offer')
      + COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Declined')
      + COUNT(*) FILTER (WHERE wf='Winback' AND activity_outcome='Follow Up')
    ) AS "Total Contribution weighting"

FROM base
GROUP BY fullname
ORDER BY fullname