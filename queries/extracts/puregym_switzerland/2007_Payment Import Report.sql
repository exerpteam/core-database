-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	t1.*
FROM
(
SELECT 
        cin.id AS file_id,
        cin.filename,
        (CASE cin.state 
                WHEN 1 THEN 'RECEIVED'
                WHEN 2 THEN 'VERIFIED'
                WHEN 3 THEN 'ERRORED'
                WHEN 4 THEN 'BAD'
                WHEN 5 THEN 'HANDLED'
                WHEN 6 THEN 'CONFIRMED'
                WHEN 7 THEN 'CLEANED'
                WHEN 8 THEN 'HANDLING'
        END) AS file_state,
        cin.payment_count,
        cin.total_amount,
        cin.generated_date,
        cin.received_date,
        'AUTOPLACED' AS unplaced_payment_state,
        ar.customercenter || 'p' || ar.customerid AS person_id,
        pea.txtvalue AS agilea_id,
        p.external_id,
        pr.full_reference AS exerp_reference,
        xfr_amount AS amount,
		ar.balance AS payment_account_balance,
		ear.balance AS external_debt_account_balance
FROM puregym_switzerland.clearing_in cin
LEFT JOIN puregym_switzerland.payment_requests pr ON cin.id = pr.xfr_delivery
LEFT JOIN puregym_switzerland.account_receivables ar ON pr.center = ar.center AND pr.id = ar.id
LEFT JOIN puregym_switzerland.persons p ON ar.customercenter = p.center AND ar.customerid = p.id
LEFT JOIN puregym_switzerland.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
LEFT JOIN puregym_switzerland.account_receivables ear ON p.center = ear.customercenter AND p.id = ear.customerid AND ear.ar_type = 5
WHERE
        cin.clearinghouse = 401
        AND cin.received_date >= to_date(:fromDate,'YYYY-MM-DD') 
		AND cin.received_date <= to_date(:todate,'YYYY-MM-DD') 
UNION ALL
SELECT 
        cin.id AS file_id,
        cin.filename,
        (CASE cin.state 
                WHEN 1 THEN 'RECEIVED'
                WHEN 2 THEN 'VERIFIED'
                WHEN 3 THEN 'ERRORED'
                WHEN 4 THEN 'BAD'
                WHEN 5 THEN 'HANDLED'
                WHEN 6 THEN 'CONFIRMED'
                WHEN 7 THEN 'CLEANED'
                WHEN 8 THEN 'HANDLING'
        END) AS file_state,
        cin.payment_count,
        cin.total_amount,
        cin.generated_date,
        cin.received_date,
        (CASE up.state
                WHEN 1 THEN 'NEW'
                WHEN 2 THEN 'PLACED'
                WHEN 4 THEN 'OLD'
                WHEN 5 THEN 'LENIENTLY_MATCHED'
        END) AS unplaced_payment_state,
        p.center || 'p' || p.id AS person_id,
        pea.txtvalue AS agilea_id,
        p.external_id,
        NULL AS exerp_reference,
        up.xfr_amount AS amount,
        ar.balance AS payment_account_balance,
		ear.balance AS external_debt_account_balance
FROM puregym_switzerland.unplaced_payments up
JOIN puregym_switzerland.clearing_in cin ON up.xfr_delivery = cin.id
LEFT JOIN puregym_switzerland.person_ext_attrs pea ON pea.name = '_eClub_OldSystemPersonId' AND pea.txtvalue = up.xfr_text
LEFT JOIN puregym_switzerland.persons p ON pea.personcenter = p.center AND pea.personid = p.id
LEFT JOIN puregym_switzerland.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
LEFT JOIN puregym_switzerland.account_receivables ear ON p.center = ear.customercenter AND p.id = ear.customerid AND ear.ar_type = 5
WHERE   
        cin.clearinghouse = 401
        AND cin.received_date >= to_date(:fromDate,'YYYY-MM-DD') 
		AND cin.received_date <= to_date(:todate,'YYYY-MM-DD') 
) t1
ORDER BY t1.file_id