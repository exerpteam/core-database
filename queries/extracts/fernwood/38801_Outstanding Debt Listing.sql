WITH
  params AS (
      SELECT
          datetolongC(TO_CHAR(CAST('2020-01-01' AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST(
              (datetolongC(
                  TO_CHAR((CAST('2025-12-31' AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),
                  c.id
              ) - 1
          ) AS BIGINT) AS ToDate
      FROM centers c
  ),
  t1 AS (
        SELECT 
            MAX(task.id) AS MAXID,
            task.person_center AS PersonCenter,
            task.person_id AS PersonID,
            tc.name AS Category
        FROM fernwood.tasks task
        JOIN params ON params.CENTER_ID = task.person_center
        JOIN fernwood.task_types tt
              ON tt.id = task.type_id
             AND tt.external_id = 'DM_NEW'
        LEFT JOIN fernwood.task_categories tc
              ON task.task_category_id = tc.id 
        WHERE task.status NOT IN ('CLOSED','DELETED')
          AND task.last_update_time BETWEEN params.FromDate AND params.ToDate
          AND task.person_center IN (:Scope)
        GROUP BY task.person_center, task.person_id, tc.name
  ),
  last_checkin AS (
        SELECT  
            longtodatec(list.checkin, list.person_center) AS checkins,
            list.person_center,
            list.person_id
        FROM (
            SELECT  
                MAX(ck.checkin_time) AS checkin,
                ck.person_center,
                ck.person_id
            FROM t1
            JOIN fernwood.checkins ck
              ON ck.person_center = PersonCenter
             AND ck.person_id = PersonID
            GROUP BY ck.person_center, ck.person_id
        ) list
  )

SELECT   
    t1.Category AS "Category",
    c.shortname AS "Center",
    p.center||'p'||p.id AS "Person ID",
    p.fullname AS "Person Full Name",
    CASE
        p.status
        WHEN 0 THEN 'Lead'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Inactive'
        WHEN 3 THEN 'TemporaryInactive'
        WHEN 4 THEN 'Transferred'
        WHEN 5 THEN 'Duplicate'
        WHEN 6 THEN 'Prospect'
        WHEN 7 THEN 'Deleted'
        WHEN 8 THEN 'Anonymized'
        WHEN 9 THEN 'Contact'
        ELSE 'Undefined'
    END AS "Member Status",
    t.status AS "Status",
    assignee.fullname AS "Assigned to",
    last_checkin.checkins AS "Last visit date",
    t.follow_up AS "Follow-up Date",
    TO_CHAR(longtodateC(t.creation_time, t.asignee_center),'YYYY-MM-DD') AS "Created date",
    TO_CHAR(longtodateC(t.last_update_time, t.asignee_center),'YYYY-MM-DD') AS "Last updated",
    ar.balance AS "Account Balance",
    CASE WHEN eac.balance IS NULL THEN 0 ELSE eac.balance END AS "Member Debt Collector Balance",
    CASE WHEN arip.balance IS NULL THEN 0 ELSE arip.balance END AS "Installment Plan Balance",
    CASE  
        WHEN pag.payment_cycle_config_id = 401 THEN 'Small billing'
        WHEN pag.payment_cycle_config_id = 1 THEN 'Big billing'
        ELSE 'FF_Invoice'
    END AS "Payment Cycle",
    p.external_id AS "External ID"
FROM fernwood.tasks t
JOIN t1
  ON t1.MAXID = t.id
 AND t1.PersonCenter = t.person_center
 AND t1.PersonID = t.person_id
LEFT JOIN fernwood.task_steps ts 
  ON ts.id = t.step_id
JOIN fernwood.persons p
  ON p.center = t.person_center
 AND p.id = t.person_id
LEFT JOIN fernwood.persons assignee
  ON assignee.center = t.asignee_center
 AND assignee.id = t.asignee_id
JOIN fernwood.centers c
  ON c.id = t.person_center
LEFT JOIN fernwood.person_ext_attrs pea
  ON pea.personcenter = p.center
 AND pea.personid = p.id
 AND pea.name = '_eClub_Email'
LEFT JOIN fernwood.zipcodes zc
  ON zc.zipcode = p.zipcode
 AND zc.city = p.city
LEFT JOIN fernwood.account_receivables ar
  ON p.center = ar.customercenter
 AND p.id = ar.customerid
 AND ar.ar_type = 4
LEFT JOIN fernwood.payment_accounts pac
  ON pac.center = ar.center
 AND pac.id = ar.id
LEFT JOIN fernwood.payment_agreements pag
  ON pac.active_agr_center = pag.center
 AND pac.active_agr_id = pag.id
 AND pac.active_agr_subid = pag.subid
LEFT JOIN fernwood.account_receivables eac
  ON p.center = eac.customercenter
 AND p.id = eac.customerid
 AND eac.ar_type = 5
LEFT JOIN fernwood.account_receivables arip
  ON arip.customercenter = p.center
 AND arip.customerid = p.id
 AND arip.ar_type = 6
LEFT JOIN last_checkin 
  ON last_checkin.person_center = p.center
 AND last_checkin.person_id = p.id
WHERE
  ts.name IN (
    '1 - R1 BA Send SMS EC',
    '1 - R1 CC Send SMS EC',
    '2 - R1 BA Send Email EC',
    '2 - R1 CC Send Email EC',
    '3 - R1 BA Reminder SMS EC',
    '3 - R1 CC Reminder SMS EC',
    '4 - R1 BA Follow up SMS EC',
    '4 - R1 CC Follow up SMS EC',
    '5 - R1 BA Follow up Email EC',
    '5 - R1 CC Follow up Email EC',
    '6 - R1 BA Debit Rolling EC',
    '6 - R1 CC Debit Rolling EC',
    '7 - R2 BA Send SMS EC',
    '7 - R2 CC Send SMS EC',
    '8 - R2 BA Send Email EC',
    '8 - R2 CC Send Email EC',
    '9 - R2 BA CALL EC***',
    '9 - R2 CC CALL EC***',
    '10 - R2 BA Reminder SMS EC',
    '10 - R2 BA Reminder SMS + Call EC',
    '10 - R2 CC Reminder SMS EC',
    '10 - R2 CC Reminder SMS + Call EC',
    '11 - R2 BA Follow up SMS EC',
    '11 - R2 CC Follow up SMS EC',
    '12 - R2 BA Follow up Email EC',
    '12 - R2 CC Follow up Email EC',
    '13 - R2 BA Debit Rolling EC',
    '13 - R2 CC Debit Rolling EC',
    '14 - R3 BA Send SMS EC',
    '14 - R3 CC Send SMS EC',
    '15 - R3 BA Send Email EC',
    '15 - R3 CC Send Email EC',
    '16 - R3 BA CALL EC***',
    '16 - R3 CC CALL EC***',
    '17 - R3 BA CALL EC***',
    '17 - R3 BA Reminder SMS',
    '17 - R3 BA Reminder SMS + Call EC',
    '17 - R3 BA Reminder SMS EC',
    '17 - R3 CC CALL EC***',
    '17 - R3 CC Reminder SMS',
    '17 - R3 CC Reminder SMS + Call EC',
    '17 - R3 CC Reminder SMS EC',
	'17 - R3 BA Reminder SMS + Call',
	'17 - R3 CC Reminder SMS + Call',
    '18 - R3 BA Follow up SMS',
    '18 - R3 BA Follow up SMS EC',
    '18 - R3 CC Follow up SMS',
    '18 - R3 CC Follow up SMS EC',
    '19 - R3 BA Follow up Email',
    '19 - R3 BA Follow up Email EC',
    '19 - R3 CC Follow up Email',
    '19 - R3 CC Follow up Email EC',
    '20 - R3 BA Debit Rolling',
    '20 - R3 BA Debit Rolling EC',
    '20 - R3 CC Debit Rolling',
    '20 - R3 CC Debit Rolling EC',
	'21 - BA Final SMS',
	'21 - BA Final SMS EC',
	'21 - CC Final SMS',
	'21 - CC Final SMS EC',
	'22 - BA CANCEL & END PMT AGR EC***',
	'22 - CC CANCEL & END PMT AGR EC***',
	'22 - BA CANCEL & END PMT AGR***',
	'22 - CC CANCEL & END PMT AGR***',
	'23 - BA Final Notice',
	'23 - BA Final Notice EC',
	'23 - CC Final Notice',
	'23 - CC Final Notice EC',
    '24 - Pending Referral to Collector',
    '25 - Referred To Debt Collector',
    'Club Manages Referral to Debt Collector',
    'Not Referred to Debt Collector')
ORDER BY
  longtodateC(t.last_update_time, t.asignee_center) DESC;