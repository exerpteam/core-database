-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/DEV-38810
WITH
    params AS
    (
        SELECT
            COALESCE(rp.END_DATE,pr.cutdate)                                                                                                                AS CutDate,
            COALESCE(CAST(extract(epoch FROM timezone('Europe/London',CAST(rp.end_date + interval '1 day' AS TIMESTAMP))) AS bigint)*1000 - 1, pr.eod_long)              AS CutDateLong,
            COALESCE(rp.CLOSE_TIME,pr.eod_long)                                                                                                                          AS CloseLong,
            COALESCE(rp.HARD_CLOSE_TIME,pr.eod_long)                                                                                                                     AS HardCloseLong,
            COALESCE(CAST(extract(epoch FROM timezone('Europe/London',CAST(rp.end_date + interval '1 day' AS TIMESTAMP))) AS bigint)*1000 - 1,pr.eod_long) - 31622400000 AS LAST_ENTRY_TIME
        FROM
            (
                SELECT
                    CAST($$for_date$$ AS DATE)                                                                                                           AS cutdate,
                    CAST(extract(epoch FROM timezone('Europe/London',CAST( CAST($$for_date$$ AS DATE) + interval '1 day' AS TIMESTAMP))) AS bigint)*1000 AS eod_long ) pr
        LEFT JOIN
            leejam.REPORT_PERIODS rp
        ON
            rp.end_date = CAST($$for_date$$ AS DATE) AND rp.SCOPE_ID = 2
    )
    ,
    art_open_amount AS
    (
        SELECT
            art_paid.CENTER,
            art_paid.ID,
            art_paid.SUBID,
            art_paid.payreq_spec_center,
            art_paid.payreq_spec_id,
            art_paid.payreq_spec_subid,
            art_paid.collected,
            art_paid.AMOUNT,
            floor(months_between(params.CutDate, timezone('Europe/Rome',to_timestamp (art_paid.TRANS_TIME/1000))::DATE)) AS AGE_MONTHS, --Debt age is between cut_date and
            -- trans_time
            ROUND( art_paid.AMOUNT * COALESCE(1- SUM(st.AMOUNT) /ABS(art_paid.AMOUNT),1),4) AS open_amount -- Open amount is the diff between the ART and the sum of all settlements
            -- of that trans
        FROM
            params
        CROSS JOIN
            leejam.AR_TRANS art_paid
        LEFT JOIN
            leejam.ART_MATCH st
        ON
            st.ART_PAID_CENTER = art_paid.CENTER AND st.ART_PAID_ID = art_paid.ID AND st.ART_PAID_SUBID = art_paid.SUBID AND st.ENTRY_TIME < params.CloseLong AND (
                st.CANCELLED_TIME IS NULL OR st.CANCELLED_TIME > params.CloseLong)
        LEFT JOIN
            leejam.AR_TRANS art_paying
        ON
            art_paying.CENTER = st.ART_PAYING_CENTER AND art_paying.ID = st.ART_PAYING_ID AND art_paying.SUBID = st.ART_PAYING_SUBID AND art_paying.ENTRY_TIME < params.CloseLong AND
            art_paying.TRANS_TIME < params.CutDateLong
        JOIN
            leejam.ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art_paid.CENTER AND ar.ID = art_paid.ID
        WHERE
            art_paid.AMOUNT < 0 AND art_paid.ENTRY_TIME < params.CloseLong AND art_paid.TRANS_TIME < params.CutDateLong AND (
                ar.BALANCE <> 0 OR ar.LAST_ENTRY_TIME >= params.LAST_ENTRY_TIME )
        GROUP BY
            art_paid.CENTER,
            art_paid.ID,
            art_paid.SUBID,
            params.CutDate
        HAVING
            COALESCE(ABS(SUM(st.AMOUNT)),0) < ABS(art_paid.AMOUNT)
    )
    ,
    pre_pivot AS
    (
        SELECT
            p.center,
            CASE ar.AR_TYPE
                WHEN 4
                THEN 'payment'
                WHEN 5
                THEN 'cashcollection'
                WHEN 1
                THEN 'cash'
                WHEN 6
                THEN 'installmentPlan'
                ELSE 'other'
            END                 AS account_type,
            p.center||'p'||p.id AS "Company id",
            p.external_id       AS "Company ExternalId",
            p.fullname          AS "Company Name",
            CASE
                WHEN extract (DAY FROM pr.req_date) = 1
                THEN pr.req_date - interval '1 day'
                ELSE pr.req_date
            END                     AS "Invoice date",
            prs.ref                 AS "Invoice number",
            -1*prs.requested_amount AS "Invoice total amount",
            SUM(art.amount)         AS original_amount,
            SUM(art.open_amount)    AS "Total outstanding for invoice",
            floor(months_between(params.CutDate, CAST(
                CASE
                    WHEN extract (DAY FROM pr.due_date) = 1
                    THEN pr.due_date - interval '1 day'
                    ELSE pr.due_date
                END AS DATE))) AS AGE_MONTHS
        FROM
            art_open_amount art
        CROSS JOIN
            params
        JOIN
            leejam.payment_request_specifications prs
        ON
            prs.center = art.payreq_spec_center AND prs.id = art.payreq_spec_id AND prs.subid = art.payreq_spec_subid AND art.collected = 1
            -- AND prs.original_due_date <= params.CutDate
        JOIN
            leejam.ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center AND art.id = ar.id
        JOIN
            persons p
        ON
            p.center = ar.customercenter AND p.id = ar.customerid
        LEFT JOIN
            leejam.payment_requests pr
        ON
            pr.inv_coll_center = prs.center AND pr.inv_coll_id = prs.id AND pr.inv_coll_subid = prs.subid
        WHERE
            p.sex ='C'
        GROUP BY
            p.center,
            p.id,
            p.external_id,
            p.fullname,
            ar.ar_type,
            prs.center,
            prs.id,
            prs.subid,
            pr.req_date,
            pr.due_date,
            params.CutDate
    )
SELECT
    *
FROM
    (
        SELECT
            center,
            account_type,
            "Company id",
            "Company ExternalId",
            "Company Name",
            "Invoice date",
            "Invoice number",
            ABS(SUM("Invoice total amount")) AS "Invoice total amount",
            --SUM(original_amount)                 AS ,
            ABS(SUM("Total outstanding for invoice")) AS "Total outstanding for invoice",
            ABS(SUM(
                CASE
                    WHEN age_months <= 0
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt not overdue",
            ABS(SUM(
                CASE
                    WHEN age_months = 1
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 1 months",
            ABS(SUM(
                CASE
                    WHEN age_months = 2
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 2 months",
            ABS(SUM(
                CASE
                    WHEN age_months = 3
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 3 months",
            ABS(SUM(
                CASE
                    WHEN age_months = 4
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 4 months",
            ABS(SUM(
                CASE
                    WHEN age_months = 5
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 5 months",
            ABS(SUM(
                CASE
                    WHEN age_months = 6
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 6 months",
            ABS(SUM(
                CASE
                    WHEN age_months = 7
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 7 months",
            ABS(SUM(
                CASE
                    WHEN age_months = 8
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 8 months" ,
            ABS(SUM(
                CASE
                    WHEN age_months = 9
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 9 months" ,
            ABS(SUM(
                CASE
                    WHEN age_months = 10
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 10 months" ,
            ABS(SUM(
                CASE
                    WHEN age_months = 11
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 11 months" ,
            ABS(SUM(
                CASE
                    WHEN age_months = 12
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 12 months" ,
            ABS(SUM(
                CASE
                    WHEN age_months BETWEEN 13 AND 25
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 13 to 24 months" ,
            ABS(SUM(
                CASE
                    WHEN age_months BETWEEN 25 AND 36
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END)) AS "Debt 25 to 36 months" ,
            ABS(SUM(
                CASE
                    WHEN age_months >= 37
                    THEN "Total outstanding for invoice"
                    ELSE 0
                END))                                                              AS "Debt 37 months and older",
            ABS(SUM(SUM("Invoice total amount")) over (partition BY "Company id")) AS "Total",
            'Company'                                                              AS "DebtorType"
        FROM
            pre_pivot
        /*WHERE
            "Company id" = '100p5405'*/
        GROUP BY
            center,
            account_type,
            "Company id",
            "Company ExternalId",
            "Company Name",
            "Invoice date",
            "Invoice number") t