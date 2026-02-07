-- This is the version from 2026-02-05
--  
WITH params AS MATERIALIZED
(
        SELECT
                c.id,
                TO_DATE(:FromDate,'dd-MM-yyyy') as fromdate,
                TO_DATE(:ToDate,'dd-MM-yyyy') as todate
        FROM centers c
)
SELECT
        ss.subscription_center,
        pr.name,
        pr.globalid,
        ss.sales_date,
        TO_CHAR(longtodatec(s.creation_time, s.center) ,'DD-MM-YYYY hh24:mi:ss')AS sub_creationtime,
        s.owner_center || 'p' || s.owner_id,
        p.fullname,
        currp.external_id AS cp_externalid,
        ss.*
FROM subscription_sales ss
JOIN params par ON ss.subscription_center = par.id
JOIN subscriptions s ON ss.subscription_center = s.center AND ss.subscription_id = s.id
JOIN products pr ON pr.center = s.subscriptiontype_center AND pr.id = s.subscriptiontype_id
JOIN employees emp ON ss.employee_center = emp.center AND ss.employee_id = emp.id
JOIN persons p ON emp.personcenter = p.center AND emp.personid = p.id
JOIN persons mem ON mem.center = s.owner_center AND mem.id = s.owner_id
JOIN persons currp ON currp.center = mem.transfers_current_prs_center AND currp.id = mem.transfers_current_prs_id
WHERE
        ss.sales_date between par.fromdate and par.todate
       -- AND pr.globalid NOT IN ('STAFF_LOCAL_PRIVILEGES','STAFF_HEADOFFICE_GLOBAL','STAFF_GLOBAL_PRIVILEGES','DAYPASS')
	   AND s.owner_center in (:club)
     