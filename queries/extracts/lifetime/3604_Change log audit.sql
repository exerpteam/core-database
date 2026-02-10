-- The extract is extracted from Exerp on 2026-02-08
-- List of changes made during the last 7 days by staff members who does not have the Exerp role
SELECT
    longtodateTZ(cl.entry_time, 'America/Toronto') AS "changetime",
    CASE
        WHEN cl.type = 1
        THEN 'Add'
        WHEN cl.type = 2
        THEN 'Update'
        ELSE 'Unknown'
    END                                       AS change_type,
    cl.employee_center||'emp'||cl.employee_id AS employee,
    cl.service_name,
    source_primary   AS "Property",
    source_secondary AS "Sub Property"--,*
FROM
    change_logs cl
WHERE
    (
        cl.employee_center, cl.employee_id) NOT IN
    (
        SELECT
            er.center,
            er.id
        FROM
            employeesroles er
        JOIN
            roles r
        ON
            er.roleid = r.id
        WHERE
            r.rolename = 'Exerp'
            )
AND cl.entry_time >= (extract(epoch FROM CURRENT_TIMESTAMP)*1000 - 168*60*60*1000)