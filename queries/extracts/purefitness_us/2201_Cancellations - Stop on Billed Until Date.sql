-- 2. Stop on BUD
SELECT
        p.center,
        p.id,
        p.fullname,
        pag.ref,
        pag.bank_account_holder,
        (CASE sub.STATE 
                WHEN 2 THEN 'ACTIVE' 
                WHEN 3 THEN 'ENDED' 
                WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' 
                WHEN 8 THEN 'CREATED' 
                ELSE 'Undefined' 
        END) AS SubscriptionState,
        sub.start_date,
        sub.billed_until_date,
        sub.end_date,
        longtodate(pag.creation_time) AS DDI_CREATED,
        ar.balance,
        ccc.startdate AS DEBT_START,
        ccc.amount,
        acl.log_date,
        (CASE pag.STATE 
                WHEN 1 THEN 'Created' 
                WHEN 2 THEN 'Sent' 
                WHEN 3 THEN 'Failed' 
                WHEN 4 THEN 'OK' 
                WHEN 5 THEN 'Ended = bank' 
                WHEN 6 THEN 'Ended = clearing house' 
                WHEN 7 THEN 'Ended = debtor' 
                WHEN 8 THEN 'Cancelled = not sent' 
                WHEN 9 THEN 'Cancelled = sent' 
                WHEN 10 THEN 'Ended = creditor' 
                WHEN 11 THEN 'No agreement' 
                WHEN 12 THEN 'Cash payment (deprecated)' 
                WHEN 13 THEN 'Agreement not needed (invoice payment)' 
                WHEN 14 THEN 'Agreement information incomplete' 
                WHEN 15 THEN 'Transfer' 
                WHEN 16 THEN 'Agreement Recreated' 
                WHEN 17 THEN 'Signature missing' 
                ELSE 'UNDEFINED' 
        END) AS DDIState,
        acl.TEXT AS ReasonCode,
		p.external_id
FROM persons p
JOIN subscriptions sub
        ON sub.owner_center = p.center
        AND sub.owner_id = p.id
        AND sub.state IN (2,4,8)
JOIN purefitnessus.subscriptiontypes st
        ON st.center = sub.subscriptiontype_center
        AND st.id = sub.subscriptiontype_id
        AND st.st_type = 1
JOIN purefitnessus.products prod
        ON prod.center = st.center 
        AND prod.id = st.id
JOIN purefitnessus.account_receivables ar
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
        AND ar.ar_type = 4
JOIN purefitnessus.payment_accounts pa
        ON pa.center = ar.center
        AND pa.id = ar.id
JOIN purefitnessus.payment_agreements pag
        ON pag.center = pa.active_agr_center
        AND pag.id = pa.active_agr_id
        AND pag.subid = pa.active_agr_subid
LEFT JOIN purefitnessus.cashcollectioncases mac
        ON mac.personcenter = p.center
        AND mac.personid = p.id
        AND mac.closed = 0
        AND mac.missingpayment = 0
LEFT JOIN purefitnessus.cashcollectioncases ccc
        ON ccc.personcenter = p.center
        AND ccc.personid = p.id
        AND ccc.closed = 0
        AND ccc.missingpayment = 1
JOIN
(
        SELECT
                acl2.agreement_center,
                acl2.agreement_id,
                acl2.agreement_subid,
                acl2.state,
                MAX(acl2.id) AS Id
        FROM purefitnessus.agreement_change_log acl2
        WHERE
              acl2.text is null 
              OR acl2.text not like 'Deduction day%'
        GROUP BY
                acl2.agreement_center,
                acl2.agreement_id,
                acl2.agreement_subid,
                acl2.state 
) acl3
        ON acl3.agreement_center = pag.center
        AND acl3.agreement_id = pag.id
        AND acl3.agreement_subid = pag.subid
        AND acl3.state = pag.state
LEFT JOIN purefitnessus.agreement_change_log acl
        ON acl.id = acl3.id
WHERE
        mac.center IS NOT NULL
        AND pag.clearinghouse = 1 -- CreditCard
        AND pag.STATE NOT IN (1,2,4,15)
        AND pag.STATE IN (5,7)
        /*AND 
        (
                (pag.state = 6 AND acl.text is null) 
                OR
                acl.text IN ('Cancelled by payer','Instruction cancelled','Cancelled, Refer to payer','No account','No instruction','Payer deceased',
                                'Account closed','Instruction cancelled by payer','Invalid account type','Bank will not accept DDI on ac','Payer reference not unique')
        )*/
        -- to review:
        --and acl.text not in ('Cancelled by payer', 'Instruction cancelled', 'Cancelled, Refer to
        -- payer', 'No account','No instruction','Payer deceased','Account closed')
        --stop on bud
        AND ar.balance = 0
        AND sub.BILLED_UNTIL_DATE IS NOT NULL
        AND 
        (
                sub.END_DATE IS NULL
                OR 
                sub.end_date > sub.BILLED_UNTIL_DATE
        )
        AND prod.GLOBALID <> 'BUDDY_SUBSCRIPTION'
        AND p.PERSONTYPE NOT IN (2,6)
        AND pag.center IN (:scope)
        
	