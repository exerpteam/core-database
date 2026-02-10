-- The extract is extracted from Exerp on 2026-02-08
-- 04/01/2020 - Performnace improvement in https://clublead.atlassian.net/browse/EC-657
 WITH
     params AS
     (
         SELECT
             $$fromDate$$                      AS FromDate,
             ($$toDate$$ + 86400 * 1000) - 1 AS ToDate
         
     )
     , 
   CREDIT_NOTE_LINES AS
    (
        SELECT
            line."center",
            line."id",
            line."subid",
            line."invoiceline_center",
            line."invoiceline_id",
            line."invoiceline_subid",
            line."productcenter",
            line."productid",
            line."person_center",
            line."person_id",
            line."account_trans_center",
            line."account_trans_id",
            line."account_trans_subid",
            line."quantity",
            line."text",
            line."credit_type",
            line."canceltype",
            line."total_amount",
            line."reason",
            line."rebooking_acc_trans_center",
            line."rebooking_acc_trans_id",
            line."rebooking_acc_trans_subid",
            line."rebooking_to_center",
            line."installment_plan_id",
            line."sales_commission",
            line."sales_units",
            line."period_commission",
            line."net_amount",
            (
                SELECT
                    l.account_trans_center
                FROM
                    credit_note_line_vat_at_link l
                WHERE
                    l.credit_note_line_center = line.center
                AND l.credit_note_line_id = line.id
                AND l.credit_note_line_subid = line.subid ) AS vat_acc_trans_center,
            (
                SELECT
                    l.account_trans_subid
                FROM
                    credit_note_line_vat_at_link l
                WHERE
                    l.credit_note_line_center = line.center
                AND l.credit_note_line_id = line.id
                AND l.credit_note_line_subid = line.subid ) AS vat_acc_trans_subid,
            (
                SELECT
                    l.account_trans_id
                FROM
                    credit_note_line_vat_at_link l
                WHERE
                    l.credit_note_line_center = line.center
                AND l.credit_note_line_id = line.id
                AND l.credit_note_line_subid = line.subid ) AS vat_acc_trans_id,
            (
                SELECT
                    l.rate
                FROM
                    credit_note_line_vat_at_link l
                WHERE
                    l.credit_note_line_center = line.center
                AND l.credit_note_line_id = line.id
                AND l.credit_note_line_subid = line.subid ) AS rate
                ,
            (
                SELECT
                    l.orig_rate
                FROM
                    credit_note_line_vat_at_link l
                WHERE
                    l.credit_note_line_center = line.center
                AND l.credit_note_line_id = line.id
                AND l.credit_note_line_subid = line.subid ) AS orig_rate
        FROM
            credit_note_lines_mt line
    )
     , am AS
     (
         SELECT
             acc.name                             AS acc_name,
             art.center                           AS art_center,
             art.id                               AS art_id,
             art.subid                            AS art_subid,
             art.amount                           AS art_amount,
             COALESCE(am_paying.amount,am_paid.amount) AS am_amount,
             COALESCE(am_paying.id,am_paid.id)         AS am_id,
             art2.amount                          AS art2_amount,
             art2.text                            AS art2_text,
             art2.REF_TYPE                        AS art2_REF_TYPE,
             art2.REF_CENTER                      AS art2_REF_CENTER,
             art2.REF_ID                          AS art2_REF_ID,
             art2.REF_SUBID                       AS art2_REF_SUBID
         FROM
             ACCOUNTS acc
         CROSS JOIN
             params
         JOIN
             ACCOUNT_TRANS act
         ON
             (
                 act.DEBIT_ACCOUNTCENTER = acc.center
                 AND act.DEBIT_ACCOUNTID = acc.id )
             OR (
                 act.CREDIT_ACCOUNTCENTER = acc.center
                 AND act.CREDIT_ACCOUNTID = acc.id )
         JOIN
             AR_TRANS art
         ON
             art.REF_TYPE = 'ACCOUNT_TRANS'
             AND art.REF_CENTER = act.center
             AND art.REF_ID = act.id
             AND art.REF_SUBID = act.subid
         LEFT JOIN
             ART_MATCH am_paying
         ON
             art.amount > 0
             AND am_paying.ENTRY_TIME < params.ToDate
             AND (
                 am_paying.CANCELLED_TIME IS NULL
                 OR am_paying.CANCELLED_TIME > params.ToDate )
             AND am_paying.ART_PAYING_CENTER = art.center
             AND am_paying.ART_PAYING_id = art.id
             AND am_paying.ART_PAYING_subid = art.subid
         LEFT JOIN
             ART_MATCH am_paid
         ON
             art.amount <0
             AND am_paid.ENTRY_TIME < params.ToDate
             AND (
                 am_paid.CANCELLED_TIME IS NULL
                 OR am_paid.CANCELLED_TIME > params.ToDate )
             AND am_paid.ART_PAID_CENTER = art.center
             AND am_paid.ART_PAID_id = art.id
             AND am_paid.ART_PAID_subid = art.subid
         LEFT JOIN
             --cash account transactions that have been moved to payment account
             AR_TRANS art2
         ON
             (
                 art.amount > 0
                 AND am_paying.ART_PAID_CENTER = art2.center
                 AND am_paying.ART_PAID_ID = art2.id
                 AND am_paying.ART_PAID_SUBID = art2.subid)
             OR (
                 art.amount < 0
                 AND am_paid.ART_PAYING_CENTER = art2.center
                 AND am_paid.ART_PAYING_ID = art2.id
                 AND am_paid.ART_PAYING_SUBID = art2.subid)
         WHERE
             acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT',
                              'BANK_ACCOUNT_WEB',
                              'PAYTEL',
                              'BANK_ACCOUNT_PT_CASH')
             AND act.ENTRY_TIME >= params.FromDate
             AND act.ENTRY_TIME < params.ToDate
             AND act.amount <> 0
     )
 SELECT
     /*+ NO_BIND_AWARE */
     (
         SELECT
             c.EXTERNAL_ID
         FROM
             centers c
         WHERE
             c.id = center) AS CostCenter,
     (
         SELECT
             c.name
         FROM
             centers c
         WHERE
             c.id = center) AS Site,
     type,
     account,
     TRANS_TYPE,
     text,
     SUM(VAT)    AS VAT,
     SUM( TOTAL) AS TOTAL
 FROM
     (
         SELECT
             am.art_center AS center,
             am.acc_name   AS account,
             CASE
                 WHEN (am.art_amount > 0)
                 THEN 'PAYMENT'
                 ELSE 'REFUND'
             END              AS type,
             am.art2_ref_type AS TRANS_TYPE,
             CASE
                 WHEN (il.center IS NOT NULL )
                 THEN
                     CASE
                         WHEN position (':' IN il.text) > 0
                         THEN SUBSTR(il.text,1,position(':' IN il.text)-1)
                         ELSE il.text
                     END
                 WHEN (cl.center IS NOT NULL )
                 THEN
                     CASE
                         WHEN position (':' in cl.text) > 0
                         THEN SUBSTR(cl.text,1,position(':' in cl.text)-1)
                         ELSE cl.text
                     END
                 ELSE
                     CASE
                         WHEN (am.art2_text LIKE 'Deduction 20%')
                         THEN 'Converted Harlands'
                             -- WHEN (acc.name LIKE 'Debt to %')
                             --THEN 'Cross center'
                         WHEN (acc2.name IS NOT NULL)
                         THEN acc2.name
                         ELSE am.art2_text
                     END
             END AS text,
             CASE
                     --when art2.amount = 0 then 0
                 WHEN (il.center IS NOT NULL )
                 THEN
                     CASE
                         WHEN (am.am_amount = am.art2_amount)
                         THEN vat.amount
                             -- in the case the amount is a match for only part of the
                             -- invoice line,
                             -- we need to make it proportianal
                         ELSE ROUND(am.am_amount*vat.amount/ABS(am.art2_amount),2)
                     END
                 WHEN (cl.center IS NOT NULL )
                 THEN
                     CASE
                         WHEN (am.am_amount = am.art2_amount)
                         THEN vat.amount
                             -- same as for invoice lines
                         ELSE ROUND(am.am_amount*vat.amount/ABS(am.art2_amount),2)
                     END
                 ELSE 0
             END AS VAT,
             CASE
                     --when art2.amount = 0 then 0
                 WHEN (il.center IS NOT NULL )
                 THEN
                     CASE
                         WHEN (am.am_amount = am.art2_amount)
                         THEN il.total_amount
                             -- in the case the amount is a match for only part of the
                             -- invoice line,
                             -- we need to make it proportianal
                         ELSE ROUND(am.am_amount*il.total_amount/ABS(am.art2_amount),2)
                     END
                 WHEN (cl.center IS NOT NULL )
                 THEN
                     CASE
                         WHEN (am.am_amount = am.art2_amount)
                         THEN -cl.total_amount
                             -- same as for invoice lines
                         ELSE -ROUND(am.am_amount*cl.total_amount/ABS(am.art2_amount),2)
                     END
                 ELSE SIGN(am.art_amount) * COALESCE(am.am_amount,0)
             END AS TOTAL
         FROM
             am
         LEFT JOIN
             INVOICELINES il
         ON
             am.art2_REF_TYPE = 'INVOICE'
             AND am.art2_REF_CENTER = il.center
             AND am.art2_REF_ID = il.id
         LEFT JOIN
             CREDIT_NOTE_LINES cl
         ON
             (
                 am.art2_REF_TYPE = 'CREDIT_NOTE'
                 AND am.art2_REF_CENTER = cl.center
                 AND am.art2_REF_ID = cl.id )
         LEFT JOIN
             ACCOUNT_TRANS vat
         ON
             (
                 cl.center IS NOT NULL
                 AND vat.center = cl.VAT_ACC_TRANS_CENTER
                 AND vat.id = cl.VAT_ACC_TRANS_ID
                 AND vat.subid = cl.VAT_ACC_TRANS_SUBID )
             OR (
                 il.center IS NOT NULL
                 AND vat.center = il.VAT_ACC_TRANS_CENTER
                 AND vat.id = il.VAT_ACC_TRANS_ID
                 AND vat.subid = il.VAT_ACC_TRANS_SUBID )
         LEFT JOIN
             ACCOUNT_TRANS act2
         ON
             (
                 il.ACCOUNT_TRANS_CENTER IS NOT NULL
                 AND act2.center = il.ACCOUNT_TRANS_CENTER
                 AND act2.id = il.ACCOUNT_TRANS_ID
                 AND act2.subid = il.ACCOUNT_TRANS_SUBID )
             OR (
                 cl.ACCOUNT_TRANS_CENTER IS NOT NULL
                 AND act2.center = cl.ACCOUNT_TRANS_CENTER
                 AND act2.id = cl.ACCOUNT_TRANS_ID
                 AND act2.subid = cl.ACCOUNT_TRANS_SUBID )
             OR (
                 il.ACCOUNT_TRANS_CENTER IS NULL
                 AND cl.ACCOUNT_TRANS_CENTER IS NULL
                 AND am.art2_REF_TYPE = 'ACCOUNT_TRANS'
                 AND am.art2_REF_CENTER = act2.center
                 AND am.art2_REF_ID = act2.id
                 AND am.art2_REF_SUBID = act2.subid )
         LEFT JOIN
             ACCOUNTS acc2
         ON
             ( (
                     am.art2_amount > 0
                     AND act2.DEBIT_ACCOUNTCENTER = acc2.CENTER
                     AND act2.DEBIT_ACCOUNTID = acc2.ID )
                 OR (
                     am.art2_amount < 0
                     AND act2.CREDIT_ACCOUNTCENTER = acc2.CENTER
                     AND act2.CREDIT_ACCOUNTID = acc2.ID))
         WHERE
             am.am_ID IS NOT NULL
     ) t
 GROUP BY
     center,
     account,
     type,
     trans_type,
     text
 -- The transactions where settlements are not entirely done
 UNION ALL
 SELECT
     (
         SELECT
             c.EXTERNAL_ID
         FROM
             centers c
         WHERE
             c.id = center) AS CostCenter,
     (
         SELECT
             c.name
         FROM
             centers c
         WHERE
             c.id = center) AS Site,
     TYPE,
     account     AS ACCOUNT,
     'N/A'       AS trans_type,
     'N/A'       AS text,
     0           AS VAT,
     SUM(AMOUNT) AS AMOUNT
 FROM
     (
         SELECT
             am.art_center AS center,
             am.art_id     AS id,
             am.art_subid  AS subid,
             am.acc_name   AS account,
             CASE
                 WHEN (am.art_amount > 0 )
                 THEN 'PREPAYMENT'
                 ELSE 'WITHDRAWAL'
             END AS TYPE,
             CASE
                 WHEN am.art_amount > 0
                 THEN am.art_amount - SUM(COALESCE(am.am_amount,0))
                 ELSE am.art_amount + SUM(COALESCE(am.am_amount,0))
             END AS amount
         FROM
             am
         CROSS JOIN
             params
         GROUP BY
             am.acc_name,
             am.art_center,
             am.art_id,
             am.art_subid,
             am.art_amount
         HAVING
             ABS(am.art_amount) <> SUM(COALESCE(am.am_amount,0)) ) t1
 GROUP BY
     center,
     TYPE,
     account
