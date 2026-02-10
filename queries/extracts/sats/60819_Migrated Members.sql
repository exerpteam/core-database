-- The extract is extracted from Exerp on 2026-02-08
-- This extract show migrated member person id in SATS and from legacy system.
 SELECT
     pe.personcenter || 'p' || pe.personid AS SATSPersonId,
     pe.txtvalue                           AS MigratedPersonId,
     REPLACE(pe.txtvalue, :migrationCode, '')        AS LegacyPersonId
 FROM
     person_ext_attrs pe
 WHERE
     pe.name = '_eClub_OldSystemPersonId'
     AND pe.personcenter IN ($$Scope$$)
