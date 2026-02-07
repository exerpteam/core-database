SELECT DISTINCT
    per.center || 'p' || per.id          AS "Member Id",
    per.external_id                      AS "External Id",
    per.fullname                         AS "Full Name",
    email.txtvalue                       AS "Email Address",
    mobile.txtvalue                      AS "Phone Number",
    ccc.amount                           AS "Debt Amount",
    TO_CHAR(ccc.startdate, 'YYYY-MM-DD') AS "Debt Case Start Date",
    CASE
        WHEN r.center IS NOT NULL
        THEN 'Y'
        ELSE 'N'
    END AS "Pays For Others"
FROM
    cashcollectioncases ccc
JOIN
    PERSONS per
ON
    per.center = ccc.personcenter
    AND per.id = ccc.personid
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    per.center=email.PERSONCENTER
    AND per.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    per.center=mobile.PERSONCENTER
    AND per.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    relatives r
ON
    r.center = per.center
    AND r.id = per.id
    AND r.rtype = 12
    AND r.status < 3
WHERE
    ccc.personcenter IN ($$Scope$$)
    AND ccc.missingpayment = 1
    AND ccc.closed = 0
	AND ccc.cashcollectionservice is null
	AND ccc.currentstep_type = -1