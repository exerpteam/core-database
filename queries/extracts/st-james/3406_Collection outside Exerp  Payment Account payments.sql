WITH params AS
(
        SELECT
                datetolongc(to_char(TO_DATE('2025-10-21','YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS cutdate,
                c.id
        FROM stjames.centers c
)
SELECT
        longtodatec(art.entry_time, art.center) AS art_entrytime,
        pea.txtvalue AS legacy_id,
        p.external_id,
        p.center || 'p' || p.id AS personId,
        p.fullname,        
        art.amount,
        art.text
FROM stjames.persons p
JOIN stjames.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN params par ON p.center = par.id
JOIN stjames.account_receivables ar ON p.center = ar.customercenter AND p.id = Ar.customerid
JOIN stjames.ar_trans art ON ar.center = art.center AND ar.id = Art.id
WHERE
        ar.ar_type = 4
        AND art.amount > 0
        AND art.ref_type NOT IN ('CREDIT_NOTE')
        AND art.entry_time > par.cutdate
        AND (art.employeecenter, art.employeeid) NOT IN ((100,1))
        AND art.TEXT NOT LIKE ('Automatic placement%')
ORDER BY 1