-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ES-25924
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:FROM AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID
      FROM
          centers c
  )
SELECT DISTINCT
        inv.payer_center||'p'||inv.payer_id AS "PersonID"
        ,CAST(longtodateC(ar.trans_time,ar.center) as date) AS "Invoice Date"
        ,inv.text AS "Invoice Description"              
        ,ar.amount AS "Invoice Amount"
        ,ar.unsettled_amount AS "Outstanding Amount"       
        ,CASE
                WHEN ip.person_center IS NULL THEN 'No'
                Else 'Yes'
        END AS "Installment Account"                
FROM
        invoices inv
JOIN
        invoice_lines_mt invl
        ON invl.center = inv.center
        AND invl.id = inv.id  
JOIN
        ar_trans ar
        ON ar.ref_center = invl.center 
        AND ar.ref_id = invl.id 
        AND ar.ref_type = 'INVOICE' 
LEFT JOIN
        (SELECT
                ip.person_center 
                ,ip.person_id
                ,pea.txtvalue AS "Old System ID"
                ,ipc.name AS "Installment"
                ,ipc.installment_plan_type "Installment Type"
                ,ip.amount AS "Total Original Installment amount"
                ,TO_CHAR(longtodateC(ip.creation_time,ip.person_center),'YYYY-MM-DD HH24:MI') AS "Creation Date"
                ,ip.end_date AS "Installment End Date"
                ,ip.installements_count 
                ,ar.balance AS "Installment Plan Account Balance"
                ,ip.id AS "Installemtn ID"
        FROM 
                installment_plans ip
        JOIN
                installment_plan_configs ipc
                ON ipc.id = ip.ip_config_id
        LEFT JOIN
                person_ext_attrs pea
                ON pea.personcenter = ip.person_center
                AND pea.personid = ip.person_id 
                AND pea.name = '_eClub_OldSystemPersonId' 
        LEFT JOIN
                account_receivables ar
                ON ar.customercenter = ip.person_center
                AND ar.customerid = ip.person_id 
                AND ar.ar_type = 6
        WHERE 
                ar.balance != 0                
        )ip
        ON ip.person_center = inv.payer_center
        AND ip.person_id = inv.payer_id
JOIN
        persons p
        ON p.center = inv.payer_center
        AND p.id = inv.payer_id 
JOIN 
        params 
        ON params.CENTER_ID = p.center                                                 
WHERE
        ar.due_date is null
        AND 
        ar.amount != 0
        AND
        inv.text != 'Converted subscription invoice'
        AND 
        ar.status = 'NEW'
        AND 
        inv.text like '%(Auto Renewal)' --To remove manual invoices raised by users of Fernwood
        AND
        ar.trans_time < params.FromDate  --Exclude todays invoices for tomorrow's billing