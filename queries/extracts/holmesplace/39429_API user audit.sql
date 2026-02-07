SELECT
        distinct on (emp.center||'emp'||emp.id)
        
        emp.center||'emp'||emp.id AS emp_key,
        r.rolename,
        emp.blocked,
        emp.use_api, p.firstname, p.lastname, emph.*
   FROM
        employees emp
   JOIN
        employeesroles er ON er.center = emp.center AND er.id = emp.id
   JOIN
        roles r ON r.id = er.roleid
        
        join persons p on emp.personcenter = p.center and emp.personid = p.id
        join
         (
        Select max(start_date), employee_center,
        employee_id
        from
        employee_password_history 
        group by
        employee_center,
        employee_id ) emph
        on emph.employee_center=emp.center aND emp.id=emph.employee_id
        
  WHERE
        emp.blocked IS false
        AND emp.use_api IS true
        AND r.rolename in ( 'UseAPI', 'API User', 'Exerp', 'HP Exerp Configurator/Developer', 'HP Super user', 'Super User Max')







