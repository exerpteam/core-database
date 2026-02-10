-- The extract is extracted from Exerp on 2026-02-08
-- List the bookingresources with the external_id = 'VirtualAttend". This should be exported to website and used as ID when attending with inverted QR-code.
SELECT 
	c.NAME,
	c.ID AS CENTER,
	br.NAME AS RESOURCE_NAME,
	br.ID::varchar AS VIRTUALATTEND_ID,
	'' AS GATE,
	c.id||'#'||'VIRTUALATTEND'||'#'||br.ID AS QR_STRING,
	'https://webapi.se/qr-checkin/generate'|| chr(63)||'centerId='||c.id||'&resourceType=VIRTUALATTEND&resourceId='||br.ID AS QR_URL
FROM CENTERS c
LEFT JOIN BOOKING_RESOURCES br 
	ON br.CENTER = c.ID
WHERE br.EXTERNAL_ID='VirtualAttend'

UNION

SELECT 
	c.NAME,
	c.ID AS CENTER,
	up.NAME AS RESOURCE_NAME,
	'' AS VIRTUAL_ATTEND_ID,
	ups.EXTERNAL_ID AS GATE,
	c.ID||'#'||'GATE'||'#'||ups.EXTERNAL_ID AS QR_STRING,
	'https://webapi.se/qr-checkin/generate'|| chr(63)||'centerId='||c.id||'&resourceType=GATE&resourceId='||ups.EXTERNAL_ID AS QR_URL
FROM CENTERS c
LEFT JOIN USAGE_POINT_SOURCES ups 
	ON ups.CENTER = c.ID
LEFT JOIN USAGE_POINTS up
	ON ups.USAGE_POINT_CENTER = up.CENTER
	AND ups.USAGE_POINT_ID = up.ID
WHERE 
	ups.EXTERNAL_ID IS NOT NULL
ORDER BY CENTER
