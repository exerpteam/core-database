-- This is the version from 2026-02-05
--  
SELECT DISTINCT
    cli.IPADDRESS,
    cl.CENTER,
    cli.USERNAME,
    cli.HOSTNAME,
    cli.CLIENT,
    cli.OSINFO,
	cl.NAME
FROM
    client_instances cli
JOIN
    clients cl
ON
    cli.HOSTNAME = cl.NAME
WHERE
    cl.STATE = 'ACTIVE' -- Only active clients
AND cli.JAVAINFO = '1.8.0_222(25.222-b10)' -- Only considering installer java version
GROUP BY
    cl.center,
    cli.IPADDRESS,
    cli.USERNAME,
    cli.HOSTNAME,
    cli.CLIENT,
    cli.OSINFO,
	cl.NAME