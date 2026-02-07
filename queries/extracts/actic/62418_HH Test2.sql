/**
* List all members that became inactive last month.
* Scheduled to send members to municipalities for deletion.
* Created by: Henrik Håkanson
*/
SELECT 
	p.CENTER || 'p' || p.ID as personKey,
	p.FULLNAME,
	s.END_DATE
FROM 
	PERSONS p 
JOIN SUBSCRIPTIONS s ON
	p.CENTER = s.OWNER_CENTER
	AND p.ID = s.OWNER_ID
WHERE 
	s.END_DATE >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
	AND s.END_DATE <  DATE_TRUNC('month', CURRENT_DATE)
	AND p.STATUS = 2
	AND p.CENTER = :center