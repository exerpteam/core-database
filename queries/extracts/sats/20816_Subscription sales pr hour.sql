SELECT
    COUNT(Sub.center||'ss'||sub.id) AS subscription_count,
    Sub.InvoiceLine_Center          AS Center,
    TO_CHAR(longtodate(inv.entry_time),'HH24') sales_time,
    TO_CHAR(longtodate(inv.entry_time),'YYYY-MM-DD') sales_date
FROM
    sats.Subscriptions sub
JOIN sats.InvoiceLines ivl
ON
    Sub.InvoiceLine_Center = ivl.Center
AND Sub.InvoiceLine_Id = ivl.Id
AND Sub.InvoiceLine_SubId = ivl.SubId
JOIN sats.invoices inv
ON
    ivl.center = inv.center
AND ivl.id = inv.id
JOIN sats.subscription_sales ss
ON
    sub.center = ss.subscription_center
AND sub.id = ss.subscription_id
WHERE
    inv.entry_time >= :date_from
and inv.entry_time <= :date_to + 86400000
AND Sub.InvoiceLine_Center in (:scope)
AND ss.type = 1 -- new sales
GROUP BY
    Sub.InvoiceLine_Center,
    TO_CHAR(longtodate(inv.entry_time),'HH24'),
	TO_CHAR(longtodate(inv.entry_time),'YYYY-MM-DD')
ORDER BY
    Sub.InvoiceLine_Center,
	TO_CHAR(longtodate(inv.entry_time),'YYYY-MM-DD'),
    TO_CHAR(longtodate(inv.entry_time),'HH24')