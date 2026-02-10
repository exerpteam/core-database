-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE(:fromdate, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS
            fromDate,
            CAST(datetolong(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')
            ) AS BIGINT) AS toDate,
            c.id         AS center_id,
            c.name       AS center_name
        FROM
            centers c
    )
    ,
    pmp_xml AS
    (
        SELECT
            sp.id,
            CAST(convert_from(sp.mimevalue, 'UTF-8') AS XML) AS pxml
        FROM
            evolutionwellness.systemproperties sp
        WHERE
            sp.globalid = 'PaymentMethodsConfig'
        AND sp.scope_id = 34
        AND sp.scope_type = 'A'
    )
    ,
    second_Table AS
    (
        SELECT
            UNNEST(xpath('attributes/attribute',px.pxml))::text AS test
        FROM
            pmp_xml px
        JOIN
            evolutionwellness.systemproperties sp
        ON
            sp.id = px.id
    )
    ,
    payment_methods AS
    (
        SELECT DISTINCT
            CAST(t.id AS INT) AS id,
            t.name AS custom_payment_method
        FROM
            (
                SELECT
                    split_part(test, '"', 2)                                      AS id,
                    trim(split_part(split_part(test, '0" name=', 2),'"',2)) AS name
                FROM
                    second_Table
                UNION ALL
                SELECT
                    split_part(test, '"', 2) AS id,
                    trim(split_part(split_part(test, '1" name=', 2),'"',2)) AS name
                FROM
                    second_Table
                UNION ALL
                SELECT
                    split_part(test, '"', 2) AS id,
                    trim(split_part(split_part(test, '2" name=', 2),'"',2)) AS name
                FROM
                    second_Table
                UNION ALL
                SELECT
                    split_part(test, '"', 2) AS id,
                    trim(split_part(split_part(test, '3" name=', 2),'"',2)) AS name
                FROM
                    second_Table
                UNION ALL
                SELECT
                    split_part(test, '"', 2) AS id,
                    trim(split_part(split_part(test, '9" name=', 2),'"',2)) AS name
                FROM
                    second_Table ) t
                WHERE
                t.name IN ('Adyen',
'BCA CREDIT CARD',
'CARD PAYMENT',
'Payment Link',
'QR PAYMENT') )
SELECT
t1.transaction_time,
CASE
WHEN t1.crttype = 'CONFIG PAYMENT METHOD'
THEN t1.custom_payment_method
ELSE t1.crttype END AS payment_method,
t1.amount,
t1.customercenter ||'p'|| t1.customerid AS member_id
FROM
(
SELECT
    longtodateC(crt.transtime, crt.center) AS transaction_time,
    CASE crt.CRTTYPE
        WHEN 1
        THEN 'CASH'
        WHEN 2
        THEN 'CHANGE'
        WHEN 3
        THEN 'RETURN ON CREDIT'
        WHEN 4
        THEN 'PAYOUT CASH'
        WHEN 5
        THEN 'PAID BY CASH AR ACCOUNT'
        WHEN 6
        THEN 'DEBIT CARD'
        WHEN 7
        THEN 'CREDIT CARD'
        WHEN 8
        THEN 'DEBIT OR CREDIT CARD'
        WHEN 9
        THEN 'GIFT CARD'
        WHEN 10
        THEN 'CASH ADJUSTMENT'
        WHEN 11
        THEN 'CASH TRANSFER'
        WHEN 12
        THEN 'PAYMENT AR'
        WHEN 13
        THEN 'CONFIG PAYMENT METHOD'
        WHEN 14
        THEN 'CASH REGISTER PAYOUT'
        WHEN 15
        THEN 'CREDIT CARD ADJUSTMENT'
        WHEN 16
        THEN 'CLOSING CASH ADJUST'
        WHEN 17
        THEN 'VOUCHER'
        WHEN 18
        THEN 'PAYOUT CREDIT CARD'
        WHEN 19
        THEN 'TRANSFER BETWEEN REGISTERS'
        WHEN 20
        THEN 'CLOSING CREDIT CARD ADJ'
        WHEN 21
        THEN 'TRANSFER BACK CASH COINS'
        WHEN 22
        THEN 'INSTALLMENT PLAN'
        WHEN 100
        THEN 'INITIAL CASH'
        WHEN 101
        THEN 'MANUAL'
        ELSE 'Undefined'
    END AS CRTTYPE,
    pm.custom_payment_method,
    crt.amount,
    crt.customercenter,
    crt.customerid,
    crt.paysessionid,
    crt.artranscenter,
    crt.artransid,
    crt.artranssubid
FROM
    evolutionwellness.cashregistertransactions crt
JOIN
    params par
ON
    par.center_id = crt.center
LEFT JOIN
payment_methods pm
ON
pm.id = crt.config_payment_method_id
WHERE
    crt.center = 352
AND crt.transtime BETWEEN par.fromdate AND par.todate ) t1
LEFT JOIN
(SELECT
inv.paysessionid,
SUM(cnl.total_amount) AS credited_amount
FROM
invoices inv
JOIN
evolutionwellness.invoice_lines_mt invl
ON
inv.center = invl.center
AND inv.id = invl.id
JOIN
evolutionwellness.credit_note_lines_mt cnl
ON
cnl.invoiceline_center = invl.center
AND cnl.invoiceline_id = invl.id
AND cnl.invoiceline_subid = invl.subid
WHERE
inv.paysessionid IS NOT NULL
AND cnl.total_amount != 0
GROUP BY
inv.paysessionid) cn
ON
cn.paysessionid = t1.paysessionid
WHERE
(cn.credited_amount IS NULL OR cn.credited_amount != t1.amount)
AND t1.amount != 0
ORDER BY
t1.transaction_time