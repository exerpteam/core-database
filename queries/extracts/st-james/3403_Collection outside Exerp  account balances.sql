SELECT
        pea.txtvalue AS legacy_id,
        p.external_id,
        p.center || 'p' || p.id AS personId,
        p.fullname,
        ar.balance,
        longToDateC(art.entry_time, art.center) AS trans_entrytime,
        art.unsettled_amount,
        art.text
FROM stjames.persons p
JOIN stjames.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN stjames.ar_trans art ON ar.center = art.center AND ar.id = art.id
LEFT JOIN stjames.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
WHERE
        art.status NOT IN ('CLOSED')
ORDER BY
        2