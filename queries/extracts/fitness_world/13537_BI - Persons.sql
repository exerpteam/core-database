-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center || 'p' || p.id AS MemberId,
    p.center                AS Center,
    p.FULLNAME,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ZIPCODE,
    p.CITY,
    p.BIRTHDATE,
    p.sex AS GENDER,
    CASE
        WHEN ces.LASTUPDATED IS NOT NULL
        THEN 'Y'
        ELSE 'N'
    END AS Imported,
    CASE
        WHEN ces.LASTUPDATED IS NOT NULL
        THEN TO_CHAR(ces.LASTUPDATED, 'YYYY-MM-DD')
        ELSE ''
    END AS ImportedDate,
    CASE
        WHEN pea.TXTVALUE IS NOT NULL
        THEN 'Y'
        ELSE 'N'
    END AS Transferred,
    CASE
        WHEN pea.TXTVALUE IS NOT NULL
        THEN pea.TXTVALUE
        ELSE ''
    END                 AS TransferredTo,
    pea_trdate.TXTVALUE AS TransferredDate,
    fitnfab.TXTVALUE as fitnfab
FROM
    persons p
LEFT JOIN
    FW.CONVERTER_ENTITY_STATE ces
ON
    ces.NEWENTITYCENTER = p.center
    AND ces.NEWENTITYID = p.id
    AND ces.WRITERNAME = 'ClubLeadPersonWriter'
LEFT JOIN
    FW.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
    AND pea.PERSONID = p.id
    AND pea.name = '_eClub_TransferredToId'
LEFT JOIN
    FW.PERSON_EXT_ATTRS pea_trdate
ON
    pea_trdate.PERSONCENTER = p.center
    AND pea_trdate.PERSONID = p.id
    AND pea_trdate.name = '_eClub_TransferDate'
LEFT JOIN
    FW.PERSON_EXT_ATTRS fitnfab
ON
    fitnfab.PERSONCENTER = p.CENTER
    AND fitnfab.PERSONID = p.id
    AND fitnfab.NAME = 'event_fitnfab'
    and fitnfab.TXTVALUE is not null
WHERE
    p.center IN ($$scope$$)
    AND p.sex != 'C'