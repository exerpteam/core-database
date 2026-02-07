-- This is the version from 2026-02-05
--  
WITH
    params AS materialized
    (
        SELECT
            getstartofday(TO_CHAR(TO_DATE(:from_date,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS fromDate,
            getendofday(TO_CHAR(TO_DATE(:to_date,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id)     AS toDate,
     
            c.id,
            pr.price  AS product_price,
            pr.center AS pr_center ,
            pr.id     AS pr_id
        FROM
            centers c
        JOIN
            products pr
        ON
            pr.center=c.id
        WHERE c.id in (:scope) and 
         pr.globalid= :product
    )
    ,
    paid_trans AS materialized
    (
        SELECT
            artm.amount AS "Settled amount",
            art_paid.ref_center,
            art_paid.ref_id,
            art_paying.ref_id AS paying_ref_id,
            --  art_paying.ref_type   AS paying_ref_type,
            art_paying.ref_center AS paying_ref_center,
            art_paying.ref_subid  AS paying_ref_subid,
            art_paying.center     AS art_paying_center,
            art_paying.id         AS art_paying_id,
            art_paying.subid      AS art_paying_subid,
            ti.pr_center,
            ti.pr_id
        FROM
            ar_trans art_paying
        JOIN
            params ti
        ON
            ti.id=art_paying.center
        JOIN
            art_match artm
        ON
            art_paying.center = artm.art_paying_center
        AND art_paying.id = artm.art_paying_id
        AND art_paying.subid = artm.art_paying_subid
        JOIN
            ar_trans art_paid
        ON
            art_paid.center = artm.art_paid_center
        AND art_paid.id = artm.art_paid_id
        AND art_paid.subid = artm.art_paid_subid
        WHERE
            artm.cancelled_time IS NULL
        AND art_paying.entry_time >= ti.fromDate
        AND art_paying.entry_time < ti.toDate
        AND art_paid.ref_type = 'INVOICE'
        AND artm.amount <= ti.product_price
        AND art_paying.text NOT LIKE 'TransferToCashCollectionAccount%'
        AND art_paying.ref_type= 'ACCOUNT_TRANS'
    )
    ,
    invoiced_trans AS materialized
    (
        SELECT
            i.center,
            i.id,
            i.text  AS inv_text,
            il.text AS il_text,
            paying_ref_center,
            paying_ref_id,
            paying_ref_subid,
            art_paying_center,
            art_paying_id,
            art_paying_subid,
            "Settled amount"
        FROM
            paid_trans
        JOIN
            invoices i
        ON
            i.center=paid_trans.ref_center
        AND i.id=paid_trans.ref_id
        JOIN
            invoice_lines_mt il
        ON
            il.productcenter = paid_trans.pr_center
        AND il.productid = paid_trans.pr_id
        AND il.center=i.center
        AND il.id=i.id
 
    )
    ,
    dataset AS materialized
    (
        SELECT
            c.external_id AS "Cost center",
            c.name        AS "Site",
            "Settled amount",
            COALESCE(ac2.external_id, ac.external_id) AS "Account ID",
            COALESCE(ac2.name, ac.name)               AS "Account name",
            CASE
                WHEN act.INFO_TYPE = 3
                AND act.text like '%FI-kort%'
                THEN 'Direct Debit - FI-kort'
                WHEN act.INFO_TYPE = 3
                THEN 'Direct Debit - bank bet.'
                WHEN ac.external_id = '6746'
                OR  act.INFO_TYPE = 23
                THEN 'Debt'
                WHEN crt.crttype = 7
                OR  act.INFO_TYPE = 16
                THEN 'POS'
                WHEN crt.crttype = 1
                THEN 'Cash'
                ELSE 'Other'
            END AS "Payment type",
            act.text "Payment text", act.INFO_TYPE
        FROM
            invoiced_trans trans
        JOIN
            ACCOUNT_TRANS act
        ON
            trans.paying_ref_center=act.center
        AND trans.paying_ref_id=act.id
        AND trans.paying_ref_subid=act.subid
        JOIN
            accounts ac
        ON
            act.debit_accountcenter=ac.center
        AND act.debit_accountid=ac.id
        JOIN
            centers c
        ON
            act.center =c.id
        LEFT JOIN
            fw.cashregistertransactions crt
        ON
            trans.art_paying_center=crt.artranscenter
        AND trans.art_paying_id=crt.artransid
        AND trans.art_paying_subid=crt.artranssubid
        LEFT JOIN
            ACCOUNT_TRANS act2
        ON
            trans.paying_ref_center=act2.debit_transaction_center
        AND trans.paying_ref_id=act2.debit_transaction_id
        AND trans.paying_ref_subid=act2.debit_transaction_subid
        LEFT JOIN
            accounts ac2
        ON
            act2.debit_accountcenter=ac2.center
        AND act2.debit_accountid=ac2.id
        WHERE
            ----filtering out transfers as they aren't payments---
            act.info NOT IN ('Transfer')
    )
--SELECT  * FROM  dataset;

SELECT
"Payment type",
SUM("Settled amount") AS "Total settled amount",

 count(*) as "Count of Payment Type"

FROM
dataset
GROUP BY
"Payment type"

