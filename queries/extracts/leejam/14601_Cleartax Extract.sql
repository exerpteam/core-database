-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
          params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST('2024-01-21' AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID
      FROM
          centers c
  )  
SELECT 
        *
FROM
        (
        SELECT  
                inv.clearance_status
                ,inv.center||'inv'||inv.id as transactionID
                ,longtodatec(inv.trans_time,inv.center) as transdate 
                ,longtodatec(inv.entry_time,inv.center) as entrydate
                ,inv.employee_center||'emp'||inv.employee_id as employee
                ,inv.cashregister_center
                ,inv.cashregister_id
                ,inv.payer_center||'p'||inv.payer_id as person_id
                ,inv.text
                ,p.sex
        FROM 
                leejam.invoices inv
        JOIN
                params
                ON params.center_id = inv.center 
        LEFT JOIN
                leejam.persons p
                ON p.center = inv.payer_center
                AND p.id = inv.payer_id 
        WHERE
                 inv.clearance_status != 'NOT_NEEDED'
                 AND
                 inv.trans_time > params.FromDate
        UNION ALL
        SELECT 
                cn.clearance_status
                ,cn.center||'cred'||cn.id as transactionID
                ,longtodatec(cn.trans_time,cn.center) as transdate  
                ,longtodatec(cn.entry_time,cn.center) as entrydate  
                ,cn.employee_center||'emp'||cn.employee_id as employee
                ,cn.cashregister_center
                ,cn.cashregister_id
                ,cn.payer_center||'p'||cn.payer_id as person_id
                ,cn.text
                ,p.sex 
        FROM 
                leejam.credit_notes cn
        JOIN
                params
                ON params.center_id = cn.center
        LEFT JOIN
                leejam.persons p
                ON p.center = cn.payer_center
                AND p.id = cn.payer_id                                  
        WHERE
                cn.clearance_status != 'NOT_NEEDED'   
                AND
                cn.trans_time > params.FromDate
        )t        