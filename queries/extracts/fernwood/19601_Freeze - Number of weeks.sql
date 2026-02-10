-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t.name as clubname
        ,sum(t.numberofweeks)
        ,t.type
FROM
        (SELECT
                c.name
                ,(sf.end_date - sf.start_date)/7 as numberofweeks
                ,sf.type
        FROM
                persons p
        JOIN
                subscriptions s
                ON p.center = s.owner_center
                AND p.id = s.owner_id
        JOIN
                subscription_freeze_period sf
                ON sf.subscription_center = s.center
                AND sf.subscription_id = s.id
                AND sf.state != 'CANCELLED'
        JOIN
                centers c 
                ON c.id = p.center
        WHERE
                sf.start_date BETWEEN :From AND :To
                AND
                p.center in (:Scope)                
        )t 
group by
        t.name
        ,t.type
                                       		