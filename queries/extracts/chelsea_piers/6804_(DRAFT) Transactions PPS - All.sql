WITH
    ex1 AS
    (
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
            t."Payer Name"
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
                    cct.transaction_id                          AS "PPS Transaction ID / Reference",
                    cct.order_id                                                AS "Order ID",
                    TO_CHAR(longtodateC(cct.transtime,cct.center),'MM/DD/YYYY') AS
                    "Transaction Date",
                    CASE
                        WHEN act.aggregated_transaction_center IS NOT NULL
                        THEN act.aggregated_transaction_center || 'agt' ||
                            act.aggregated_transaction_id
                        ELSE NULL
                    END                                                   AS "Aggr. Transaction ID",
                    cct.center                                                          AS "Center",
                    cct.amount                                                          AS "Amount",
                    TO_CHAR(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS
                    "Entry Time",
                    i.center||'inv'||i.id AS "Invoice",
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
                    p.external_id AS "Payer ID",
                    p.fullname                      AS "Payer Name"
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
                JOIN
                    persons p
                ON
                    i.payer_center = p.center
                AND i.payer_id= p.id
                WHERE
                    cct.CENTER IN ($$Scope$$)
                AND cct.transtime BETWEEN params.FROM_DATE AND params.TO_DATE
                UNION ALL
                SELECT DISTINCT
                    cct.transaction_id                          AS "PPS Transaction ID / Reference",
                    cct.order_id                                                AS "Order ID",
                    TO_CHAR(longtodateC(cct.transtime,cct.center),'MM/DD/YYYY') AS
                    "Transaction Date",
                    CASE
                        WHEN act.aggregated_transaction_center IS NOT NULL
                        THEN act.aggregated_transaction_center || 'agt' ||
                            act.aggregated_transaction_id
                        ELSE NULL
                    END                                                   AS "Aggr. Transaction ID",
                    cct.center                                                          AS "Center",
                    cct.amount                                                          AS "Amount",
                    TO_CHAR(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS
                    "Entry Time",
                    NULL AS "Invoice",
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
                    p.center||'p'||p.id AS "Payer ID" ,
                    p.fullname          AS "Payer Name"
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
                    cct.transaction_id                          AS "PPS Transaction ID / Reference",
                    cct.order_id                                                AS "Order ID",
                    TO_CHAR(longtodateC(cct.transtime,cct.center),'MM/DD/YYYY') AS
                    "Transaction Date",
                    CASE
                        WHEN act.aggregated_transaction_center IS NOT NULL
                        THEN act.aggregated_transaction_center || 'agt' ||
                            act.aggregated_transaction_id
                        ELSE NULL
                    END                                                   AS "Aggr. Transaction ID",
                    cct.center                                                          AS "Center",
                    cct.amount                                                          AS "Amount",
                    TO_CHAR(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS
                    "Entry Time",
                    NULL                AS "Invoice",
                    NULL                AS "Payment Type",
                    p.external_id AS "Payer ID",
                    p.fullname          AS "Payer Name"
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
            t."Payer Name"
    )
    ,
    ex2 AS
    (
        WITH
            params AS materialized
            (
                SELECT
                    c.id                    AS center,
                    CAST($$from_date$$ AS DATE)   AS FROM_DATE,
                    CAST($$to_date$$ AS DATE)+1 AS TO_DATE
                FROM
                    centers c
            )
        SELECT
            pr.center                    AS "Center",
            pr.full_reference            AS "Exerp Reference",
            pr.clearinghouse_payment_ref AS "PPS Reference",
            CASE
                WHEN REQUEST_TYPE = 1
                THEN 'Payment'
                WHEN REQUEST_TYPE = 2
                THEN 'Debt Collection'
                WHEN REQUEST_TYPE = 3
                THEN 'Reversal'
                WHEN REQUEST_TYPE = 4
                THEN 'Reminder'
                WHEN REQUEST_TYPE = 5
                THEN 'Refund'
                WHEN REQUEST_TYPE = 6
                THEN 'Representation'
                WHEN REQUEST_TYPE = 7
                THEN 'Legacy'
                WHEN REQUEST_TYPE = 8
                THEN 'Zero'
                WHEN REQUEST_TYPE = 9
                THEN 'Service Charge'
                ELSE 'Undefined'
            END AS "Request Type",
            CASE
                WHEN pr.STATE = 1
                THEN 'New'
                WHEN pr.STATE = 2
                THEN 'Sent'
                WHEN pr.STATE = 3
                THEN 'Done'
                WHEN pr.STATE = 4
                THEN 'Done, manual'
                WHEN pr.STATE = 5
                THEN 'Rejected, clearinghouse'
                WHEN pr.STATE = 6
                THEN 'Rejected, bank'
                WHEN pr.STATE = 7
                THEN 'Rejected, debtor'
                WHEN pr.STATE = 8
                THEN 'Cancelled'
                WHEN pr.STATE = 10
                THEN 'Reversed, new'
                WHEN pr.STATE = 11
                THEN 'Reversed , sent'
                WHEN pr.STATE = 12
                THEN 'Failed, not creditor'
                WHEN pr.STATE = 13
                THEN 'Reversed, rejected'
                WHEN pr.STATE = 14
                THEN 'Reversed, confirmed'
                WHEN pr.STATE = 17
                THEN 'Failed, payment revoked'
                WHEN pr.STATE = 18
                THEN 'Done Partial'
                WHEN pr.STATE = 19
                THEN 'Failed, Unsupported'
                WHEN pr.STATE = 20
                THEN 'Require approval'
                WHEN pr.STATE = 21
                THEN 'Fail, debt case exists'
                WHEN pr.STATE = 22
                THEN 'Failed, timed out'
                ELSE 'Undefined'
            END                                                                 AS "Request State",
            TO_CHAR(pr.due_date,'MM/DD/YYYY')                                   AS "Due Date",
            TO_CHAR(longtodateC(pr.entry_time, pr.center),'MM/DD/YYYY HH24:MI') AS "Entry Time",
            pr.req_amount                                                       AS "Amount",
            pr.creditor_id                                                      AS "Creditor ID",
            pr.uuid                                                             AS "UUID",
            pr.xfr_info                                                         AS "Status",
            p.external_id AS "Payer ID"
        FROM
            PAYMENT_REQUESTS pr
        JOIN
            PARAMS
        ON
            params.center = pr.center
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.center = pr.center
        AND ar.id = pr.id
        AND ar.AR_TYPE = 4
        join persons p on p.center = ar.customercenter and p.id=ar.customerid
        WHERE
            pr.clearinghouse_id <> 201 -- exclude invoices
        AND pr.CENTER IN ($$Scope$$)
        AND pr.due_date >= params.FROM_DATE
        AND pr.due_date < params.TO_DATE
        AND pr.state IN (3,4) -- Done and Manual
    )
    ,
    ex3 AS
    (
        SELECT
            t."PPS Transaction ID / Reference",
            t."Transaction Date",
            t."Center",
            t."Amount",
            string_agg(t."Aggr. Transaction ID",';') AS "Aggr. Transaction ID",
            t."Entry Time",
            t."Invoice",
            t."Owner ID",
            t."Person External ID",
            t."Payment Type",
            t."Payer ID"
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
                    crt.coment                                  AS "PPS Transaction ID / Reference",
                    TO_CHAR(longtodateC(crt.transtime,crt.center),'MM/DD/YYYY') AS
                    "Transaction Date",
                    crt.center AS "Center",
                    crt.amount AS "Amount",
                    CASE
                        WHEN act.aggregated_transaction_center IS NOT NULL
                        THEN act.aggregated_transaction_center || 'agt' ||
                            act.aggregated_transaction_id
                        ELSE NULL
                    END                                                   AS "Aggr. Transaction ID",
                    TO_CHAR(longtodateC(act.entry_time,act.center),'MM/DD/YYYY HH24:MI') AS
                    "Entry Time",
                    i.center||'inv'||i.id               AS "Invoice",
                    il.person_center||'p'||il.person_id AS "Owner ID",
                    p.external_id                       AS "Person External ID",
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
                    p.external_id AS "Payer ID"
                FROM
                    CASHREGISTERTRANSACTIONS crt
                JOIN
                    PARAMS
                ON
                    params.center = crt.center
                JOIN
                    CASHREGISTERS cr
                ON
                    cr.center = crt.center
                AND cr.id = crt.id
                AND cr.type = 'WEB'
                LEFT JOIN
                    invoices i
                ON
                    crt.PAYSESSIONID = i.PAYSESSIONID
                LEFT JOIN
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
                LEFT JOIN
                    persons p
                ON
                    il.person_center = p.center
                AND il.person_id = p.id
                WHERE
                    crt.coment IS NOT NULL
                AND crt.CENTER IN ($$Scope$$)
                AND crt.transtime BETWEEN params.FROM_DATE AND params.TO_DATE
                AND crt.crttype = 13 ) t
        GROUP BY
            t."PPS Transaction ID / Reference",
            t."Transaction Date",
            t."Center",
            t."Amount",
            t."Entry Time",
            t."Invoice",
            t."Owner ID",
            t."Person External ID",
            t."Payment Type",
            t."Payer ID"
    ),
    unioned AS
    (
        SELECT
            "PPS Transaction ID / Reference"
            , "Payer ID"
        FROM
            ex1
        UNION ALL
        SELECT
            "Exerp Reference", "Payer ID"
        FROM
            ex2
        UNION ALL
        SELECT
            "PPS Transaction ID / Reference", "Payer ID"
        FROM
            ex3
    )
    select * from unioned