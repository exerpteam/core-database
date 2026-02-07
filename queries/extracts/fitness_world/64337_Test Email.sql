-- This is the version from 2026-02-05
--  
Select p.CENTER,
p.ID,
pea.NAME,
pea.txtvalue
from persons p
Left join PERSON_EXT_ATTRS PEA ON PEA.PERSONCENTER = 
        P.CENTER AND PEA.PERSONID = P.ID 
WHERE pea.name in ('_eClub_Email','_eClub_OldEmail')
AND (pea.txtvalue like '_')