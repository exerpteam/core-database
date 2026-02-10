-- The extract is extracted from Exerp on 2026-02-08
-- Morning Journals
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
            c.id                                                                     AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'),
            'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
    )
    SELECT
    *
    FROM
    (
SELECT
    longtodatec(art.trans_time,art.center) AS "Date",
    art.info                               AS "Receipt Number",
    per.center||'p'|| per.id               AS "Exerp ID",
    c.name                                 AS "Location",
    per.fullname                           AS "Member Name",
    art.amount                             AS "Amount",
    'Debt Payment'                         AS "Purchase Type", -- 'Online Join', 'Online Shop', 'Debt Payment', 'Online Transaction'
    'Debt Payment'                         AS "Purchase information",
    email.txtvalue AS "Email"
FROM
    ar_trans art
JOIN
    account_trans act
ON
    act.center = art.ref_center
AND act.id = art.ref_id
AND act.subid = art.ref_subid
JOIN
    account_receivables ar
ON
    ar.center = art.center
AND ar.id = art.id
JOIN
    persons per
ON
    per.center = ar.customercenter
AND per.id = ar.customerid
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = per.center
AND email.personid = per.id
AND email.name = '_eClub_Email'
JOIN
    centers c
ON
    c.id = art.center
JOIN
    params
ON
    params.center_id = c.id
WHERE
    art.employeecenter = 100
AND art.employeeid = 19603
AND art.ref_type = 'ACCOUNT_TRANS'
AND art.amount > 0
AND art.trans_time BETWEEN params.FromDate AND params.ToDate
UNION ALL
SELECT
	longtodatec(inv.trans_time,inv.center) AS "Date",
    crt.coment                             AS "Receipt Number",
    inv.payer_center||'p'|| inv.payer_id   AS "Exerp ID",
    c.name                                 AS "Location",
    per.fullname                           AS "Member Name",
    invl.total_amount                      AS "Amount",
    CASE
        WHEN pr.ptype = 10
        THEN 'Online Join'
		WHEN pr.ptype = 7
        THEN 'Online Transaction'
        ELSE 'Online Shop'
    END            AS "Purchase Type", -- 'Online Join', 'Online Shop', 'Debt Payment', 'Online Transaction'
    invl.text      AS "Purchase information",
    email.txtvalue AS "Email"
FROM
    invoices inv
JOIN
    invoice_lines_mt invl
ON
    inv.center = invl.center
AND inv.id = invl.id
JOIN
    products pr
ON
    pr.center = invl.productcenter
AND pr.id = invl.productid
JOIN
    centers c
ON
    c.id = inv.center
JOIN
    persons per
ON
    per.center = inv.payer_center
AND per.id = inv.payer_id
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter = per.center
AND email.personid = per.id
AND email.name = '_eClub_Email'
LEFT JOIN
    cashregistertransactions crt
ON
    inv.paysessionid = crt.paysessionid
AND inv.cashregister_center = crt.center
AND inv.cashregister_id = crt.id
JOIN
    params
ON
    params.center_id = c.id
WHERE
    inv.employee_center = 100
AND inv.employee_id = 19603
AND invl.total_amount != 0
AND inv.trans_time BETWEEN params.FromDate AND params.ToDate ) t
WHERE
"Receipt Number" IS NOT NULL
AND "Receipt Number" != 'noExternalPaymentHappened'