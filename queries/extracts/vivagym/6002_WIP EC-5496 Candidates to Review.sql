WITH params AS MATERIALIZED
(
        SELECT
                c.id AS center_id
        FROM
                vivagym.centers c
        WHERE
                c.country = 'PT'
)
SELECT
        p.center,
        p.id,
		p.center || 'p' || p.id AS PersonId,
        art.amount,
        art.text,
        art.unsettled_amount,
        art.status,
        art.entry_time,
		sum(il.net_amount) AS net_amount,
        --prod.external_id,
		ch.name
FROM vivagym.persons p
JOIN params par ON p.center = par.center_id
JOIN vivagym.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid 
JOIN vivagym.ar_trans art ON ar.center = art.center AND ar.id = art.id
JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id
JOIN vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
JOIN vivagym.products prod ON il.productcenter = prod.center AND il.productid = prod.id
JOIN vivagym.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
join vivagym.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
JOIN vivagym.clearinghouses ch ON ch.id = pag.clearinghouse
WHERE
        -- Exclude Companies
        p.sex != 'C'
        -- Only transactions on the Payment Account
        AND ar.ar_type = 4
        -- Only transactions that have not been collected before
        AND art.collected = 0
        -- Only include transactions that are NEW or OPEN (partially paid)
        AND art.status NOT IN ('CLOSED')
        -- Only look at negative transactions coming from an Invoice
        AND art.ref_type = 'INVOICE'
        -- Only check those transactions that are not free
        AND art.amount < 0
        -- Include only Clipcards, Creation (Joining) and Prorrata product
        AND prod.ptype IN (4,5,12)
        -- Include only clearinghouses EasyPayCC and EasyPaySEPA
        AND pag.clearinghouse IN (401,601)
GROUP BY
		p.center,
        p.id,
        art.amount,
        art.text,
        art.unsettled_amount,
        art.status,
        art.entry_time,
        --prod.external_id,
        ch.name

        