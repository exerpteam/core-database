-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2312
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT 
        p.center ||'p'|| p.id AS "Member ID"
        ,p.fullname AS "Member Name"
        ,company.center ||'p'|| company.id AS "Company ID"
        ,company.fullname AS "Company Name"
        ,TO_CHAR(longtodateC(act.entry_time,act.center),'YYYY-MM-dd') AS "Creation Date"
        ,TO_CHAR(longtodateC(act.trans_time,act.center),'YYYY-MM-dd') AS "Book Date"
        ,act.text AS "Reason"
        ,art.amount AS "Amount"
        ,ac.name AS "Global Account"
        ,empp.center ||'p'|| empp.id AS "Employee ID"
        ,empp.fullname AS "Employee Name"
FROM
        leejam.account_trans act
JOIN
        leejam.ar_trans art
                ON act.center = art.ref_center
                AND act.id = art.ref_id
                AND act.subid = art.ref_subid      
JOIN
        leejam.account_receivables ar
                ON ar.center = art.center
                AND ar.id = art.id
JOIN
        leejam.persons p
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
JOIN
        leejam.accounts ac
                ON ac.center = act.credit_accountcenter
                AND ac.id = act.credit_accountid   
JOIN
        leejam.employees emp
                ON emp.center = art.employeecenter
                AND emp.id = art.employeeid
JOIN
        leejam.persons empp
                ON empp.center = emp.personcenter
                AND empp.id = emp.personid
LEFT JOIN
        leejam.relatives rel
                ON rel.relativecenter = p.center
                AND rel.relativeid = p.id
                AND rel.rtype = 2
                AND rel.status = 1   
LEFT JOIN
        leejam.persons company
                ON company.center = rel.center
                AND company.id = rel.id
JOIN 
        params 
                ON params.CENTER_ID = act.center
WHERE
        act.info_type = 11
        AND
        act.trans_type = 2
        AND
        art.amount < 0
        AND
        act.entry_time BETWEEN params.FromDate AND params.ToDate
        AND
        act.center in (:Scope) 
        