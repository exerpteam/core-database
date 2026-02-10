-- The extract is extracted from Exerp on 2026-02-08
--  
/*
Aim: this report should copy AR Balance report without aggregating transactions
ARBalance report seems to simply sum up all transactions based on trans_time <= cut_off on accounts
To get to the same result this extract takes transactions !=0, with trans_time <= cut_off,
then checks if they have been settled. If yes it checks if they have been settled with a
transaction with
trans_time > cut_off, if yes then the settled amount is again added to the unsettled_amount of the
original transaction
*/
WITH
    params AS materialized
    (
        SELECT
            getendofday((:cut_off)::DATE::VARCHAR, 100)                             AS cut_off_date,
            getendofday(((:cut_off)::DATE - interval '1' YEAR)::DATE::VARCHAR, 100) AS
            year_ago_date
    )
    ,
    report AS materialized
    (
        SELECT
            p.center AS "Center",
            CASE ar.AR_TYPE
                WHEN 1
                THEN 'Cash'
                WHEN 4
                THEN 'Payment'
                WHEN 5
                THEN 'Debt'
                WHEN 6
                THEN 'installment'
            END                 AS "Account type" ,
            p.center||'p'||p.id AS "Member ID",
            p.external_id       AS "External ID",
            ext.txtvalue        AS "Old member ID",
            p.fullname          AS "Name",
            art.unsettled_amount - COALESCE( SUM(
                CASE
                    WHEN art_paying.TRANS_TIME > params.cut_off_date
                    THEN art_match_paying.amount
                    ELSE NULL
                END), 0) + COALESCE( SUM(
                CASE
                    WHEN art_paid.TRANS_TIME > params.cut_off_date
                    THEN art_match_paid.amount
                    ELSE NULL
                END), 0 ) AS "Open amount",
            art.Amount    AS "Full amount",
            art.text      AS art_text,
            ar.ar_type,
            ar.customercenter,
            ar.customerid,
            art.text,
            art.ref_center,
            art.ref_id,
            art.ref_subid,
            art.ref_type,
            art.center,
            art.id,
            art.subid,
            art.amount,
            art.unsettled_amount,
            params.cut_off_date
        FROM
            ACCOUNT_RECEIVABLES ar
        CROSS JOIN
            params
        JOIN
            PERSONS p
        ON
            ar.customerCENTER = p.CENTER
        AND ar.customerID = p.ID
        JOIN
            AR_TRANS AS ART
        ON
            art.center=ar.center
        AND art.id=ar.id
        LEFT JOIN
            art_match art_match_paying
        ON
            art.center=art_match_paying.art_paid_center
        AND art.id=art_match_paying.art_paid_id
        AND art.subid=art_match_paying.art_paid_subid
        AND art_match_paying.cancelled_time IS NULL
        LEFT JOIN
            AR_TRANS art_paying
        ON
            art_match_paying.art_paying_center=art_paying.center
        AND art_match_paying.art_paying_id=art_paying.id
        AND art_match_paying.art_paying_subid=art_paying.subid
        LEFT JOIN
            art_match art_match_paid
        ON
            art.center =art_match_paid.art_paying_center
        AND art.id=art_match_paid.art_paying_id
        AND art.subid=art_match_paid.art_paying_subid
        AND art_match_paid.cancelled_time IS NULL
        LEFT JOIN
            AR_TRANS art_paid
        ON
            art_match_paid.art_paid_center =art_paid.center
        AND art_match_paid.art_paid_id=art_paid.id
        AND art_match_paid.art_paid_subid=art_paid.subid
        LEFT JOIN
            person_ext_attrs ext
        ON
            ext.personcenter = ar.customercenter
        AND ext.personid = ar.customerid
        AND ext.name = '_eClub_OldSystemPersonId'
        LEFT JOIN
            puregym_switzerland.invoices i
        ON
            art.ref_center = i.center
        AND art.ref_id = i.id
        AND art.ref_type = 'INVOICE'
        WHERE
            ART.TRANS_TIME <= params.cut_off_date
        AND ( (
                    art_match_paying IS NULL
                AND art_match_paid IS NULL )
            OR  (
                    art_paying.TRANS_TIME > params.cut_off_date
                OR  art_paid.TRANS_TIME > params.cut_off_date )
            OR  art.unsettled_amount != 0 )
        AND ar.CENTER IN (:scope)
        AND ar.ar_type IN (1,
                           4,
                           5)
        AND (
                ar.BALANCE != 0
            OR  ar.LAST_ENTRY_TIME >= params.year_ago_date )
        AND art.amount != 0
            -- AND p.center||'p'||p.id='6004p1689'
            --  AND p.center||'p'||p.id='6004p1454'
            -- AND p.center||'p'||p.id= '6009p2324'
        GROUP BY
            ar.AR_TYPE ,
            art.center,
            art.id,
            art.subid,
            art.text,
            p.center,
            p.id,
            p.external_id,
            ext.txtvalue,
            i.text,
            ar.ar_type,
            ar.customercenter,
            ar.customerid,
            art.text,
            art.ref_center,
            art.ref_id,
            art.ref_subid,
            art.ref_type,
            art.center,
            art.id,
            art.subid,
            art.amount,
            params.cut_off_date
        ORDER BY
            p.center,
            p.id,
            ar.AR_TYPE
    )
--SELECT * FROM   report;
SELECT
    r."Center",
    r."Account type" ,
    r."Member ID",
    r."External ID",
    r."Old member ID",
    r."Name",
    CASE
        WHEN art_paid_payacc.text IS NULL
        THEN r."Open amount"
            ----------------------------------------------------------------------------------------
            --------when it is a transfer from pay acc to debt acc, it could potentially be
            -- aggregated- this means when unaggregating the amount and in case it is partially
            -- settled
            ----we need to settled it by ratio and then as a last step we use window function to
            -- remove rounding issues
            ------so in case we are cents off after rounding this is added back to the largest
            -- amount amongst the transactions involved
            -------------------------------------------------------------------------------------------------------------------------
        ELSE ROUND(((-1 * am_payacc.amount)/r.amount) * r."Open amount", 2) +
            CASE
                WHEN rOW_NUMBER() OVER (PARTITION BY r.center, r.id, r.subid ORDER BY
                    art_paid_payacc.amount) = 1
                THEN r."Open amount" + SUM(ROUND((am_payacc.amount/r.amount) * r."Open amount" , 2)
                    ) OVER (PARTITION BY r.center, r.id, r.subid)
                ELSE 0
            END
    END AS "Open amount",
    CASE
        WHEN art_paid_payacc.text IS NULL
        THEN r."Full amount"
        ELSE art_paid_payacc.amount
    END AS "Full amount",
    CASE
        WHEN art_paid_payacc.text IS NULL
        THEN r.art_text
        ELSE art_paid_payacc.text
    END AS "Text",
    CASE
        WHEN (CASE
        WHEN art_paid_payacc.text IS NULL
        THEN r.art_text
        ELSE art_paid_payacc.text
    END) like '%Converted subscription invoice%'
        THEN 'Y'
        ELSE 'N'
    END AS "Migrated"
FROM
    report r
    -------------------------------------------------------------------------------------------
    --------fetching orgiginal transaction text from --transfer to debt account-- charges
    -----------------------------------------------------------------------------------------
LEFT JOIN
    account_receivables ar_payacc
ON
    ar_payacc.customercenter=r.customercenter
AND ar_payacc.customerid=r.customerid
AND r.ar_type=5
AND ar_payacc.ar_type=4
AND r.text LIKE 'TransferToCashCollectionAccount%'
LEFT JOIN
    ar_trans art_payacc
ON
    art_payacc.center= ar_payacc.center
AND art_payacc.id=ar_payacc.id
AND r.ref_center=art_payacc.ref_center
AND r.ref_id=art_payacc.ref_id
AND r.ref_subid=art_payacc.ref_subid
LEFT JOIN
    art_match am_payacc
ON
    am_payacc.art_paying_center= art_payacc.center
AND am_payacc.art_paying_id=art_payacc.id
AND am_payacc.art_paying_subid=art_payacc.subid
AND am_payacc.entry_time <= r.cut_off_date
LEFT JOIN
    ar_trans art_paid_payacc
ON
    am_payacc.art_paid_center= art_paid_payacc.center
AND am_payacc.art_paid_id=art_paid_payacc.id
AND am_payacc.art_paid_subid=art_paid_payacc.subid