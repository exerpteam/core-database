-- The extract is extracted from Exerp on 2026-02-08
--  
WITH og_trans AS
( 
    SELECT
        p.center,
        p.id,
        art.amount,
        pag.clearinghouse_ref,
        art.text,
        art.status,
        art.unsettled_amount
    FROM vivagym.payment_agreements pag
    JOIN vivagym.payment_accounts pac ON pag.center = pac.center AND pag.id = pac.id
    JOIN vivagym.account_receivables ar ON ar.center = pac.center AND ar.id = pac.id
    JOIN vivagym.persons p ON p.center = ar.customercenter AND p.id = ar.customerid
    JOIN vivagym.ar_trans art ON art.center = ar.center AND art.id = ar.id
    WHERE
        pag.clearinghouse IN (4601,1)
        AND pag.clearinghouse_ref ~ '^([a-f0-9\-]{36}\|\d+|[a-f0-9]{40})$'
        AND pag.creation_time BETWEEN 1748908800000 AND 1748995140000
        AND art.text LIKE '%(Renovación automática)%'
        AND art.entry_time BETWEEN 1748991600000  AND 1748995140000 
		 
)
SELECT
    c.id AS center_id,
    c.name AS center_name,
    pea.txtvalue AS Legacy_id,
    p.center || 'p' || p.id AS person_id,
    (CASE WHEN pag.active = false THEN 'X' ELSE NULL END) AS is_agreement_updated,
    (CASE WHEN ot.center IS NULL THEN 'X' ELSE NULL END) AS no_renewal,
    (CASE WHEN ar.balance = 0 AND ot.amount < 0 THEN 'X' ELSE NULL END) AS has_member_paid,
    (CASE WHEN ar.balance != 0 AND ar.balance != ot.amount THEN 'X' ELSE NULL END) AS has_amount_changed,
    (CASE WHEN ot.amount = 0 THEN 'X' ELSE NULL END) AS is_original_amount_zero,
    (CASE WHEN p.external_id IS NULL THEN 'X' ELSE NULL END) AS person_has_been_transferred_review,
    ar.balance AS payment_account_balance,
    ot.amount AS amount_to_collect_provis
FROM vivagym.payment_agreements pag
JOIN vivagym.payment_accounts pac ON pag.center = pac.center AND pag.id = pac.id
JOIN vivagym.account_receivables ar ON ar.center = pac.center AND ar.id = pac.id
JOIN vivagym.persons p ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN vivagym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN vivagym.centers c ON p.center = c.id
LEFT JOIN og_trans ot ON ot.center = p.center AND ot.id = p.id
WHERE
    pag.clearinghouse IN (4601,1)
    and pag.clearinghouse_ref ~ '^([a-f0-9\-]{36}\|\d+|[a-f0-9]{40})$'
    AND pag.creation_time BETWEEN 1748908800000 AND 1748995140000
ORDER BY 2;
