SELECT
    CASE
        WHEN p.center IS NOT NULL
        THEN p.CENTER || 'p' || p.ID
        ELSE NULL
    END ExerpId,
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "Person Status",
    CASE p.persontype
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END          AS "PersonType" ,
    pea.TXTVALUE AS LegacyPersonId,
    CASE pag.state
        WHEN 1
        THEN 'CREATED'
        WHEN 2
        THEN 'SENT'
        WHEN 4
        THEN 'OK'
        WHEN 10
        THEN 'ENDED BY CREDITOR'
        WHEN 6
        THEN 'ENDED BY CLEARING HOUSE'
        WHEN 13
        THEN 'INVOICE PAYMENT AGREEMENT'
        WHEN 14
        THEN 'INCOMPLETE PAYMENT AGREEMENT INFO'
        ELSE '' ||pag.state
    END AS "Payment Agreement State"
FROM
    persons p
LEFT JOIN
    person_ext_attrs pea
ON
    pea.NAME='_eClub_OldSystemPersonId'
    AND pea.personcenter = p.center
    AND pea.personid = p.id
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER=p.center
    AND ar.CUSTOMERID=p.id
    AND ar.AR_TYPE=4
LEFT JOIN
    payment_agreements pag
ON
    ar.center = pag.center
    AND ar.id = pag.id
    AND pag.active = 1
WHERE
    p.center IN (612,
                 613)