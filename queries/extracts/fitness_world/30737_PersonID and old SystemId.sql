-- This is the version from 2026-02-05
--  
SELECT
    p.CENTER || 'p' || p.ID as PERSONKEY,
    e.TXTVALUE
FROM
    FW.PERSONS p
JOIN
    FW.PERSON_EXT_ATTRS e
ON
    p.CENTER = e.PERSONCENTER
    AND p.ID = e.PERSONID
    AND e.NAME = '_eClub_OldSystemPersonId'
WHERE
    e.TXTVALUE IN (:oldmemberid)