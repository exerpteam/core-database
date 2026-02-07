SELECT
        p.center || 'p' || p.id AS personid,
        c.name AS centerName,
        c.id,
        s.center || 'ss' || s.id AS subscriptionid,
        s.start_date,
        s.billed_until_date,
        s.end_date,
        pr.name AS productname,
        pag.clearinghouse_ref,
        length(pag.clearinghouse_ref) as token_length,
        ch.name AS clearinghouseName,
        ch.id,
        pag.subid
FROM vivagym.persons p
JOIN vivagym.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
JOIN vivagym.centers c ON p.center = c.id
JOIN vivagym.products pr ON s.subscriptiontype_center = pr.center AND s.subscriptiontype_id = pr.id
JOIN vivagym.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN vivagym.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN vivagym.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
JOIN vivagym.clearinghouses ch ON pag.clearinghouse = ch.id 
WHERE
        s.state IN (2,4,8)
        AND s.is_change_restricted = true
        AND (ch.id NOT IN (4001,4201) OR pag.subid != 1)