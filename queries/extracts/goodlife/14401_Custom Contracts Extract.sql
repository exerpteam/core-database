SELECT 
	j.person_center,
	j.person_center || 'p' || j.person_id AS PersonID,
	to_char(longtodatec(j.creation_time, j.person_center),'YYYY-MM-DD HH24:MI:SS') AS CreationDateTime,
	j.name,
	j.document_name,
	email.txtvalue AS EmailAddress
	 
FROM journalentries j
LEFT JOIN
	PERSON_EXT_ATTRS email
ON
	j.person_center = email.personcenter
AND 
	j.person_id = email.personid
AND 
	email.name = '_eClub_Email'
-- Return Contracts
WHERE
	j.person_center IN ($$Scope$$)
AND
	j.creation_time >= dateToLongC(to_char(to_date(:Start_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'),j.person_center) 
AND 
	j.creation_time <= dateToLongC(to_char(to_date(:End_Date,'YYYY-MM-DD'),'YYYY-MM-DD HH24:MI:SS'),j.person_center) 
AND
	(j.name = 'Customer contract'
OR
	j.name = 'Clipcard contract')