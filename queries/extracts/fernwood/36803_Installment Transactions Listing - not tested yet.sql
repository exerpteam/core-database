WITH
  params AS
  (
      SELECT
          /*+ materialize */
          TO_DATE(:FromDate,'YYYY-MM-DD') AS FromDate,
          c.id AS CENTER_ID,
          TO_DATE(:ToDate,'YYYY-MM-DD') AS ToDate
      FROM
          centers c
  )
SELECT
        t.*
FROM
        (
        SELECT
                p.center
                ,p.center||'p'||p.id AS PersonID
                ,art.text AS Description
                ,art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid AS transaction_id
                ,longtodatec(art.entry_time,art.center)::date AS invoice_date
                ,art.due_date
                ,longtodatec(arm.entry_time,arm.art_paid_center)::date AS InvoiceSettlementDate
                ,CASE
                        WHEN artp.ref_type = 'ACCOUNT_TRANS' THEN artp.ref_center||'acc'||artp.ref_id||'tr'||artp.ref_subid 
                        WHEN artp.ref_type = 'CREDIT_NOTE' THEN artp.ref_center||'cred'||artp.ref_id 
                END AS Payment_transaction
                ,empp.fullname AS Employee
                ,-art.amount AS total_amount
                ,-art.collected_amount AS settled_amount
                ,-art.unsettled_amount
                ,'Installment Plan' AS Trans_type
        FROM
                fernwood.account_receivables ar
        JOIN
                fernwood.ar_trans art
                ON ar.center = art.center
                AND ar.id = art.id
                AND ar.ar_type = 4
        JOIN
                fernwood.persons p
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
        JOIN
                fernwood.installment_plans ip
                ON ip.id = art.installment_plan_id 
        JOIN
                fernwood.art_match arm
                ON arm.art_paid_center = art.center
                AND arm.art_paid_id = art.id
                AND arm.art_paid_subid = art.subid
                AND arm.cancelled_time IS NULL    
        JOIN
                fernwood.ar_trans artp
                ON artp.center = arm.art_paying_center
                AND artp.id = arm.art_paying_id
                AND artp.subid = arm.art_paying_subid 
        LEFT JOIN
                fernwood.employees emp
                ON emp.center = artp.employeecenter
                AND emp.id = artp.employeeid
        LEFT JOIN
                fernwood.persons empp
                ON empp.center = emp.personcenter
                AND empp.id = emp.personid                         
        WHERE 
                art.ref_type = 'ACCOUNT_TRANS'
                AND art.amount < 0
                AND art.installment_plan_subindex IS NOT NULL
        UNION ALL
        SELECT
                p.center
                ,p.center||'p'||p.id AS PersonID
                ,art.text AS Description
                ,art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid AS transaction_id
                ,longtodatec(art.entry_time,art.center)::date AS invoice_date
                ,art.due_date
                ,longtodatec(arm.entry_time,arm.art_paid_center)::date AS InvoiceSettlementDate
                ,CASE
                        WHEN artp.ref_type = 'ACCOUNT_TRANS' THEN artp.ref_center||'acc'||artp.ref_id||'tr'||artp.ref_subid 
                        WHEN artp.ref_type = 'CREDIT_NOTE' THEN artp.ref_center||'cred'||artp.ref_id 
                END AS Payment_transaction
                ,empp.fullname AS Employee
                ,-art.amount AS total_amount
                ,-art.collected_amount AS settled_amount
                ,-art.unsettled_amount
                ,'Manual invoice' AS Trans_type
        FROM
                fernwood.account_receivables ar
        JOIN
                fernwood.ar_trans art
                ON ar.center = art.center
                AND ar.id = art.id
                AND ar.ar_type = 4
        JOIN
                fernwood.persons p
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
        JOIN
                fernwood.art_match arm
                ON arm.art_paid_center = art.center
                AND arm.art_paid_id = art.id
                AND arm.art_paid_subid = art.subid
                AND arm.cancelled_time IS NULL    
        JOIN
                fernwood.ar_trans artp
                ON artp.center = arm.art_paying_center
                AND artp.id = arm.art_paying_id
                AND artp.subid = arm.art_paying_subid 
        LEFT JOIN
                fernwood.employees emp
                ON emp.center = artp.employeecenter
                AND emp.id = artp.employeeid
        LEFT JOIN
                fernwood.persons empp
                ON empp.center = emp.personcenter
                AND empp.id = emp.personid                         
        WHERE 
                art.ref_type = 'ACCOUNT_TRANS'
                AND art.amount < 0
                AND art.installment_plan_subindex IS NULL
        )t
JOIN
        params
        ON params.center_id = t.center        
WHERE
        t.due_date != t.invoicesettlementdate
        AND
        t.center IN (:Scope)
        AND
        t.invoicesettlementdate BETWEEN params.FromDate AND params.ToDate                                                        