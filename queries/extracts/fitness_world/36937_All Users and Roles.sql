-- This is the version from 2026-02-05
--  
SELECT
    emp.center || 'emp' || emp.id          AS "Employee Id",
    CASE per.PERSONTYPE
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        ELSE 'UNKNOWN'
    END AS "Person Type",
    CASE per.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "Person Status",    
    per.fullname                           AS "Member Name",
        CASE
        WHEN emprole.scope_type = 'G' THEN 'Global'
        WHEN emprole.scope_type IN ('A','T') THEN a.name
        WHEN emprole.scope_type = 'C' THEN c.name
        ELSE 'Unknown'
    END AS "Role Scope",
    role.rolename                                                                    AS "Role Name",
    TO_CHAR(LONGTODATEC(last_login.last_login_date, emp.center), 'YYYY-MM-DD HH24:MI') AS "Last Login Datetime",
emp.blocked,
per.external_id
FROM
    employees emp
JOIN
    persons per
ON
    per.center = emp.personcenter
    AND per.id = emp.personid
JOIN
    employeesroles emprole
ON
    emprole.center = emp.center
    AND emprole.id = emp.id
JOIN
    roles role
ON
    role.id = emprole.roleid
LEFT JOIN
    areas a
ON
    a.id = emprole.scope_id
LEFT JOIN
    centers c
ON
    c.id = emprole.scope_id
LEFT JOIN
    (
        SELECT
            login.employee_center,
            login.employee_id,
            MAX(login.log_in_time) last_login_date
        FROM
            log_in_log login
        GROUP BY
            login.employee_center,
            login.employee_id
    ) last_login
ON
    last_login.employee_center = emp.center
    AND last_login.employee_id = emp.id
WHERE
    emp.personcenter IN ($$Scope$$)   
--and emp.blocked = 0
and per.STATUS in (1,3)
and per.PERSONTYPE = 2
and role.rolename in 
('Admin, Activity manager AskCustomer',
'BI Access',
'Clubs, Activity coordinator',
'Ekspresbank',
'Exerp',
'ExtractsAddOn',
'Frontdesk manager lock role',
'FW-DK, Activator',
'FW-DK, District Manager',
'FW-DK, Finance manager',
'FW-DK, GF support',
'FW-DK, Gym Staff',
'FW-DK, HQ frokost',
'FW-DK, Inventory Manager',
'FW-DK, IT support',
'FW-DK, Lindorff',
'FW-DK, Memberservice',
'FW-DK, Product manager',
'FW-DK, PT',
'FW-DK, PT department',
'FW-DK, PT Premium clipcard',
'FW-DK, Regional manager',
'FW-DK, Regional PT Lead',
'Marketing coordinator',
'MarketingManager',
'Member Web API role',
'Memberships support',
'Planday',
'Sales',
'Sell Legacy Subscriptions',
'Sergel',
'Staff manager',
'Subscription Special',
'Subscription_Special_archived',
'SUPPL, Corporate account manager',
'SUPPL, District Manager',
'SUPPL, Gym Staff',
'SUPPL, Sponsor',
'SYS, IT support',
'SYS, Online sales lock role',
'SYS, TEST web',
'Sælg personale medlemskab')
ORDER BY 1;
