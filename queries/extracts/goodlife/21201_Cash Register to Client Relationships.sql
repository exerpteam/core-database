SELECT DISTINCT
    c.shortname                                                            AS "Center",
    cl.type                                                                AS "Type",
    ci.username                                                            AS "User",
    ci.ipaddress                                                           AS "IP Address",
    cl.state                                                               AS "State",
    TO_CHAR(longtodatec(ci.startuptime, cl.center), 'YYYY-MM-dd HH24:MI')  AS "Startup Time",
    TO_CHAR(longtodatec(ci.shutdowntime, cl.center), 'YYYY-MM-dd HH24:MI') AS "Shutdown Time",
    ci.javainfo                                                            AS "Java Version",
    ci.osinfo                                                              AS "Operating System",
    ci.macaddress                                                          AS "MAC Address",
    cr.name                                                                AS "Cash Register Type"
FROM
    clients cl
JOIN
    centers c
ON
    c.id = cl.center
JOIN
    (
        SELECT
            ci.client,
            MAX(ci.id)            AS id,
            MAX(ci.creation_time) AS creation_time
        FROM
            client_instances ci
        GROUP BY
            ci.client ) cl_inst
ON
    cl_inst.client = cl.id
JOIN
    client_instances ci
ON
    ci.client = cl_inst.client
    AND ci.id = cl_inst.id
    AND ci.creation_time = cl_inst.creation_time
JOIN
    cashregisters cr
ON
    cr.center = c.id