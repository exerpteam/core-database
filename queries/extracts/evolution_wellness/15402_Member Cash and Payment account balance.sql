-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
        params AS
        (
        SELECT
                /*+ materialize */
                datetolongC(TO_CHAR(CAST(:Cutdate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS CutDate,
                c.id AS CENTER_ID
        FROM
                centers c
        ),
        account_art AS
        (
        SELECT 
                art.center
                ,art.id
                ,SUM(art.amount) AS Balance
        FROM
                evolutionwellness.ar_trans art
        JOIN
                params
                ON params.center_id = art.center                
        WHERE                
                art.entry_time < params.CutDate
        GROUP BY
                art.center
                ,art.id
        )                                    
SELECT
        p.center||'p'||p.id AS PersonID
        ,p.external_id AS ExternalID
        ,p.fullname AS MemberName
        ,c.id AS ClubID
        ,c.name AS ClubName
        ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
        ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PersonStatus
        ,arp.balance AS CurrentPaymentAccountBalance
        ,arc.balance AS CurrentCashAccountBalance
        ,longtodatec(params.cutdate,p.center)::date AS Cutoffdate
        ,part.balance AS "PaymentAccountBalance cutoffdate"
        ,cart.balance AS "CashAccountBalance cutoffdate"
FROM
        evolutionwellness.persons p
JOIN
        evolutionwellness.centers c
        ON c.id = p.center
JOIN
        params
        ON params.center_id = c.id                
LEFT JOIN
        evolutionwellness.account_receivables arp                        
        ON arp.customercenter = p.center
        AND arp.customerid = p.id
        AND arp.ar_type = 4
LEFT JOIN
        evolutionwellness.account_receivables arc                        
        ON arc.customercenter = p.center
        AND arc.customerid = p.id
        AND arc.ar_type = 1
LEFT JOIN
        account_art part
        ON part.center = arp.center
        AND part.id = arp.id 
LEFT JOIN
        account_art cart
        ON cart.center = arc.center
        AND cart.id = arc.id              
WHERE
        p.external_id IS NOT NULL
        AND
        p.center IN (:Scope)
        AND
        p.status IN (1,2,3)
        AND
        p.PERSONTYPE IN (:PersonType)  