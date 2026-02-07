SELECT
        r1.person_id,
        r1.PERSONTYPE,
        r1.PERSON_STATUS,
        r1.balance,
        r1.has_subscription,
        r1.latest_remesa,
        r1.agreement_creation_date,
        r1.employee_payment_agr
FROM
(
        SELECT
                t1.person_id,
                t1.PERSONTYPE,
                t1.PERSON_STATUS,
                t1.balance,
                t1.has_subscription,
                t1.latest_remesa,
                acl.employee_center,
                acl.employee_id,
                acl.text,
                TO_CHAR(longtodatec(acl.entry_time, acl.agreement_center),'YYYY:MM:DD HH24:MI') AS agreement_creation_date,
                pemp.fullname AS employee_payment_agr,
                rank() over (partition by acl.agreement_center,acl.agreement_id,acl.agreement_subid ORDER BY acl.entry_time, acl.text) ranking
        FROM
        (
                WITH PARAMS AS MATERIALIZED
                (
                        SELECT
                                DATE_TRUNC('MONTH', TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 month') AS cutdate,
                                c.id AS centerId
                        FROM vivagym.centers c
                        WHERE
                                c.country = 'ES'
                ),
                subscription_list AS
                (
                        SELECT
                                DISTINCT
                                s.owner_center,
                                s.owner_id
                        FROM persons p
                        JOIN params par 
                                ON p.center = par.centerId
                        JOIN vivagym.account_receivables ar 
                                ON p.center = ar.customercenter AND p.id = ar.customerid
                        JOIN vivagym.centers c 
                                ON ar.center = c.id AND c.country = 'ES'
                        JOIN vivagym.payment_accounts pac 
                                ON ar.center = pac.center AND ar.id = pac.id
                        JOIN vivagym.payment_agreements pag 
                                ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
                        JOIN vivagym.subscriptions s 
                                ON p.center = s.owner_center AND p.id = s.owner_id 
                        JOIN vivagym.subscriptiontypes st
                                ON st.center = s.subscriptiontype_center AND st.id = s.subscriptiontype_id AND st.st_type = 1
                        LEFT JOIN vivagym.subscription_price sp 
                                ON sp.subscription_center = s.center AND sp.subscription_id = s.id AND sp.cancelled = false AND sp.from_date = par.cutdate
                        WHERE
                                pag.clearinghouse = 1
                                AND pag.state = 1
                                AND p.status IN (1,3)
                                AND s.state IN (2,4,8)
                                AND (s.end_date > par.cutDate OR s.end_date IS NULL)
                                AND 
                                (
                                        s.subscription_price > 0 
                                        OR 
                                        (s.subscription_price = 0 AND sp.price > 0)
                                )
                )
                SELECT
                        ar.customercenter || 'p' || ar.customerid as person_id,
                        CASE p.persontype WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
                        CASE p.status WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
                        ar.balance,
                        (CASE WHEN sl.owner_center IS NULL THEN 'No subscription to collect next month'
                                ELSE 'Active Subscription to collect'
                        END) has_subscription,
                        MAX(pr.req_date) latest_remesa,
                        pag.center,
                        pag.id,
                        pag.subid
                FROM persons p
                JOIN vivagym.account_receivables ar 
                        ON p.center = ar.customercenter AND p.id = ar.customerid
                JOIN vivagym.centers c 
                        ON ar.center = c.id AND c.country = 'ES'
                JOIN vivagym.payment_accounts pac 
                        ON ar.center = pac.center AND ar.id = pac.id
                JOIN vivagym.payment_agreements pag 
                        ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
                LEFT JOIN vivagym.payment_requests pr 
                        ON pag.center = pr.center AND pag.id = pr.id AND pag.subid = pr.agr_subid
                LEFT JOIN subscription_list sl
                        ON sl.owner_center = p.center AND sl.owner_id = p.id
                WHERE
                        pag.clearinghouse = 1
                        AND pag.state = 1
                        AND p.status IN (1,3)
                GROUP BY
                        ar.customercenter,
                        ar.customerid, 
                        ar.balance,
                        sl.owner_center,
                        p.persontype,
                        p.status,
                        pag.center,
                        pag.id,
                        pag.subid
        ) t1
        JOIN vivagym.agreement_change_log acl 
                ON t1.center = acl.agreement_center AND t1.id = acl.agreement_id AND t1.subid = acl.agreement_subid
        LEFT JOIN vivagym.employees emp
                ON emp.center = acl.employee_center AND emp.id = acl.employee_id
        LEFT JOIN vivagym.persons pemp
                ON pemp.center = emp.personcenter AND pemp.id = emp.personid
) r1
WHERE
        r1.ranking = 1