SELECT DISTINCT
    op.center || 'p' || op.id                                                                                                                                                        AS OTHERPAYERID,
    DECODE (op.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                        AS OtherPayerPersonType,
    DECODE (op.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS OtherPayerPersonStatus,

op.firstname,
op.lastname,
op.address1,
op.address2,
op.address3,
op.zipcode,
op.city

FROM
    PERSONS p
JOIN
    RELATIVES op_rel
ON
    op_rel.RELATIVECENTER=p.CENTER
    AND op_rel.RELATIVEID=p.ID
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3
JOIN
    PERSONS op
ON
    op.CENTER = op_rel.CENTER
    AND op.ID = op_rel.ID
WHERE
    p.CENTER IN (403,
440,
436,
411,
441,
442,
419,
434,
407,
400,
406,
435,
401,
443
)
    AND op.center = 4