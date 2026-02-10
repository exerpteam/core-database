-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    CNL.PERSON_CENTER ||'p'|| CNL.person_id                                    AS "Person ID",
    cnl.total_amount                                                           as "Credited Amount", 
    cn.text                                                                  AS "Credit Text",
    acc.name                                                                 AS "Account configuration used",
    cn.employee_center ||'emp'|| cn.employee_id                                AS "Employee ID",
    p.fullname                                                                 AS "Employee name",
  to_char(longtodate(cn.ENTRY_TIME),'yyyy-MM-dd') as "Transaction_creation_date",
    to_char(longtodate(cn.ENTRY_TIME),'HH24:MI') as "Transaction_creation_time"
        
FROM
    CREDIT_NOTES CN
JOIN
    CREDIT_NOTE_LINES_MT CNL
ON
    CN.CENTER = CNL.CENTER
AND CN.ID = CNL.ID
join ACCOUNT_TRANS act
on
act.center = cnl.ACCOUNT_TRANS_CENTER
and
act.id = cnl.ACCOUNT_TRANS_ID
and
act.subid = cnl.ACCOUNT_TRANS_SUBID
join accounts acc
on
acc.center = act.DEBIT_ACCOUNTCENTER
and
acc.id = act.DEBIT_ACCOUNTID

join products pr
on
cnl.PRODUCTCENTER = pr.center 
and
cnl.PRODUCTid = pr.id

join EMPLOYEES emp
on
emp.center = cn.employee_center
and emp.id = cn.employee_id

join EMPLOYEESROLES empr
on
empr.center = emp.center
and
empr.id = emp.id
join ROLES ro
on
ro.id = empr.ROLEID
and
ro.rolename = 'MS Audit'

join persons p 
on
p.center = emp.PERSONCENTER
and
p.id = emp.PERSONID 

LEFT JOIN
    INVOICES I
ON
    I.CENTER = CNL.INVOICELINE_CENTER
AND I.ID = CNL.INVOICELINE_ID
WHERE
    CNL.CENTER IN(:scope)
AND CN.ENTRY_TIME >= :Fromdate                                          AND cn.ENTRY_TIME <= :Todate+(24*3600*1000)
and cnl.total_amount > 0
and cn.text NOT IN ('Subscription changed')