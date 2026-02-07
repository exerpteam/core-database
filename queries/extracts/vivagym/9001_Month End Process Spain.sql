WITH params AS MATERIALIZED
(
        SELECT
               TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS todaysDate,
               c.id AS center_id,
               c.shortname AS center_name
        FROM
                centers c
        WHERE
                c.country = 'ES'
)
SELECT
        r1.SubscriptionId, 
        r1.end_date,
        r1.personkey,
        r1.Center,
        r1.balance,
        r1.Clearing_house,
        r1."Person Status",
        r1.Substatus,
        r1.PaymentAgreement_State,
        r1.group,
        r1.ccc_amount,
        EXISTS
        (
                SELECT sfp.* 
                FROM vivagym.subscription_freeze_period sfp 
                WHERE 
                        (sfp.subscription_center || 'ss' || sfp.subscription_id) = r1.subscriptionid 
                        AND sfp.state = 'ACTIVE'
                        AND sfp.cancel_time IS NULL 
                        AND sfp.end_date > todaysDate
        ) AS "cancel-stop-freeze"
FROM
( 
        WITH params AS MATERIALIZED
        (
                SELECT
                       TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS todaysDate,
                       c.id AS center_id,
                       c.shortname AS center_name
                FROM
                        centers c
                WHERE
                        c.country = 'ES'
        )
        -- SEPA rejections received today (CCC is not still open)
        SELECT
                DISTINCT
                s.center || 'ss' || s.id AS SubscriptionId, 
                p.center AS centerid,
                s.end_date,
                p.center || 'p' || p.id AS personkey,
                par.center_name AS Center,
                ar.balance,
                ch.name as Clearing_house,
                (CASE p.STATUS
                        WHEN 0 THEN 'LEAD'
                        WHEN 1 THEN 'ACTIVE'
                        WHEN 2 THEN 'INACTIVE'
                        WHEN 3 THEN 'TEMPORARYINACTIVE'
                        WHEN 4 THEN 'TRANSFERRED'
                        WHEN 5 THEN 'DUPLICATE'
                        WHEN 6 THEN 'PROSPECT'
                        WHEN 7 THEN 'DELETED'
                        WHEN 8 THEN 'ANONYMIZED'
                        WHEN 9 THEN 'CONTACT'
                        ELSE 'UNKNOWN'
                END) AS "Person Status",
                (CASE
                        WHEN p.blacklisted = 0 THEN 'NONE'
                        WHEN p.blacklisted = 1 THEN 'BLACKLISTED'
                        WHEN p.blacklisted = 2 THEN 'SUSPENDED'
                        WHEN p.blacklisted = 3 THEN 'BLOCKED'
                END) AS Substatus,
                (CASE pag.STATE 
                       WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' 
                       WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' 
                       WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' 
                       WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' 
                       WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' 
                       WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' 
                       ELSE NULL 
                END) AS PaymentAgreement_State,
                'SEPA rejected today' AS group,
                0 as ccc_amount
        FROM vivagym.clearing_in ci
        JOIN vivagym.payment_requests pr
                 ON ci.id = pr.xfr_delivery
        JOIN params par 
                ON par.center_id = pr.center
        JOIN vivagym.account_receivables ar
                ON ar.center = pr.center
                AND ar.id = pr.id
        JOIN vivagym.persons p
                ON ar.customercenter = p.center
                AND ar.customerid = p.id
        LEFT JOIN vivagym.payment_accounts paa
                ON ar.center = paa.center
                AND ar.id = paa.id
        LEFT JOIN vivagym.payment_agreements pag
                ON paa.active_agr_center = pag.center
                AND paa.active_agr_id = pag.id
                AND paa.active_agr_subid = pag.subid
        LEFT JOIN vivagym.clearinghouses ch
                ON ch.id = pag.clearinghouse
        LEFT JOIN vivagym.subscriptions s
                ON s.owner_center = p.center
                AND s.owner_id = p.id
                AND s.state IN (2,4,8)
                AND 
                (
                        s.end_date IS NULL 
                        OR
                        s.end_date > par.todaysDate
                )
        WHERE 
                ci.received_date = par.todaysDate
                AND pr.creditor_id LIKE '2768'
                AND ar.balance < -16
                AND
                (
                        s.center IS NOT NULL
                        OR
                        pag.center IS NOT NULL
                        OR
                        p.blacklisted NOT IN (2)
                )
        UNION
        -- This one makes no sense it will never happen
        -- Adyen rejections received today (CCC is not still open)
        SELECT
                DISTINCT
                s.center || 'ss' || s.id AS SubscriptionId, 
                p.center AS centerid,
                s.end_date,
                p.center || 'p' || p.id AS personkey,
                par.center_name AS Center,
                ar.balance,
                ch.name as Clearing_house,
                (CASE p.STATUS
                        WHEN 0 THEN 'LEAD'
                        WHEN 1 THEN 'ACTIVE'
                        WHEN 2 THEN 'INACTIVE'
                        WHEN 3 THEN 'TEMPORARYINACTIVE'
                        WHEN 4 THEN 'TRANSFERRED'
                        WHEN 5 THEN 'DUPLICATE'
                        WHEN 6 THEN 'PROSPECT'
                        WHEN 7 THEN 'DELETED'
                        WHEN 8 THEN 'ANONYMIZED'
                        WHEN 9 THEN 'CONTACT'
                        ELSE 'UNKNOWN'
                END) AS "Person Status",
                (CASE
                        WHEN p.blacklisted = 0 THEN 'NONE'
                        WHEN p.blacklisted = 1 THEN 'BLACKLISTED'
                        WHEN p.blacklisted = 2 THEN 'SUSPENDED'
                        WHEN p.blacklisted = 3 THEN 'BLOCKED'
                END) AS Substatus,
                (CASE pag.STATE 
                       WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' 
                       WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' 
                       WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' 
                       WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' 
                       WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' 
                       WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' 
                       ELSE NULL 
                END) AS PaymentAgreement_State,
                'ADYEN rejected today' AS group,
        0
        FROM vivagym.payment_requests pr
        JOIN params par 
                ON par.center_id = pr.center
        JOIN vivagym.account_receivables ar
                ON ar.center = pr.center
                AND ar.id = pr.id
        JOIN vivagym.persons p
                ON ar.customercenter = p.center
                AND ar.customerid = p.id
        LEFT JOIN vivagym.payment_accounts paa
                ON ar.center = paa.center
                AND ar.id = paa.id
        LEFT JOIN vivagym.payment_agreements pag
                ON paa.active_agr_center = pag.center
                AND paa.active_agr_id = pag.id
                AND paa.active_agr_subid = pag.subid
        LEFT JOIN vivagym.clearinghouses ch
                ON ch.id = pag.clearinghouse
        LEFT JOIN vivagym.subscriptions s
                ON s.owner_center = p.center
                AND s.owner_id = p.id
                AND s.state IN (2,4,8)
                AND 
                (
                        s.end_date IS NULL 
                        OR
                        s.end_date > par.todaysDate
                )
        WHERE 
                pr.req_date = par.todaysDate
                AND pr.creditor_id = 'Adyen' 
                AND pr.state NOT IN (3)
                AND pr.request_type = 1
                AND
                (
                        s.center IS NOT NULL
                        OR
                        pag.center IS NOT NULL
                        OR
                        p.blacklisted NOT IN (2)
                )
        UNION 
        -- Open CashCollectionCases
        SELECT
                s.center || 'ss' || s.id AS SubscriptionId, 
                p.center AS centerid,
                s.end_date,
                p.center || 'p' || p.id AS personkey,
                par.center_name AS Center,
                ar.balance,
                ch.name as Clearing_house,
                (CASE p.STATUS
                        WHEN 0 THEN 'LEAD'
                        WHEN 1 THEN 'ACTIVE'
                        WHEN 2 THEN 'INACTIVE'
                        WHEN 3 THEN 'TEMPORARYINACTIVE'
                        WHEN 4 THEN 'TRANSFERRED'
                        WHEN 5 THEN 'DUPLICATE'
                        WHEN 6 THEN 'PROSPECT'
                        WHEN 7 THEN 'DELETED'
                        WHEN 8 THEN 'ANONYMIZED'
                        WHEN 9 THEN 'CONTACT'
                        ELSE 'UNKNOWN'
                END) AS "Person Status",
                (CASE
                        WHEN p.blacklisted = 0 THEN 'NONE'
                        WHEN p.blacklisted = 1 THEN 'BLACKLISTED'
                        WHEN p.blacklisted = 2 THEN 'SUSPENDED'
                        WHEN p.blacklisted = 3 THEN 'BLOCKED'
                END) AS Substatus,
                (CASE pag.STATE 
                       WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' 
                       WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' 
                       WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' 
                       WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' 
                       WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' 
                       WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' 
                       ELSE NULL 
                END) AS PaymentAgreement_State,
                'Cash Collection Case' AS group,
        ccc.amount
        FROM vivagym.cashcollectioncases ccc
        JOIN params par
                ON par.center_id = ccc.personcenter
        JOIN vivagym.account_receivables ar
                ON ar.customercenter = ccc.personcenter
                AND ar.customerid = ccc.personid
                AND ar.ar_type = 4
        JOIN vivagym.persons p
                ON ar.customercenter = p.center
                AND ar.customerid = p.id
        LEFT JOIN vivagym.payment_accounts paa
                ON ar.center = paa.center
                AND ar.id = paa.id
        LEFT JOIN vivagym.payment_agreements pag
                ON paa.active_agr_center = pag.center
                AND paa.active_agr_id = pag.id
                AND paa.active_agr_subid = pag.subid
        LEFT JOIN vivagym.clearinghouses ch
                ON ch.id = pag.clearinghouse
        LEFT JOIN vivagym.subscriptions s
                ON s.owner_center = p.center
                AND s.owner_id = p.id
                AND s.state IN (2,4,8)
                AND 
                (
                        s.end_date IS NULL 
                        OR
                        s.end_date > par.todaysDate
                )
        LEFT JOIN vivagym.subscriptiontypes st
                ON s.subscriptiontype_center = st.center
                AND s.subscriptiontype_id = st.id
                AND st.st_type = 1
        WHERE
                ccc.closed = false
                AND ccc.missingpayment = true
                AND p.status NOT IN (0,2,4,5,7,8,9)
                AND ccc.amount > 10
) r1
JOIN params par ON center_id = r1.centerid