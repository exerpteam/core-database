-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-5051
SELECT
    t."PPS Transaction ID / Reference",
    t."Transaction Date",
    t."Center",
    t."Amount",
    string_agg(t."Aggr. Transaction ID",';') AS "Aggr. Transaction ID",
    t."Entry Time",
    t."Invoice",
    t."Payment Type",
    t."Payer ID",
    t."Payer Name",
    t."Order ID/Replay ID"
FROM
    (
        WITH
            params AS materialized
            (
                SELECT
                    c.id AS center,
                    CAST(datetolongc(TO_CHAR(to_date($$from_date$$, 'YYYY-MM-DD HH24:MI:SS'),
                    'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT) AS FROM_DATE,
                    CAST(datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS')+1,
                    'YYYY-MM-DD HH24:MI:SS'), c.id)-1 AS BIGINT) AS TO_DATE
                FROM
                    centers c
            )
        SELECT DISTINCT
            cct.transaction_id                                  AS "PPS Transaction ID / Reference",
            cct.order_id                                                AS "Order ID",
            TO_CHAR(longtodateC(cct.transtime,cct.center),'MM/DD/YYYY') AS "Transaction Date",
            CASE
                WHEN act.aggregated_transaction_center IS NOT NULL
                THEN act.aggregated_transaction_center || 'agt' || act.aggregated_transaction_id
                ELSE NULL
            END                                                           AS "Aggr. Transaction ID",
            cct.center                                                           AS "Center",
            cct.amount                                                           AS "Amount",
            TO_CHAR(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS "Entry Time",
            i.center||'inv'||i.id                                                AS "Invoice",
            CASE
                WHEN crt.CRTTYPE = 1
                THEN 'CASH'
                WHEN CRTTYPE = 2
                THEN 'CHANGE'
                WHEN CRTTYPE = 3
                THEN 'RETURN ON CREDIT'
                WHEN CRTTYPE = 4
                THEN 'PAYOUT CASH'
                WHEN CRTTYPE = 5
                THEN 'PAID BY CASH AR ACCOUNT'
                WHEN CRTTYPE = 6
                THEN 'DEBIT CARD'
                WHEN CRTTYPE = 7
                THEN 'CREDIT CARD'
                WHEN CRTTYPE = 8
                THEN 'DEBIT OR CREDIT CARD'
                WHEN CRTTYPE = 9
                THEN 'GIFT CARD'
                WHEN CRTTYPE = 10
                THEN 'CASH ADJUSTMENT'
                WHEN CRTTYPE = 11
                THEN 'CASH TRANSFER'
                WHEN CRTTYPE = 12
                THEN 'PAYMENT AR'
                WHEN CRTTYPE = 13
                THEN 'CONFIG PAYMENT METHOD'
                WHEN CRTTYPE = 14
                THEN 'CASH REGISTER PAYOUT'
                WHEN CRTTYPE = 15
                THEN 'CREDIT CARD ADJUSTMENT'
                WHEN CRTTYPE = 16
                THEN 'CLOSING CASH ADJUST'
                WHEN CRTTYPE = 17
                THEN 'VOUCHER'
                WHEN CRTTYPE = 18
                THEN 'PAYOUT CREDIT CARD'
                WHEN CRTTYPE = 19
                THEN 'TRANSFER BETWEEN REGISTERS'
                WHEN CRTTYPE = 20
                THEN 'CLOSING CREDIT CARD ADJ'
                WHEN CRTTYPE = 21
                THEN 'TRANSFER BACK CASH COINS'
                WHEN CRTTYPE = 22
                THEN 'INSTALLMENT PLAN'
                WHEN CRTTYPE = 100
                THEN 'INITIAL CASH'
                WHEN CRTTYPE = 101
                THEN 'MANUAL'
                ELSE 'Undefined'
            END                             AS "Payment Type",
            i.payer_center||'p'||i.payer_id AS "Payer ID"
            ,p.fullname as "Payer Name",
            cct.order_id as "Order ID/Replay ID"
        FROM
            CREDITCARDTRANSACTIONS cct
        JOIN
            PARAMS
        ON
            params.center = cct.center
        JOIN
            CASHREGISTERTRANSACTIONS crt
        ON
            crt.GLTRANSCENTER = cct.GL_TRANS_CENTER
        AND crt.GLTRANSID = cct.GL_TRANS_ID
        AND crt.GLTRANSSUBID = cct.GL_TRANS_SUBID
        JOIN
            invoices i
        ON
            crt.PAYSESSIONID = i.PAYSESSIONID
        JOIN
            invoice_lines_mt il
        ON
            i.center = il.center
        AND i.id = il.id
        LEFT JOIN
            ACCOUNT_TRANS act
        ON
            act.CENTER = il.ACCOUNT_TRANS_CENTER
        AND act.ID = il.ACCOUNT_TRANS_ID
        AND act.SUBID = il.ACCOUNT_TRANS_SUBID
        left JOIN
            persons p
        ON
            i.payer_center = p.center
        AND i.payer_id= p.id
        WHERE
            cct.CENTER IN ($$Scope$$)
        AND cct.transtime BETWEEN params.FROM_DATE AND params.TO_DATE
        UNION ALL
        SELECT DISTINCT
            cct.transaction_id                                  AS "PPS Transaction ID / Reference",
            cct.order_id                                                AS "Order ID",
            TO_CHAR(longtodateC(cct.transtime,cct.center),'MM/DD/YYYY') AS "Transaction Date",
            CASE
                WHEN act.aggregated_transaction_center IS NOT NULL
                THEN act.aggregated_transaction_center || 'agt' || act.aggregated_transaction_id
                ELSE NULL
            END                                                           AS "Aggr. Transaction ID",
            cct.center                                                           AS "Center",
            cct.amount                                                           AS "Amount",
            TO_CHAR(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS "Entry Time",
            NULL                                                                 AS "Invoice",
            CASE
                WHEN crt.CRTTYPE = 1
                THEN 'CASH'
                WHEN CRTTYPE = 2
                THEN 'CHANGE'
                WHEN CRTTYPE = 3
                THEN 'RETURN ON CREDIT'
                WHEN CRTTYPE = 4
                THEN 'PAYOUT CASH'
                WHEN CRTTYPE = 5
                THEN 'PAID BY CASH AR ACCOUNT'
                WHEN CRTTYPE = 6
                THEN 'DEBIT CARD'
                WHEN CRTTYPE = 7
                THEN 'CREDIT CARD'
                WHEN CRTTYPE = 8
                THEN 'DEBIT OR CREDIT CARD'
                WHEN CRTTYPE = 9
                THEN 'GIFT CARD'
                WHEN CRTTYPE = 10
                THEN 'CASH ADJUSTMENT'
                WHEN CRTTYPE = 11
                THEN 'CASH TRANSFER'
                WHEN CRTTYPE = 12
                THEN 'PAYMENT AR'
                WHEN CRTTYPE = 13
                THEN 'CONFIG PAYMENT METHOD'
                WHEN CRTTYPE = 14
                THEN 'CASH REGISTER PAYOUT'
                WHEN CRTTYPE = 15
                THEN 'CREDIT CARD ADJUSTMENT'
                WHEN CRTTYPE = 16
                THEN 'CLOSING CASH ADJUST'
                WHEN CRTTYPE = 17
                THEN 'VOUCHER'
                WHEN CRTTYPE = 18
                THEN 'PAYOUT CREDIT CARD'
                WHEN CRTTYPE = 19
                THEN 'TRANSFER BETWEEN REGISTERS'
                WHEN CRTTYPE = 20
                THEN 'CLOSING CREDIT CARD ADJ'
                WHEN CRTTYPE = 21
                THEN 'TRANSFER BACK CASH COINS'
                WHEN CRTTYPE = 22
                THEN 'INSTALLMENT PLAN'
                WHEN CRTTYPE = 100
                THEN 'INITIAL CASH'
                WHEN CRTTYPE = 101
                THEN 'MANUAL'
                ELSE 'Undefined'
            END                 AS "Payment Type",
            p.center||'p'||p.id AS "Payer ID"
            ,p.fullname as "Payer Name",
            cct.order_id as "Order ID/Replay ID"
        FROM
            CREDITCARDTRANSACTIONS cct
        JOIN
            PARAMS
        ON
            params.center = cct.center
        JOIN
            CASHREGISTERTRANSACTIONS crt
        ON
            crt.GLTRANSCENTER = cct.GL_TRANS_CENTER
        AND crt.GLTRANSID = cct.GL_TRANS_ID
        AND crt.GLTRANSSUBID = cct.GL_TRANS_SUBID
        JOIN
            ar_trans art
        ON
            crt.artranscenter =art.center
        AND crt.artransid =art.id
        AND crt.artranssubid =art.subid
        JOIN
            ACCOUNT_TRANS act
        ON
            act.CENTER = art.ref_center
        AND act.ID = art.ref_id
        AND act.SUBID = art.ref_subid
        AND art.ref_type = 'ACCOUNT_TRANS'
        JOIN
            account_receivables ar
        ON
            art.CENTER = ar.center
        AND art.ID = ar.id
        JOIN
            persons p
        ON
            ar.customercenter = p.center
        AND ar.customerid= p.id
        WHERE
            cct.CENTER IN ($$Scope$$)
        AND cct.transtime BETWEEN params.FROM_DATE AND params.TO_DATE
        UNION ALL
        SELECT DISTINCT
            cct.transaction_id                                  AS "PPS Transaction ID / Reference",
            cct.order_id                                                AS "Order ID",
            TO_CHAR(longtodateC(cct.transtime,cct.center),'MM/DD/YYYY') AS "Transaction Date",
            CASE
                WHEN act.aggregated_transaction_center IS NOT NULL
                THEN act.aggregated_transaction_center || 'agt' || act.aggregated_transaction_id
                ELSE NULL
            END                                                           AS "Aggr. Transaction ID",
            cct.center                                                           AS "Center",
            cct.amount                                                           AS "Amount",
            TO_CHAR(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS "Entry Time",
            NULL                                                                 AS "Invoice",
            NULL                                                                 AS "Payment Type",
            p.center||'p'||p.id                                                  AS "Payer ID"
            ,p.fullname as "Payer Name",
            cct.order_id as "Order ID/Replay ID"
        FROM
            params,
            CREDITCARDTRANSACTIONS cct
        JOIN
            chelseapiers.account_trans act
        ON
            act.CENTER = cct.GL_TRANS_CENTER
        AND act.ID = cct.GL_TRANS_ID
        AND act.SUBID = cct.GL_TRANS_SUBID
        JOIN
            chelseapiers.ar_trans art
        ON
            art.info = cct.transaction_id
        JOIN
            account_receivables ar
        ON
            art.CENTER = ar.center
        AND art.ID = ar.id
        JOIN
            persons p
        ON
            ar.customercenter = p.center
        AND ar.customerid= p.id
        WHERE
            cct.CENTER IN ($$Scope$$)
        AND cct.transtime BETWEEN params.FROM_DATE AND params.TO_DATE ) t
GROUP BY
    t."PPS Transaction ID / Reference",
    t."Transaction Date",
    t."Center",
    t."Amount",
    t."Entry Time",
    t."Invoice",
    t."Payment Type",
    t."Payer ID",
    t."Payer Name",
    t."Order ID/Replay ID"