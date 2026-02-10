-- The extract is extracted from Exerp on 2026-02-08
-- RG: Lists all active users with access to APIs
SELECT
	emp.center||'emp'||emp.id as EMPLOYEE_ID,
	emp.LAST_LOGIN,
	emp.PASSWD_EXPIRATION,
	p.center||'p'||p.id as PERSON_ID,
	p.firstname,
	p.lastname 
FROM	
    EMPLOYEES emp	
JOIN 	
	PERSONS p
	ON p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID	
WHERE 	
	emp.use_api = 1
AND	
	emp.blocked = 0
AND
	P.Center in (
	'76',
'29',
'30',
'437',
'33',
'34',
'35',
'27',
'36',
'421',
'405',
'38',
'438',
'40',
'39',
'47',
'48',
'12',
'51',
'9',
'955',
'56',
'954',
'57',
'59',
'415',
'2',
'60',
'61',
'422',
'452',
'15',
'6',
'68',
'69',
'410',
'16',
'71',
'75',
'953',
'425',
'408',
'4')

