WITH
params AS
(
SELECT
  /*+ materialize */
  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
  c.id AS CENTER_ID,
  CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
FROM
  centers c
WHERE
	c.id in (:Scope)
)
SELECT 
        c.shortname AS "Club Name"
        ,TO_CHAR(longtodateC(act.entry_time,act.center),'YYYY-MM-dd') AS "Date" --(of the transaction/refund)
        ,p.center||'p'||p.id AS "Person ID"
        ,p.fullname AS "Person Name"
        ,pag.clearinghouse_ref AS "Payway ID"
        ,TO_CHAR(longtodateC(pag.creation_time,pag.center),'YYYY-MM-dd') AS "Payment Agreement creation Date"        
        ,act.amount AS "Amount"
        ,empp.fullname AS "Employee name" --(who was the employee that processed the transaction
FROM
        fernwood.account_trans act
JOIN
        fernwood.ar_trans art
        ON art.ref_center = act.center
        AND art.ref_id = act.id 
        AND art.ref_subid = act.subid
        AND art.amount < 0
JOIN
        fernwood.account_receivables ar
        ON ar.center = art.center
        AND ar.id = art.id
JOIN
        fernwood.persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
JOIN
        fernwood.employees emp
        ON emp.center = art.employeecenter
        AND emp.id = art.employeeid
JOIN
        fernwood.persons empp
        ON empp.center = emp.personcenter
        AND empp.id = emp.personid
JOIN
        fernwood.centers c
        ON c.id = act.center
LEFT JOIN
        fernwood.payment_agreements pag 
        ON ar.center = pag.center 
        AND ar.id = pag.id
        AND pag.clearinghouse = 2   
JOIN 
        params 
        ON params.CENTER_ID = act.center                                                                              
WHERE
        act.trans_type = 2
        AND
        act.info_type = 6
        AND
        art.installment_plan_id IS NULL
        AND
        act.entry_time BETWEEN params.FromDate AND params.ToDate
        --AND 
        --act.center in (:Scope)
Order by 1,3,6        
        