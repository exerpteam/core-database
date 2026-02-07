SELECT
        p.CENTER || 'p' || p.ID AS PersonId,
        substr(pea.TXTVALUE,4) AS fdk_personid,
        c.CENTER || 'cc' || c.ID || 'id' || c.SUBID AS ClipcardId,
        c.CLIPS_INITIAL,
        c.CLIPS_LEFT,
        pd.GLOBALID AS OldClipcardTypeId,
        pd.NAME AS OldClipcardTypeName,
        c.CANCELLED
FROM SATS.PERSONS p
JOIN SATS.PERSON_EXT_ATTRS pea ON p.CENTER = pea.PERSONCENTER AND p.ID = pea.PERSONID AND pea.NAME = '_eClub_OldSystemPersonId'
JOIN SATS.CLIPCARDS c ON p.CENTER = c.OWNER_CENTER AND p.ID = c.OWNER_ID
JOIN SATS.CLIPCARDTYPES ct ON ct.center = c.CENTER AND ct.ID = c.ID
JOIN SATS.PRODUCTS pd ON pd.CENTER = ct.CENTER AND pd.ID = ct.ID
WHERE
        pea.TXTVALUE LIKE 'fdk%'
        AND c.CC_COMMENT LIKE 'LegacyClipcardId%'