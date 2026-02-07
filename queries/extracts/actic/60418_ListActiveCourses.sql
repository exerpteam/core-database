/*
* Extrakt to fetch upcoming bookings (two hours from now).
* These should be sent as reminders in ActicApp.
* Creator: Henrik Håkanson
*/ 

SELECT 
	p.CENTER,
	p.ID,
	p.CENTER ||'p'||p.ID,
	activecourse.TXTVALUE
	
FROM PERSONS p
JOIN PERSON_EXT_ATTRS activecourse ON
	activecourse.PERSONCENTER = p.CENTER
	AND activecourse.PERSONID = p.ID
	AND activecourse.NAME = 'ACTIVECOURSE'
WHERE 
	activecourse.TXTVALUE = 'true'		
GROUP BY 
	p.CENTER,
	p.ID,
	activecourse.TXTVALUE
