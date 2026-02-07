SELECT
        t1.*
FROM
(
        SELECT
                p.center || 'p' || p.id as person_id,
                p.persontype,
                MAX(s.start_date) AS sub_startdate,
                MAX(s.subscription_price) sub_price,
                ar.balance
        FROM vivagym.persons p
        JOIN vivagym.centers c ON p.center = c.id AND c.country = 'PT'
        JOIN vivagym.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
        JOIN vivagym.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
        JOIN vivagym.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id AND s.state in (2,4,8) AND (s.end_date IS NULL OR s.end_date > s.billed_until_date)
        JOIN vivagym.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id AND st.st_type = 1
        WHERE
                pac.active_agr_center IS NULL
                AND EXISTS
                (
                        SELECT 
                                1
                        FROM vivagym.subscriptions s
                        WHERE
                                s.owner_center = p.center
                                AND s.owner_id = p.id
                                AND s.state IN (2,4,8)
                )
        GROUP BY
                p.center,
                p.id,
                p.persontype,
                ar.balance
) t1
WHERE  
        t1.persontype NOT IN (2)