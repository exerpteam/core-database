-- This is the version from 2026-02-05
--  
SELECT DISTINCT
    person.CENTER,
    person.ID,
    person.FULLNAME
FROM
    PERSONS person
LEFT JOIN RELATIVES rel
ON
    person.CENTER = rel.RELATIVECENTER
AND person.ID = rel.RELATIVEID
AND rel.RTYPE = 2
LEFT JOIN PERSONS company
ON
    company.CENTER = rel.CENTER
AND company.ID = rel.ID
LEFT JOIN RELATIVES companyAgrRel
ON
    person.CENTER = companyAgrRel.CENTER
AND person.ID = companyAgrRel.ID
AND companyAgrRel.RTYPE = 3
LEFT JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = companyAgrRel.RELATIVECENTER
AND ca.ID = companyAgrRel.RELATIVEID
AND ca.SUBID = companyAgrRel.RELATIVESUBID
WHERE
    ca.center = 116
AND ca.id = 16122
AND ca.subid = 1
AND person.status <> 2
AND NOT EXISTS
    (
        SELECT
            *
        FROM
            INVOICES I
        JOIN INVOICELINES IL
        ON
            I.CENTER=IL.CENTER
        AND I.ID=IL.ID
        JOIN products p
        ON
            il.productcenter = p.center
        AND il.productid = p.id
        WHERE
            p.GLOBALID = 'SERVICE_FEE'
        AND I.trans_time BETWEEN datetolong('2010-02-01 00:00') AND
datetolong('2010-02-28 23:59')
        AND i.person_center = person.center
        AND i.person_id = person.id
    )