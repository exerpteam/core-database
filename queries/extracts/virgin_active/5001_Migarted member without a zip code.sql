SELECT
    p.CENTER || 'p' || p.ID pid,
    nvl2(rel.CENTER,1,0 )   is_other_payer,
    atts.TXTVALUE           old_system_id,
    p.FULLNAME,
    p.ZIPCODE,
    p.CITY,
DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE
FROM
    PERSONS p
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER
    AND rel.id = p.id
    AND rel.STATUS = 1
    AND rel.RTYPE = 12
LEFT JOIN
    PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = p.CENTER
    AND atts.PERSONID = p.ID
    AND atts.NAME = '_eClub_OldSystemPersonId'
WHERE
    p.ZIPCODE IS NULL
    AND p.STATUS NOT IN (4,5,7,8)
    