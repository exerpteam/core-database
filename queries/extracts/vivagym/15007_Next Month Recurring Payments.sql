-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months')AS fromDate,
                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 days' toDate,
                CAST(dateToLongC(TO_CHAR(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')),'YYYY-MM-DD'),c.id) AS BIGINT) AS fromDateLong,
                CAST(dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD'),'YYYY-MM-DD'),c.id)-1 AS BIGINT) AS toDateLong,
                c.id AS center_id,
                c.name as center_name
        FROM 
                vivagym.centers c
        WHERE
                c.country = 'ES'      
)
SELECT
        p.center || 'p' || p.id AS personid,
        p.fullname,
        CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' 
                          WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' 
                          WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS persontype,
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' 
                      WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' 
                      ELSE 'Undefined' END AS person_status,
        pr.name AS product_name,
        spp.from_date,
        spp.to_date,
        spp.subscription_price,
        spp.addons_price,
        il.total_amount invoice_line_total_amount,
        il.text AS invoice_text
FROM vivagym.invoices i
JOIN params par ON i.center = par.center_id
JOIN vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
JOIN vivagym.spp_invoicelines_link spl ON spl.invoiceline_center = il.center AND spl.invoiceline_id = il.id AND spl.invoiceline_subid = il.subid
JOIN vivagym.subscriptionperiodparts spp ON spl.period_center = spp.center AND spl.period_id = spp.id AND spl.period_subid = spp.subid
JOIN vivagym.subscriptions s ON spp.center = s.center AND spp.id = s.id
JOIN vivagym.persons p ON s.owner_center = p.center AND s.owner_id = p.id
JOIN vivagym.products pr ON s.subscriptiontype_center = pr.center AND s.subscriptiontype_id = pr.id
WHERE 
        i.entry_time between par.fromDateLong AND par.toDateLong
        AND spp.cancellation_time = 0
        AND spp.to_date >= par.fromDate