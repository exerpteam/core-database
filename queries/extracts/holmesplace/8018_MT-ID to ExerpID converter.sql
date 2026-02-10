-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pea.TXTVALUE,
    pea.PERSONCENTER||'p'||pea.PERSONID
FROM
    HP.PERSON_EXT_ATTRS pea
WHERE
    pea.NAME = '_eClub_OldSystemPersonId'
    and pea.TXTVALUE in ($$Old_Member_Ids$$)