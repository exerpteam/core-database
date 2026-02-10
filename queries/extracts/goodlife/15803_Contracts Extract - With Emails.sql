-- The extract is extracted from Exerp on 2026-02-08
-- Use for logic app when contracts get created with Exerp, they should be sent with PDF copy of their agreement. This logic app will find out all the contract in the past day, download the PDF and send to Member.  Uses Export Schedules.

WITH
    PARAMS AS
    (
        SELECT
            ROUND(EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000) AS TODATE,
            ROUND(EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000) - (CAST(:OffsetDays AS BIGINT)*24*3600*1000) AS FROMDATE
    )
	
SELECT 
	CAST(j.Id as text) as JournalKey,	
	j.person_center,
	j.person_center || 'p' || j.person_id AS PersonID,	
	to_char(longtodatec(j.creation_time, j.person_center),'YYYY-MM-DD HH24:MI:SS') AS CreationDateTime,
	j.name,
	j.document_name,
	j.ref_globalid,
	j.ref_center,
	j.ref_id,
	j.ref_subid,
	email.txtvalue AS EmailAddress,
	p.external_Id
	 
FROM journalentries j
CROSS JOIN
	PARAMS
LEFT JOIN
	PERSON_EXT_ATTRS email
ON
	j.person_center = email.personcenter
AND 
	j.person_id = email.personid
AND 
	email.name = '_eClub_Email'
JOIN	--Retrieve ExternalId
    goodlife.persons p
ON
    p.center = j.person_center
AND 
    p.id = j.person_id
WHERE
	j.person_center IN ($$Scope$$)
AND
	j.creation_time >= PARAMS.FROMDATE
AND 
	j.creation_time <= PARAMS.TODATE 
AND
	(
        j.name = 'Customer contract'
    OR
	    j.name = 'Clipcard contract'
    )
AND
	(email.txtvalue IS NOT NULL OR email.txtvalue != '')
AND
	-- Filter out people who purchased at Corporate / Home Office
	j.ref_center NOT IN (870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 990)