-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2979
SELECT
    p.center || 'p' || p.id             AS "Person ID",
    p.center                            AS "Center Id",
    il.text                             AS "Description",
    ROUND(il.net_amount,2)              AS "Payment Price Amount (Pre Tax)",
    (ROUND(il.total_amount,2) - ROUND(il.net_amount,2)) AS "Payment Tax Amount",
    p.fullname                          AS "Person Full Name",
    TO_CHAR(longtodateC(i.TRANS_TIME, 100), 'YYYY-MM-dd HH24:MI') AS "Transaction Date",
    TO_CHAR(spp.from_date, 'YYYY-MM-dd')                       AS "Period From",
    TO_CHAR(spp.to_date, 'YYYY-MM-dd')                         AS "Period To",
    i.Payer_center || 'p' || i.payer_id AS "Payer ID"  
FROM
    persons p
JOIN
    invoice_lines_mt il
ON
    p.id = il.person_id AND p.center = il.person_center
JOIN
    INVOICES i
ON
    il.center = i.center
    AND il.id = i.id
JOIN 
    spp_invoicelines_link sppl
ON 
    il.center = sppl.invoiceline_center 
    AND il.id = sppl.invoiceline_id 
    AND il.subid = sppl.invoiceline_subid
JOIN 
    subscriptionperiodparts spp
ON
    spp.center = sppl.period_CENTER 
    AND spp.id = sppl.period_id 
    AND spp.subid = sppl.period_subid    
WHERE
        p.center || 'p' || p.id = $$PersonId$$
        AND i.TRANS_TIME BETWEEN CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
        AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 
UNION ALL
SELECT
    CASE
        WHEN p.SEX <> 'C'
        THEN  p.center || 'p' || p.id
        ELSE NULL
    END "PERSON_ID",
    cl.CENTER                                         "CENTER_ID",
    cl.text,
    -ROUND(cl.net_amount,2)                          AS "NET_AMOUNT",
    -ROUND(cl.TOTAL_AMOUNT,2)+ROUND(cl.net_amount,2) AS "VAT_AMOUNT",
    p.fullname,
    TO_CHAR(longtodateC(c.TRANS_TIME, 100), 'YYYY-MM-dd HH24:MI') AS "Transaction Date",
    ''        AS "Period From",
    ''        AS "Period To",
    ''        AS "Payer ID"  
FROM
    CREDIT_NOTES c
JOIN
    credit_note_lines_mt cl
ON
    cl.center = c.center
    AND cl.id = c.id
LEFT JOIN
    PERSONS p
ON
    p.center = cl.PERSON_CENTER
    AND p.ID = cl.PERSON_ID
WHERE    
        p.center || 'p' || p.id = :PersonId
        AND c.TRANS_TIME BETWEEN CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
        AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 

