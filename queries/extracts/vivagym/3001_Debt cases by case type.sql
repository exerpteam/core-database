SELECT
    ccc.personcenter || 'p' || ccc.personid AS personkey,
    c.shortname AS Center,
	ccc.startdate AS Open_case,
    (
        CASE
            WHEN ccc.missingpayment = false 
            THEN 'MISSING_AGREEMENT'
            ELSE 'DEBT_CASE'
        END) Case_type,
    ar.balance,
    pea.txtvalue AS Phone,
    ch.name as Clearing_house,
    (
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
        END) AS "Member Status",
	CASE
		WHEN p.blacklisted = 0 THEN 'NONE'
		WHEN p.blacklisted = 1 THEN 'BLACKLISTED'
		WHEN p.blacklisted = 2 THEN 'SUSPENDED'
		WHEN p.blacklisted = 3 THEN 'BLOCKED'
	END AS Substatus
FROM
    cashcollectioncases ccc
JOIN
    vivagym.account_receivables ar
ON
    ar.customercenter = ccc.personcenter
AND ar.customerid = ccc.personid
AND ar.ar_type = 4
JOIN
    vivagym.persons p
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
JOIN
        vivagym.centers c
        ON p.center = c.id
LEFT JOIN
        vivagym.person_ext_attrs pea
        ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_PhoneSMS'
LEFT JOIN
    vivagym.payment_accounts paa
ON
    ar.center = paa.center
AND ar.id = paa.id
LEFT JOIN
    vivagym.payment_agreements pag
ON
    paa.active_agr_center = pag.center
AND paa.active_agr_id = pag.id
AND paa.active_agr_subid = pag.subid
LEFT JOIN
	vivagym.clearinghouses ch
ON
	ch.id = pag.clearinghouse
WHERE
    ccc.closed = False
	AND ccc.personcenter IN (:scope)