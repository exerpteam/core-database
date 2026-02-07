SELECT DISTINCT
    cl.CENTER,
    cl.CLIENTID,
    cl.name as NAME,
    cli.MACADDRESS,
    cl.TYPE,
    longtodate(MAX(CLI2.STARTUPTIME)) as LATEST_STARTUP
FROM
    clients clcert
LEFT JOIN
    CLIENT_INSTANCES cli
ON
    cli.CERTIFICATE_NAME = clcert.CLIENTID
JOIN
    clients cl
ON
    cl.ID = cli.CLIENT
JOIN
    CLIENT_INSTANCES cli2
ON
    cli2.client = cl.id
WHERE
    CL.STATE = 'ACTIVE'
    AND clcert.EXPIRATION_DATE >= exerpsysdate()
    AND cl.center in (:Scope)
GROUP BY
    cl.CENTER,
    cl.CLIENTID,
    cl.name,
    cli.MACADDRESS,
    cl.TYPE
ORDER BY
    longtodate(MAX(CLI2.STARTUPTIME)) desc