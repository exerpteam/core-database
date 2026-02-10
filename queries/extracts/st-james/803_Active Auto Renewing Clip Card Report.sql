-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9905
WITH
    params AS
    (   SELECT
            CAST(datetolongTZ(TO_CHAR(to_date($$for_date$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), c.time_zone) AS BIGINT) AS fromDate,
            c.id                    AS centerid
        FROM
            centers c
        WHERE c.id IN ($$Scope$$)            
    )
SELECT
    pr.name                                                                        AS "Package Name",
    pe.external_id                                                                 AS "Member ID",
    pe.center||'p'||pe.id                                                          AS "Member P-id" ,
    TO_CHAR(longtodateC(i.entry_time,c.center), 'MM/DD/YYYY')                     AS "Invoice Transaction Datetime",
    TO_CHAR(longtodateC(i.trans_time,c.center), 'MM/DD/YYYY')                      AS "Book Datetime",
    TO_CHAR(longtodateC(c.valid_from,c.center),'MM/DD/YYYY')                       AS "Valid From",
    TO_CHAR(longtodateC(c.valid_until,c.center),'MM/DD/YYYY')                      AS "Expiration Date",
    s.center ||'ss'||s.id                                                          AS "Subscription ID",
    TO_CHAR(s.start_date,'MM/DD/YYYY')                                             AS "Subscription Start Date",
    TO_CHAR(s.end_date,'MM/DD/YYYY')                                               AS "Subscription End Date",
    il.total_amount                                                                AS "Original Balance",
    ROUND((c.clips_initial-c.clips_left) * (il.total_amount / c.clips_initial),2)  AS "Recognized Amount",
    ROUND(c.clips_left * (il .total_amount / c.clips_initial),2)                   AS "Deferred Amount",
    CASE
        WHEN c.finished
        THEN 'Expired'
        ELSE 'Active'
    END             AS "Package Status" ,
    c.clips_initial AS "Total Sessions",
    c.clips_left    AS "Sessions Remaining",
    st.PERIODCOUNT || ' per ' ||
    CASE
        WHEN st.PERIODUNIT = 0  THEN 'WEEK'
        WHEN st.PERIODUNIT = 1  THEN 'DAY'
        WHEN st.PERIODUNIT = 2  THEN 'MONTH'
        WHEN st.PERIODUNIT = 3  THEN 'YEAR'
    END    AS "INTERVAL",
    i.text AS "Description"
FROM
    subscriptions s
JOIN
    params
ON
    s.center = params.centerid        
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
AND st.st_type = 2 -- only PT Subscriptions
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    persons pe
ON
    pe.center = s.owner_center
AND pe.id = s.owner_id
LEFT JOIN
    subscriptionperiodparts spp
ON
    s.center = spp.center
    AND s.id = spp.id
    AND spp.spp_state = 1
    AND ($$for_date$$ BETWEEN spp.from_date AND spp.to_date)
LEFT JOIN
    spp_invoicelines_link link
ON
    link.period_center = spp.center
    AND link.period_id = spp.id
    AND link.period_subid = spp.subid
LEFT JOIN
    invoice_lines_mt il
ON
    link.invoiceline_center= il.center
AND link.invoiceline_id = il.id
AND link.invoiceline_subid = il.subid
LEFT JOIN
    invoices i
ON
    i.center = il.center
AND i.id = il.id    
LEFT JOIN
    clipcards c
ON
   c.invoiceline_center = il.center
   AND c.invoiceline_id = il.id        
   AND c.invoiceline_subid = il.subid
WHERE
   s.state  IN ($$Subscription_State$$)

