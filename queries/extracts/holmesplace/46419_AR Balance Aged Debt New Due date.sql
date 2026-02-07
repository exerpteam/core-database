WITH
    params AS
    (
        SELECT
            pr.cutdate                AS CutDate,
            pr.eod_long               AS CutDateLong,
            pr.eod_long               AS CloseLong,
            pr.eod_long               AS HardCloseLong,
            pr.eod_long - 31622400000 AS LAST_ENTRY_TIME
        FROM
            (
                SELECT
                    CAST($$for_date$$ AS DATE) AS cutdate,
                    CAST(extract(epoch FROM timezone('Europe/Berlin',CAST(CAST($$for_date$$ AS DATE) +
                    interval '1 day' AS TIMESTAMP))) AS bigint)*1000 AS eod_long ) pr
    )
    ,
    art_open_amount AS
    (--find all AR transactions and their settlements which have happened by the cutDate
        SELECT
            art_paid.CENTER,
            art_paid.ID,
            art_paid.SUBID,
            art_paid.payreq_spec_center,
            art_paid.payreq_spec_id,
            art_paid.payreq_spec_subid,
            art_paid.collected,
            art_paid.AMOUNT,
            art_paid.due_date,
            CASE
                WHEN ar.ar_type = 1
                AND longtodateTZ(art_paid.TRANS_TIME, 'Europe/Berlin') < params.CutDate
                THEN true
                WHEN art_paid.due_date < params.CutDate
                THEN true
                ELSE false
            END                                                AS is_overdue,
            longtodateTZ(art_paid.TRANS_TIME, 'Europe/Berlin') AS trans_date,
            params.CutDate,
            ar.balance,
            CAST(extract(days FROM params.CutDate - longtodateTZ(art_paid.TRANS_TIME,
                    'Europe/Berlin')) AS INTEGER) AS age_days,
            CAST(extract(days FROM params.CutDate - longtodateTZ(art_paid.TRANS_TIME,
            'Europe/Berlin'))/30 AS INTEGER)                                          AS age_months,
            MIN(st.ENTRY_TIME)                                                     AS first_payment,
            ROUND ( art_paid.AMOUNT * COALESCE(1- SUM(st.AMOUNT) /ABS(art_paid.AMOUNT),1), 4 ) AS
            open_amount
        FROM
            params
        CROSS JOIN
            AR_TRANS art_paid
        LEFT JOIN
            ART_MATCH st
        ON
            st.ART_PAID_CENTER = art_paid.CENTER
        AND st.ART_PAID_ID = art_paid.ID
        AND st.ART_PAID_SUBID = art_paid.SUBID
        AND st.ENTRY_TIME < params.CloseLong
        AND ( st.CANCELLED_TIME IS NULL
            OR  st.CANCELLED_TIME > params.CloseLong)
        LEFT JOIN
            AR_TRANS art_paying
        ON
            art_paying.CENTER = st.ART_PAYING_CENTER
        AND art_paying.ID = st.ART_PAYING_ID
        AND art_paying.SUBID = st.ART_PAYING_SUBID
        AND art_paying.ENTRY_TIME < params.CloseLong
        AND art_paying.TRANS_TIME < params.CutDateLong
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art_paid.CENTER
        AND ar.ID = art_paid.ID
        WHERE
            art_paid.AMOUNT < 0
        AND art_paid.ENTRY_TIME < params.CloseLong
        AND art_paid.TRANS_TIME < params.CutDateLong
        AND ( ar.BALANCE <> 0
            OR  ar.LAST_ENTRY_TIME >= params.LAST_ENTRY_TIME )
        GROUP BY
            art_paid.CENTER,
            art_paid.ID,
            art_paid.SUBID,
            ar.balance,
            params.CutDate,
            ar.ar_type
        HAVING
            COALESCE ( ABS(SUM(st.AMOUNT)), 0 ) < ABS ( art_paid.AMOUNT )
    )
SELECT
    p.center||'p'||p.id AS "Member ID",
    c.shortname         AS "Club",
    p.fullname          AS "Member Name",
    CASE
        WHEN AR_TYPE = 1
        THEN 'Cash'
        WHEN AR_TYPE = 4
        THEN 'Payment'
        WHEN AR_TYPE = 5
        THEN 'Debt'
        WHEN AR_TYPE = 6
        THEN 'installment'
    END                               AS "AR Type",
    ar.balance                        AS "Current account balance",
    CAST(MIN(art.due_date) AS DATE) AS "Earliest Date of Debt",
    ROUND(SUM(
        CASE
            WHEN is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "Total Debt", --  The total amount of the transaction
    -- minus the settlements gives a time-safe open amount for the transaction
    ROUND(SUM(
        CASE
            WHEN NOT is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "Debt not overdue",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 0 AND 30
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "0-30 Days 1",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 31 AND 60
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "31-60 Days 2" ,
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 61 AND 90
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "61-90 Days 3",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 91 AND 120
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "91-120 Days 4",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 121 AND 150
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "121-150 Days 5",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 151 AND 180
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "151-180 Days 6 ",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 181 AND 210
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "181-210 Days 7",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 211 AND 240
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "211-240 Days 8",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 241 AND 270
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "241-270 Days 9",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 271 AND 300
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "271-300 Days 10",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 301 AND 330
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "301-330 Days 11",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 331 AND 360
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "331-360 Days 12",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 361 AND 720
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "361-720 Days >12<24",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 720 AND 1080
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END),2) AS "721-1080 Days >24<36",
    ROUND(SUM(
        CASE
            WHEN age_days > 1080
            AND is_overdue
            THEN art.open_amount
            ELSE 0
        END ),2) AS "Over 1080 Days >36"
FROM
    art_open_amount art
CROSS JOIN
    params
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = art.center
AND art.id = ar.id
JOIN
    persons p
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
JOIN
    centers c
ON
    c.id = p.center
WHERE
    p.center IN ($$scope$$)
GROUP BY
    p.center,
    p.id,
    c.shortname,
    p.fullname,
    ar.ar_type,
    ar.balance,
    params.CutDate