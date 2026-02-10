-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    CNL.PERSON_CENTER ||'p'|| CNL.person_id                     AS "Person ID",
    cnl.total_amount                                            AS "Credited Amount",
    cn.text                                                     AS "Credit Text",
    acc.name                                                    AS "Account configuration used",
    cn.employee_center ||'emp'|| cn.employee_id                 AS "Employee ID",
    p.fullname                                                  AS "Employee name",
    TO_CHAR(longtodateC(cn.ENTRY_TIME, cn.center),'yyyy-MM-dd') AS "Transaction_creation_date",
    TO_CHAR(longtodateC(cn.ENTRY_TIME, cn.center),'HH24:MI')    AS "Transaction_creation_time"
FROM
    CREDIT_NOTES CN
JOIN
    CREDIT_NOTE_LINES_MT CNL
ON
    CN.CENTER = CNL.CENTER
AND CN.ID = CNL.ID
JOIN
    ACCOUNT_TRANS act
ON
    act.center = cnl.ACCOUNT_TRANS_CENTER
AND act.id = cnl.ACCOUNT_TRANS_ID
AND act.subid = cnl.ACCOUNT_TRANS_SUBID
JOIN
    accounts acc
ON
    acc.center = act.DEBIT_ACCOUNTCENTER
AND acc.id = act.DEBIT_ACCOUNTID
JOIN
    products pr
ON
    cnl.PRODUCTCENTER = pr.center
AND cnl.PRODUCTid = pr.id
JOIN
    EMPLOYEES emp
ON
    emp.center = cn.employee_center
AND emp.id = cn.employee_id
JOIN
    EMPLOYEESROLES empr
ON
    empr.center = emp.center
AND empr.id = emp.id
JOIN
    ROLES ro
ON
    ro.id = empr.ROLEID
   AND ro.rolename = 'MS Audit'
JOIN
    persons p
ON
    p.center = emp.PERSONCENTER
AND p.id = emp.PERSONID
LEFT JOIN
    INVOICES I
ON
    I.CENTER = CNL.INVOICELINE_CENTER
AND I.ID = CNL.INVOICELINE_ID
WHERE
    CNL.CENTER IN(:scope)
AND CN.ENTRY_TIME >= getstartofday((:fromDate)::date::varchar, cn.center)
AND cn.ENTRY_TIME <= getendofday((:endDate)::date::varchar, cn.center)
AND cnl.total_amount > 0
AND cn.text NOT IN ('Subscription changed')