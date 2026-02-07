WITH
params AS
(
SELECT
  /*+ materialize */
  dateToLongC(getcentertime(c.id), c.id) AS CurrentDate,
          dateToLongC((to_char((to_date((getcentertime(c.id)), 'YYYY-MM-DD')-7 ),'YYYY-MM-DD HH24:MI:SS')), c.id) AS CutDate, 
          c.id AS CENTER_ID
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
        ,p.external_id AS "External ID"
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
        act.entry_time BETWEEN params.CutDate AND params.CurrentDate
        --AND 
        --act.center in (:Scope)
Order by 1,3,6