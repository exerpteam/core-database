SELECT 
	per.EXTERNAL_ID AS ExterntId,
	per.CENTER ||'p' || per.ID AS Medlemsnummer,
	per.FULLNAME AS Namn,
	TO_CHAR(LONGTODATE(MAX(checkins.CHECKIN_TIME)),'YYYY-MM-DD') AS SenasteCheckin
FROM PERSONS per
LEFT JOIN CHECKINS checkins
	ON checkins.PERSON_CENTER = per.CENTER
	AND checkins.PERSON_ID = per.ID
WHERE 
	per.CENTER = :center
	AND per.STATUS = 1
	AND	checkins.CHECKIN_TIME > :last_checkin_date
	AND per.EXTERNAL_ID NOT IN (
		SELECT p.EXTERNAL_ID
			FROM PERSONS p
			JOIN PERSON_EXT_ATTRS pe ON
			p.CENTER = pe.PERSONCENTER AND
			p.ID = pe.PERSONID
			LEFT JOIN PERSON_EXT_ATTRS pea ON
			p.CENTER = pea.PERSONCENTER AND
			p.ID = pea.PERSONID AND
			pea.NAME = '_eClub_Email'	
		WHERE
			pe.NAME = 'TWIIKID'
			AND p.CENTER = :center
			AND p.STATUS = 1
)
GROUP BY 
	per.EXTERNAL_ID,
	per.CENTER,
	per.ID,
	per.FULLNAME
	

