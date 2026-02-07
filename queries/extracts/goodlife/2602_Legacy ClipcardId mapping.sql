SELECT
        p.center || 'p' || p.id AS "ExerpPersonId",
        pea.txtvalue AS "LegacyPersonId",
        c.center || 'cc' || c.id || 'id' || c.subid  "ExerpClipcardId",
        substring(c.cc_comment FROM 'LegacyClipcardId:(.+' || CHR(63) || ')' || CHR(13)) AS "LegacyClipcardId",
        substring(c.cc_comment FROM 'PTContractNo:(.+' || CHR(63) || ')' || CHR(13)) AS "PTContractNo"
        
FROM persons p
JOIN clipcards c
        ON p.center = c.owner_center AND p.id = c.owner_id
JOIN person_ext_attrs pea
        ON p.center = pea.personcenter AND p.id = pea.personid AND pea.NAME = '_eClub_OldSystemPersonId'
WHERE
        p.center in (:scope)
        AND c.cc_comment LIKE 'LegacyClipcardId: %'