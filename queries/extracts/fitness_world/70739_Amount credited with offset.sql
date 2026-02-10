-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
           (TRUNC(current_timestamp) - :offset - to_date('01-01-1970','DD-MM-YYYY')) * 24 * 3600 * 1000::bigint AS FROMDATE
          , (TRUNC(current_timestamp+1) - to_date('01-01-1970','DD-MM-YYYY')) * 24 * 3600 * 1000::bigint            AS TODATE
        
    )
 SELECT
cn.employee_center                                                                  AS Center_number,
    cn.employee_center ||'emp'|| cn.employee_id                                AS Employee_ID,
    p.fullname                                                                 AS Employee_name,
     CNL.PERSON_CENTER ||'p'|| CNL.person_id                                    AS Member_credited,
   to_char(longtodate(cn.ENTRY_TIME),'yyyy-MM-dd') as "Transaction_creation_date",
    to_char(longtodate(cn.ENTRY_TIME),'HH24:MI') as "Transaction_creation_time",
        cnl.total_amount                                                           as Amount, 
    pr.NAME                                                                    AS Item_credited, 
    cn.text                                                                    AS Credit_Note_TEXT
FROM
    CREDIT_NOTES CN
JOIN
    CREDIT_NOTE_LINES_MT CNL
ON
    CN.CENTER = CNL.CENTER
AND CN.ID = CNL.ID
cross join params 
join products pr
on
cnl.PRODUCTCENTER = pr.center 
and
cnl.PRODUCTid = pr.id

join EMPLOYEES emp
on
emp.center = cn.employee_center
and emp.id = cn.employee_id

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
    CNL.CENTER IN(:CNCenter)
AND CN.ENTRY_TIME >= params.FromDate
AND CN.ENTRY_TIME <= params.ToDate
and cnl.total_amount > 0
AND emp.center || 'emp' || emp.id NOT IN ('114emp813')
and cn.text NOT IN ('Medlemskab ændret')
and cn.text NOT LIKE ('Annulering af%%')
