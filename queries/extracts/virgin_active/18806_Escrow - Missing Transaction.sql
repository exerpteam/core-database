WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                      AS FromDate,
            $$EndDate$$                        AS ToDate            
        FROM
            dual
    )
SELECT distinct
    c.id                                    AS "Club Id",
    c.name                                  AS "Club Name",
    p.center || 'p' || p.id                 AS PERSONID,
    longToDateC(art.entry_time, art.center) AS ENTRYTIME,
    art.text                                AS TEXT,
    art.due_date                            AS DUEDATE,
    CASE
        WHEN art.amount > 0
        THEN art.amount
    END                                     AS DEPOSIT,
    CASE
        WHEN art.amount < 0
        THEN art.amount
    END                                     AS WITHDRAWN,
    ar.balance                              AS ACCOUNT_BALANCE 
FROM params
CROSS JOIN
    PERSONS p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.customercenter = p.center
    AND ar.customerid = p.id
    AND ar.ar_type = 4

JOIN    
    AR_TRANS art
ON
    art.center = ar.CENTER
    AND art.id = ar.id
    AND art.entry_time BETWEEN params.FromDate AND params.ToDate
    AND ((
            art.REF_TYPE = 'ACCOUNT_TRANS'
            AND art.text not like ('Transfer to cash collection account%')
            AND art.text not like ('Balance trans%')
            AND art.text not like ('%Collstream%')
            AND UPPER(art.text) not like ('%TRANSFER%'))
        OR (
            art.REF_TYPE = 'INVOICE'
            AND art.text like ('%(Auto Renewal)%')))
JOIN
    CENTERS c
ON
    c.ID = p.center
WHERE (p.center, p.id) IN   
((451,21003),
(28,2197),
(14,1812),
(26,4494),
(19,3004))
