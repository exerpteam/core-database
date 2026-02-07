WITH params AS
(
        SELECT
                date_trunc('month',to_date(getCenterTime(c.id),'YYYY-MM-DD')) AS last_collection,
                date_trunc('month',to_date(getCenterTime(c.id),'YYYY-MM-DD') + INTERVAL '1 month') - interval '1 days' AS end_of_month,
                date_trunc('month',to_date(getCenterTime(c.id),'YYYY-MM-DD') + INTERVAL '2 month') - interval '1 days' AS end_of_month_plus_one,
                c.id
        FROM stjames.centers c
),
payment_request_unique AS
(
        SELECT
                t1.*
        FROM
        (
                SELECT
                        pr.center,
                        pr.id,
                        pr.agr_subid,
                        pr.xfr_info,
                        pr.entry_time,
                        RANK() OVER (PARTITION BY pr.center, pr.id, pr.agr_subid ORDER BY pr.entry_time DESC) AS ranking
                FROM stjames.payment_requests pr
                JOIN params par ON pr.center = par.id
                WHERE
                        pr.req_date = par.last_collection
                        AND pr.request_type = 1
                        AND pr.state NOT IN (8)
        ) t1
        WHERE 
                t1.ranking = 1

)
SELECT
        DISTINCT
        t2.subscription_owner,
        t2.sub_owner_persontype,
        t2.payer,
        t2.account_balance,
        t2.subscription_id,
        t2.product_name,
        t2.subscription_price,
        t2.has_sub_agr_assigned,
        t2.linked_agreement_ref,
        t2.linked_agreement_subid,
        t2.linked_agreement_state,
        t2.linked_agreement_clearinghouse,
        --t2.product_global_id,
        linked_pr.xfr_info AS linked_agreement_last_collection,
        t2.actual_agreement_ref,
        t2.actual_agreement_subid,
        t2.actual_agreement_state,
        t2.actual_agreement_clearinghouse,
        act_pr.xfr_info AS actual_agreement_last_collection,
        (CASE
                WHEN t2.actual_agreement_ref IS NOT NULL AND t2.actual_agreement_state = 'OK' THEN 'OK: Ready for collection using agreement in column actual_agreement_subid'
                WHEN t2.actual_agreement_ref IS NOT NULL AND t2.actual_agreement_state = 'Sent' THEN 'NOT OK: Agreement in column actual_agreement_subid not ready for collection yet: state SENT'
                WHEN t2.actual_agreement_ref IS NOT NULL AND t2.actual_agreement_state = 'Failed' THEN 'NOT OK: Agreement in column actual_agreement_subid not valid: state Failed'
                WHEN t2.actual_agreement_ref IS NOT NULL AND t2.actual_agreement_state IN ('Ended, creditor','Ended, clearing house') THEN 'NOT OK: Agreement in column actual_agreement_subid not valid: state Ended'
                WHEN t2.linked_agreement_state = 'OK' THEN 'OK: Ready for collection using linked_agreement_subid'
                WHEN t2.linked_agreement_state = 'Sent' THEN 'NOT OK: Agreement in column linked_agreement_subid not ready for collection yet: state SENT'
                WHEN t2.linked_agreement_state = 'Failed' THEN 'NOT OK: Agreement in column linked_agreement_subid not valid: state Failed'
                WHEN t2.linked_agreement_state IN ('Ended, creditor','Ended, clearing house') THEN 'NOT OK: Agreement in column linked_agreement_subid not valid: state Ended'
                WHEN t2.linked_agreement_state IS NULL THEN 'NOT OK: No agreement for subscription'
                ELSE NULL
        END) Exerp_comment
FROM
(
        
        SELECT
                t1.center,
                t1.subscription_owner,
                t1.payer,
                t1.subscription_id,
                t1.subscription_price,
                CASE t1.persontype WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS sub_owner_persontype,
                t1.product_name,
                t1.product_global_id,
                (CASE WHEN t1.payment_agreement_center IS NOT NULL THEN 'override agreement on subscription' ELSE NULL END) AS has_sub_agr_assigned,
                t1.potential_payment_agr_ref AS linked_agreement_ref,
                t1.potential_payment_agr_subid AS linked_agreement_subid,
                CASE t1.potential_payment_agr_state WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE NULL END AS linked_agreement_state,
                ch_pot.name AS linked_agreement_clearinghouse,
                current_agr.ref AS actual_agreement_ref,
                current_agr.subid AS actual_agreement_subid,
                CASE current_agr.state WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE NULL END AS actual_agreement_state,
                ch_act.name AS actual_agreement_clearinghouse,
                t1.current_payment_agr_center,
                t1.current_payment_agr_id,
                t1.current_payment_agr_subid,
                t1.potential_payment_agr_center,
                t1.potential_payment_agr_id,
                t1.potential_payment_agr_subid,
                t1.account_balance
        FROM
        (
                SELECT
                        p.center,
                        p.center || 'p' || p.id AS subscription_owner,
                        r.center || 'p' || r.id AS payer,
                        s.center || 'ss' || s.id AS subscription_id,
                        s.payment_agreement_center,
                        pr.name AS product_name,
                        pr.globalid AS product_global_id,
                        s.subscription_price,
                        (CASE WHEN r.center IS NULL THEN ar_owner.balance ELSE ar_payer.balance END) AS account_balance,
                        --r.center AS payer_center,
                        --r.id AS payer_id,
                        --p.center AS sub_owner_center,
                        --p.id AS sub_owner_id,
                        --s.center AS sub_center,
                        --s.id AS sub_id,
                        --s.payment_agreement_center,
                        --s.payment_agreement_id,
                        --s.payment_agreement_subid,
                        p.persontype,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.ref
                                WHEN r.center IS NOT NULL THEN pag_payer.ref
                                ELSE pag_owner.ref
                        END) AS potential_payment_agr_ref,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.state
                                WHEN r.center IS NOT NULL THEN pag_payer.state
                                ELSE pag_owner.state
                        END) AS potential_payment_agr_state,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.clearinghouse
                                WHEN r.center IS NOT NULL THEN pag_payer.clearinghouse
                                ELSE pag_owner.clearinghouse
                        END) AS potential_payment_agr_clearinghouse,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.center
                                WHEN r.center IS NOT NULL THEN pag_payer.center
                                ELSE pag_owner.center
                        END) AS potential_payment_agr_center,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.id
                                WHEN r.center IS NOT NULL THEN pag_payer.id
                                ELSE pag_owner.id
                        END) AS potential_payment_agr_id,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.subid
                                WHEN r.center IS NOT NULL THEN pag_payer.subid
                                ELSE pag_owner.subid
                        END) AS potential_payment_agr_subid,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.current_center
                                WHEN r.center IS NOT NULL THEN pag_payer.current_center
                                ELSE pag_owner.current_center
                        END) AS current_payment_agr_center,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.current_id
                                WHEN r.center IS NOT NULL THEN pag_payer.current_id
                                ELSE pag_owner.current_id
                        END) AS current_payment_agr_id,
                        (CASE
                                WHEN s.payment_agreement_center IS NOT NULL THEN pag_sub.current_subid
                                WHEN r.center IS NOT NULL THEN pag_payer.current_subid
                                ELSE pag_owner.current_subid
                        END) AS current_payment_agr_subid
                FROM stjames.persons p
                JOIN params par ON p.center = par.id
                JOIN stjames.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
                JOIN stjames.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
                JOIN stjames.products pr ON st.center = pr.center AND st.id = pr.id 
                LEFT JOIN stjames.relatives r ON r.relativecenter = p.center AND r.relativeid = p.id AND r.rtype = 12 AND r.status < 2
                LEFT JOIN stjames.account_receivables ar_payer ON ar_payer.customercenter = r.center AND ar_payer.customerid = r.id AND ar_payer.ar_type = 4
                LEFT JOIN stjames.account_receivables ar_owner ON ar_owner.customercenter = p.center AND ar_owner.customerid = p.id AND ar_owner.ar_type = 4
                LEFT JOIN stjames.payment_accounts pac_payer ON ar_payer.center = pac_payer.center AND ar_payer.id = pac_payer.id
                LEFT JOIN stjames.payment_accounts pac_owner ON pac_owner.center = ar_owner.center AND pac_owner.id = ar_owner.id
                LEFT JOIN stjames.payment_agreements pag_payer ON pag_payer.center = pac_payer.active_agr_center AND pag_payer.id = pac_payer.active_agr_id AND pag_payer.subid = pac_payer.active_agr_subid
                LEFT JOIN stjames.payment_agreements pag_owner ON pag_owner.center = pac_owner.active_agr_center AND pag_owner.id = pac_owner.active_agr_id AND pag_owner.subid = pac_owner.active_agr_subid
                LEFT JOIN stjames.payment_agreements pag_sub ON pag_sub.center = s.payment_agreement_center AND pag_sub.id = s.payment_agreement_id AND pag_sub.subid = s.payment_agreement_subid
                WHERE
                        s.state IN (2,4,8)
                        AND st.st_type NOT IN (0)
                        AND pr.globalid NOT IN ('EMPLOYEE_MEMBERSHIP')
                        AND 
                        (
                                s.end_date IS NULL 
                                OR
                                s.end_date > par.end_of_month
                        )
                        AND
                        (
                                s.billed_until_date IS NULL
                                OR
                                s.billed_until_date < par.end_of_month_plus_one
                        )
        ) t1
        LEFT JOIN stjames.payment_agreements current_agr ON t1.current_payment_agr_center = current_agr.center AND t1.current_payment_agr_id = current_agr.id AND t1.current_payment_agr_subid = current_agr.subid
        LEFT JOIN stjames.clearinghouses ch_pot ON ch_pot.id = t1.potential_payment_agr_clearinghouse
        LEFT JOIN stjames.clearinghouses ch_act ON ch_act.id = current_agr.clearinghouse
) t2
JOIN params par ON par.id = t2.center
LEFT JOIN payment_request_unique act_pr ON act_pr.center = t2.current_payment_agr_center AND act_pr.id = t2.current_payment_agr_id AND act_pr.agr_subid = t2.current_payment_agr_subid
LEFT JOIN payment_request_unique linked_pr ON linked_pr.center = t2.potential_payment_agr_center AND linked_pr.id = t2.potential_payment_agr_id AND linked_pr.agr_subid = t2.potential_payment_agr_subid 
