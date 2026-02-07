SELECT
  emp."EmployeeCenter"||'emp'||emp."EmployeeID" AS "Employee ID",
  p.Fullname,
  emp."LastLogin",
  emp."Role",
    CASE WHEN emp."Blocked" = 1
     THEN 'Blocked'
     ELSE 'Active'
    END AS "Role Status",
    listagg (prd.Name, ', ') WITHIN GROUP (ORDER BY prd.Name) Memberships,
    listagg (DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect'),', ') WITHIN GROUP (ORDER BY prd.Name) SubscriptionTypes
FROM
    (
    SELECT
    e.CENTER AS "EmployeeCenter",
    e.ID AS "EmployeeID",
    e.PERSONCENTER AS "PersonCenter",
    e.PERSONID AS "PersonId",
    e.BLOCKED  AS "Blocked",
    e.LAST_LOGIN AS "LastLogin",
    r.ROLENAME AS  "Role"
FROM
    Employees e
LEFT JOIN 
    EmployeesRoles er
ON
    e.CENTER = er.CENTER AND e.ID = er.ID
JOIN 
    Roles r
ON
    er.ROLEID = r.ID
) emp
JOIN
    Persons p
ON
    p.CENTER = emp."PersonCenter" AND p.ID = emp."PersonId"
LEFT JOIN
    Subscriptions s
ON
    s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID  AND s.STATE IN (2,4,8) 
LEFT JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center AND st.id = s.subscriptiontype_id
LEFT JOIN
    products prd 
ON
    prd.center = st.center AND prd.id = st.id 
WHERE
    emp."EmployeeCenter" in (:Scope) 
GROUP BY p.Fullname, emp."Blocked", emp."LastLogin", emp."Role", emp."EmployeeCenter"||'emp'||emp."EmployeeID"