-- The extract is extracted from Exerp on 2026-02-08
-- This extracts returns all members with journal notes created when an Energy Cardio punch card has been given.
SELECT 
  je.person_center||'p'||je.person_id AS PersonID
, p.external_id as ExternalID
, p.FirstName
, p.LastName
, p.center as HomeClub
, je.creatorcenter||'p'||je.creatorid As JournalNoteCreator
, je.name AS JournalNoteText
, TO_CHAR(longtodatec(je.creation_time, 100), 'YYYY-MM-DD HH24:MI') 
AS CreationDate
FROM journalentries je
	JOIN persons p
		ON je.person_center = p.center
		AND je.person_id = p.id
WHERE name like '%energy cardio%' or name like '%punch card%'