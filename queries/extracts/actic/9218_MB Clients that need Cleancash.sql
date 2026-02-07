SELECT
	cen.external_ID,
	cl.id Client_id,
	cl.center,
	cen.shortname,
	cen.ADDRESS1,
	cen.ZIPCODE,
	cen.CITY,
	cl.id clientid,
	cl.name client_name,
	mod_ci.username,
	mod_ci.ipaddress,
	cr.center || 'cr' || cr.id pos_id,
	cr.name cr_name,
	cr.CC_PAYMENT_METHOD,
	DECODE (cr.cash, 0,'NONE', 1,'Cash') cash_in_register,
	DECODE (d.driver, 'dk.procard.eclub.devices.drivers.point.se.XentaSEDriver','Point SE','NONE') CREDITCARD1,
	DECODE (d1.driver, 'dk.procard.eclub.devices.drivers.point.no.v5014.PayPointDriver','Point NO','NONE') CREDITCARD2,
	DECODE (d2.driver, 'dk.procard.eclub.devices.drivers.cleancash.CleanCashDriver','TRUE','FALSE') CLEANCASH,
	TO_DATE('19700101','yyyymmdd') + ((mod_ci.startuptime/1000)/24/60/60) last_time_cl_started

FROM
	clients cl

JOIN (
		SELECT
			ci.client,
			ci.ipaddress,
			ci.username,
			ci.hostname,
			ci.startuptime,
			ci.shutdowntime	
		FROM (
				SELECT
					ci.client client,
					MAX(ci.startuptime) startuptime
				FROM
					client_instances ci
				GROUP BY
					ci.client
			) ci_x
		JOIN client_instances ci
		ON
		ci_x.client = ci.client
		AND ci_x.startuptime = ci.startuptime
	) mod_ci
ON
	mod_ci.client = cl.id
JOIN systemproperties sp 
ON 
	sp.client = cl.id 
	AND sp.globalid='CLIENT_CASHREGISTER'	
LEFT JOIN devices d
ON
	cl.id = d.client
	AND d.driver = 'dk.procard.eclub.devices.drivers.point.se.XentaSEDriver'
	AND d.enabled = 1
LEFT JOIN devices d1
ON
	cl.id = d1.client
	AND d1.driver = 'dk.procard.eclub.devices.drivers.point.no.v5014.PayPointDriver'
	AND d1.enabled = 1
LEFT JOIN devices d2
ON
	cl.id = d2.client
	AND d2.driver = 'dk.procard.eclub.devices.drivers.cleancash.CleanCashDriver'
	AND d2.enabled = 1
JOIN centers cen
ON
	cen.id = cl.center
LEFT JOIN cashregisters cr
ON
	cl.center = cr.center
	AND sp.txtvalue = cr.id

WHERE
	cl.center IN (:ChosenScope)
	AND cl.center NOT IN (100, 500, 600)
	AND cl.type = 'CLIENT'
	AND cl.state = 'ACTIVE'

ORDER BY
	cr.center,
	cr.id