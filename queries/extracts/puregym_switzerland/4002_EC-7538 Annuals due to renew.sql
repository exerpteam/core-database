-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    date_range AS materialized
    (
        SELECT
             :from_date::DATE AS from_date,
               :to_date::DATE   AS to_date
           -- '2024-07-25'::DATE AS from_date,
          --  '2024-11-25'::DATE AS to_date
    )
    ,
    due_renew AS
    (
        SELECT
            p.external_id        AS external_id,
            p.center             AS person_center,
            p.center||'p'||p.id  AS member_id,
            s.center||'ss'||s.id AS subscription_id,
            CASE s.STATE
                WHEN 2
                THEN 'ACTIVE'
                WHEN 3
                THEN 'ENDED'
                WHEN 4
                THEN 'FROZEN'
                WHEN 7
                THEN 'WINDOW'
                WHEN 8
                THEN 'CREATED'
                ELSE 'Undefined'
            END AS subscription_state,
            s.end_date,
            s.billed_until_date,
            pr.name AS product_name,
            CASE pag.STATE
                WHEN 1
                THEN 'Created'
                WHEN 2
                THEN 'Sent'
                WHEN 3
                THEN 'Failed'
                WHEN 4
                THEN 'OK'
                WHEN 5
                THEN 'Ended, bank'
                WHEN 6
                THEN 'Ended, clearing house'
                WHEN 7
                THEN 'Ended, debtor'
                WHEN 8
                THEN 'Cancelled, not sent'
                WHEN 9
                THEN 'Cancelled, sent'
                WHEN 10
                THEN 'Ended, creditor'
                WHEN 11
                THEN 'No agreement'
                WHEN 12
                THEN 'Cash payment (deprecated)'
                WHEN 13
                THEN 'Agreement not needed (invoice payment)'
                WHEN 14
                THEN 'Agreement information incomplete'
                WHEN 15
                THEN 'Transfer'
                WHEN 16
                THEN 'Agreement Recreated'
                WHEN 17
                THEN 'Signature missing'
                ELSE 'UNDEFINED'
            END AS payment_agreement_state
        FROM
            subscriptions s
        CROSS JOIN
            date_range dr
        JOIN
            persons p
        ON
            p.center=s.owner_center
        AND p.id=s.owner_id
        JOIN
            puregym_switzerland.product_and_product_group_link ppgl
        ON
            ppgl.product_center = s.subscriptiontype_center
        AND ppgl.product_id = s.subscriptiontype_id
        AND ppgl.product_group_id = 602 --12 Month - Reporting
        JOIN
            products pr
        ON
            s.subscriptiontype_center=pr.CENTER
        AND s.subscriptiontype_id=pr.ID
        JOIN
            account_receivables ar
        ON
            p.center=ar.customercenter
        AND p.id=ar.customerid
        JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.center = ar.center
        AND pac.id = ar.id
        JOIN
            PAYMENT_AGREEMENTS pag
        ON
            pac.active_agr_center = pag.center
        AND pac.active_agr_id = pag.id
        AND pac.active_agr_subid = pag.subid
        WHERE
            (
                s.end_date > s.billed_until_date
            OR  s.end_date IS NULL)
        AND s.billed_until_date BETWEEN dr.from_date AND dr.to_date
        AND ar.ar_type=4
        AND ar.state=0
    )
SELECT
    *
FROM
    due_renew