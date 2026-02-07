SELECT
        p.center || 'p' || p.id AS personid,
        pea.txtvalue AS agileaid,
        ccc.startdate,
        ccc.currentstep,
        ccc.currentstep_type,
        ccc.currentstep_date
FROM puregym_switzerland.persons p
JOIN puregym_switzerland.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
LEFT JOIN puregym_switzerland.cashcollectioncases ccc ON p.center = ccc.personcenter AND p.id = ccc.personid AND ccc.missingpayment = 1 AND ccc.closed = false
