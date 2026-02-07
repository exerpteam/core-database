WITH
    def_pay_ag AS
    (
        SELECT
            ar.customercenter AS pcenter,
            ar.customerid     AS pid,
            pag.center,
            pag.id,
            pag.subid,
            pag.bank_accno,
            pag.state,
            pag.clearinghouse
        FROM
            account_receivables ar
        JOIN
            payment_accounts pac
        ON
            pac.center = ar.center
        AND pac.id = ar.id
        JOIN
            payment_agreements pag
        ON
            pac.active_agr_center = pag.center
        AND pac.active_agr_id = pag.id
        AND pac.active_agr_subid = pag.subid
        WHERE
            ar.ar_type = 4
    )
    ,
    pay_ag1 AS
    (
        SELECT
            pag.*,
            rank () over (PARTITION BY pag.center, pag.id ORDER BY pag.subid DESC)
        FROM
            chelseapiers.payment_agreements pag
        JOIN
            def_pay_ag dpag
        ON
            dpag.center = pag.center
        AND dpag.id = pag.id
        AND dpag.subid <> pag.subid
        WHERE
            pag.active = true
        GROUP BY
            pag.center,
            pag.id,
            pag.subid
    )
SELECT
    c.name                            AS "Scope",
    s.owner_center ||'p'|| s.owner_id AS "SubscriptionOwnerKey",
    p.firstname ||' '|| p.lastname    AS "SubscriptionOwner",
    CASE
        WHEN s.state = 2
        THEN 'Active'
        WHEN s.state = 3
        THEN 'Ended'
        WHEN s.state = 4
        THEN 'Frozen'
        WHEN s.state = 7
        THEN 'Window'
        WHEN s.state = 8
        THEN 'Created'
    END                                    AS "Status",
    s.center ||'ss'||s.id                  AS "SubscriptionKey",
    s.creator_center ||'p'|| s.creator_id  AS "SalesEmployee",
    s.subscription_price                   AS "Monthly Price",
    longtoDateC(s.creation_time, s.center) AS "SalesDate",
    s.start_date                           AS "StartDate",
    ch.name                                AS "Default Payment Agreement Clearinghouse",
    dpag.bank_accno                        AS "Default Bank Account/ Card Number",
    CASE
        WHEN dpag.state = 1
        THEN 'Created'
        WHEN dpag.state = 2
        THEN 'Sent'
        WHEN dpag.state = 3
        THEN 'Failed'
        WHEN dpag.state = 4
        THEN 'OK'
        WHEN dpag.state = 5
        THEN 'Ended, bank'
        WHEN dpag.state = 6
        THEN 'Ended, clearing house'
        WHEN dpag.state = 7
        THEN 'Ended, debtor'
        WHEN dpag.state = 8
        THEN 'Cancelled, not sent'
        WHEN dpag.state = 9
        THEN 'Cancelled, sent'
        WHEN dpag.state = 10
        THEN 'Ended, creditor'
        WHEN dpag.state = 11
        THEN 'No agreement'
        WHEN dpag.state = 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN dpag.state = 14
        THEN 'Agreement information incomplete'
        WHEN dpag.state = 15
        THEN 'Transfer'
        WHEN dpag.state = 16
        THEN 'Agreement recreated'
        WHEN dpag.state = 17
        THEN 'Agreement signature missing'
        ELSE NULL
    END             AS "Default Payment Agreement Status",
    ch1.name        AS "Active Payment Agreement Clearinghouse #2",
    pag1.bank_accno AS "Active Bank Account/ Card Number #2",
    CASE
        WHEN pag1.state = 1
        THEN 'Created'
        WHEN pag1.state = 2
        THEN 'Sent'
        WHEN pag1.state = 3
        THEN 'Failed'
        WHEN pag1.state = 4
        THEN 'OK'
        WHEN pag1.state = 5
        THEN 'Ended, bank'
        WHEN pag1.state = 6
        THEN 'Ended, clearing house'
        WHEN pag1.state = 7
        THEN 'Ended, debtor'
        WHEN pag1.state = 8
        THEN 'Cancelled, not sent'
        WHEN pag1.state = 9
        THEN 'Cancelled, sent'
        WHEN pag1.state = 10
        THEN 'Ended, creditor'
        WHEN pag1.state = 11
        THEN 'No agreement'
        WHEN pag1.state = 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN pag1.state = 14
        THEN 'Agreement information incomplete'
        WHEN pag1.state = 15
        THEN 'Transfer'
        WHEN pag1.state = 16
        THEN 'Agreement recreated'
        WHEN pag1.state = 17
        THEN 'Agreement signature missing'
        ELSE NULL
    END             AS "Active Payment Agreement Status #2",
    ch2.name        AS "Active Payment Agreement Clearinghouse #3",
    pag2.bank_accno AS "Active Bank Account/ Card Number #3",
    CASE
        WHEN pag2.state = 1
        THEN 'Created'
        WHEN pag2.state = 2
        THEN 'Sent'
        WHEN pag2.state = 3
        THEN 'Failed'
        WHEN pag2.state = 4
        THEN 'OK'
        WHEN pag2.state = 5
        THEN 'Ended, bank'
        WHEN pag2.state = 6
        THEN 'Ended, clearing house'
        WHEN pag2.state = 7
        THEN 'Ended, debtor'
        WHEN pag2.state = 8
        THEN 'Cancelled, not sent'
        WHEN pag2.state = 9
        THEN 'Cancelled, sent'
        WHEN pag2.state = 10
        THEN 'Ended, creditor'
        WHEN pag2.state = 11
        THEN 'No agreement'
        WHEN pag2.state = 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN pag2.state = 14
        THEN 'Agreement information incomplete'
        WHEN pag2.state = 15
        THEN 'Transfer'
        WHEN pag2.state = 16
        THEN 'Agreement recreated'
        WHEN pag2.state = 17
        THEN 'Agreement signature missing'
        ELSE NULL
    END AS "Active Payment Agreement Status #3"
FROM
    chelseapiers.subscriptions s
JOIN
    chelseapiers.centers c
ON
    s.center = c.id
JOIN
    chelseapiers.persons p
ON
    p.center = s.owner_center
AND p.id = s.owner_id
JOIN
    def_pay_ag dpag
ON
    s.owner_center = dpag.pcenter
AND s.owner_id = dpag.pid
LEFT JOIN
    pay_ag1 pag1
ON
    dpag.center = pag1.center
AND dpag.id = pag1.id
AND pag1.rank = 1
LEFT JOIN
    pay_ag1 pag2
ON
    dpag.center = pag2.center
AND dpag.id = pag2.id
AND pag2.rank = 2
JOIN
    chelseapiers.clearinghouses ch
ON
    dpag.clearinghouse = ch.id
LEFT JOIN
    chelseapiers.clearinghouses ch1
ON
    pag1.clearinghouse = ch1.id
LEFT JOIN
    chelseapiers.clearinghouses ch2
ON
    pag2.clearinghouse = ch2.id
WHERE
  s.state IN (:sub_states)
AND 
s.center IN ($$scope$$) ;


