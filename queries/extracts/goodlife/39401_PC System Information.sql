WITH
      Q1 AS
      (
          select extract(epoch from now())* 1000 - 2592000000 AS compare, c.id
          FROM centers c
      )
SELECT DISTINCT
     c.name AS "Center",
     ci.ipaddress AS "IP Address",
     ci.hostname AS "Hostname",
     ci.username AS "Username",
     ci.javainfo AS "Java Version",
     ci.osinfo AS "Operating System",
     ci.locale AS "Locale",
     cl.name AS "Client Name",
     cr.name AS "Cash Register"
FROM clients cl
LEFT JOIN systemproperties sp
ON sp.client = cl.id
AND sp.globalid = 'CLIENT_CASHREGISTER'
LEFT JOIN cashregisters cr
ON cl.center = cr.center
AND CAST (sp.txtvalue AS INTEGER) = cr.id
LEFT JOIN client_instances ci
ON cl.clientid = ci.certificate_name
LEFT JOIN centers c
ON cl.center = c.id
JOIN Q1
ON c.id = Q1.id
WHERE cl.state = 'ACTIVE' AND cl.type = 'CLIENT' AND last_contact IS NOT NULL AND last_contact >= 0 AND ci.hostname IS NOT NULL 
AND ci.shutdowntime > Q1.compare
AND ci.hostname IN (:pcname)