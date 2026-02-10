-- The extract is extracted from Exerp on 2026-02-08
-- RG 23.09.25 - Created for INC-333194 to find the member a Vitality enitity number matches to
SELECT 
    per.center || 'p' || per.id AS "Member ID",
    (SELECT pea.TXTVALUE
     FROM PERSON_EXT_ATTRS pea
     WHERE pea.PERSONCENTER = per.CENTER
       AND pea.PERSONID = per.ID
       AND pea.NAME = '_eClub_PBLookupPartnerPersonId'
       AND pea.TXTVALUE = :entity
     LIMIT 1) AS Partner_Benefit_Value,
    (SELECT pea.TXTVALUE
     FROM PERSON_EXT_ATTRS pea
     WHERE pea.PERSONCENTER = per.CENTER
       AND pea.PERSONID = per.ID
       AND pea.NAME = 'VITENT'
       AND pea.TXTVALUE = :entity
     LIMIT 1) AS Extended_Attribute_Value
FROM persons per
WHERE EXISTS (
    SELECT 1
    FROM PERSON_EXT_ATTRS pea
    WHERE pea.PERSONCENTER = per.CENTER
      AND pea.PERSONID = per.ID
      AND pea.NAME IN ('_eClub_PBLookupPartnerPersonId','VITENT')
      AND pea.TXTVALUE = :entity
);