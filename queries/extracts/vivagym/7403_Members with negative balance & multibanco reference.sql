SELECT
        longtodatec(mbref.last_edit_time, mbref.personcenter) AS last_edited_time,
        p.center || 'p' || p.id AS personid,
        p.external_id,
        p.firstname,
        email.txtvalue AS email,
        (CASE p.STATUS
            WHEN 0 THEN 'LEAD'
            WHEN 1 THEN 'ACTIVE'
            WHEN 2 THEN 'INACTIVE'
            WHEN 3 THEN 'TEMPORARYINACTIVE'
            WHEN 4 THEN 'TRANSFERRED'
            WHEN 5 THEN 'DUPLICATE'
            WHEN 6 THEN 'PROSPECT'
            WHEN 7 THEN 'DELETED'
            WHEN 8 THEN 'ANONYMIZED'
            WHEN 9 THEN 'CONTACT'
            ELSE 'UNKNOWN'
        END) AS "Member Status",
        ch.name AS clearinghouse_name,
        ccc.amount AS cash_collection_amount,
        ccc.startdate AS cash_collection_start_date,
        ccc.currentstep AS cash_collection_current_step,
        mbref.txtvalue AS Multibanco_reference,
        mbamt.txtvalue AS MultiBanco_amount,
        mbentity.txtvalue AS MultiBanco_entity
FROM vivagym.persons p
JOIN vivagym.centers c ON p.center = c.id AND c.country = 'PT'
JOIN vivagym.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid 
JOIN vivagym.person_ext_attrs mbref ON p.center = mbref.personcenter AND p.id = mbref.personid AND mbref.name = 'MBREF' AND mbref.txtvalue IS NOT NULL
JOIN vivagym.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
LEFT JOIN vivagym.person_ext_attrs mbamt ON p.center = mbamt.personcenter AND p.id = mbamt.personid AND mbamt.name = 'MBAMT' AND mbamt.txtvalue IS NOT NULL
LEFT JOIN vivagym.person_ext_attrs mbentity ON p.center = mbentity.personcenter AND p.id = mbentity.personid AND mbentity.name = 'MBENTITY' AND mbentity.txtvalue IS NOT NULL
LEFT JOIN vivagym.person_ext_attrs email ON p.center = email.personcenter AND p.id = email.personid AND email.name = '_eClub_Email' AND email.txtvalue IS NOT NULL
LEFT JOIN vivagym.payment_agreements pag ON pag.center = pac.active_agr_center AND pag.id = pac.active_agr_id AND pag.subid = pac.active_agr_subid
LEFT JOIN vivagym.clearinghouses ch ON pag.clearinghouse = ch.id
LEFT JOIN vivagym.cashcollectioncases ccc ON ccc.personcenter = p.center AND ccc.personid = p.id AND ccc.closed = 0 AND ccc.missingpayment = 1
WHERE
        ar.ar_type = 4
        AND ar.balance < 0
        AND p.center IN (:Scope)
		AND p.STATUS != 2