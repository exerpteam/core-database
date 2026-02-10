-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT pea.PERSONCENTER || 'p' || pea.PERSONID as ExerpId, pea.TXTVALUE as OldId
FROM PERSON_EXT_ATTRS pea
WHERE pea.NAME = '_eClub_OldSystemPersonId'
AND pea.TXTVALUE IN ($$oldIds$$)