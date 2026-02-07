WITH
    params AS
    (
        SELECT
            COALESCE(rp.END_DATE,pr.cutdate) AS CutDate,
            COALESCE(CAST(extract(epoch FROM timezone('America/New_York',CAST(rp.end_date +
            interval '1 day' AS TIMESTAMP))) AS bigint)*1000 - 1, pr.eod_long) AS CutDateLong,
            COALESCE(rp.CLOSE_TIME,pr.eod_long)                                AS CloseLong,
            COALESCE(rp.HARD_CLOSE_TIME,pr.eod_long)                           AS HardCloseLong,
            COALESCE(CAST(extract(epoch FROM timezone('America/New_York',CAST(rp.end_date +
            interval '1 day' AS TIMESTAMP))) AS bigint)*1000 - 1, pr.eod_long) - 31622400000 AS
            LAST_ENTRY_TIME
        FROM
            (
                SELECT
                    CAST($$for_date$$ AS DATE) AS cutdate,
                    CAST(extract(epoch FROM timezone('America/New_York',CAST(CAST($$for_date$$ AS DATE)
                    + interval '1 day' AS TIMESTAMP))) AS bigint)*1000 AS eod_long ) pr
        LEFT JOIN
            REPORT_PERIODS rp
        ON
            rp.end_date = pr.cutdate
        AND rp.SCOPE_ID = 1
        AND rp.scope_type = 'T'
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
            longtodateTZ(art_paid.TRANS_TIME, 'America/New_York') AS trans_date,
            params.CutDate,
            ar.balance,
            CAST(extract(days FROM params.CutDate - longtodateTZ(art_paid.TRANS_TIME,
            'America/New_York')) AS INTEGER)                                            AS age_days,
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
        AND ar.ar_type = 4
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
            params.CutDate
 --      HAVING COALESCE ( ABS(SUM(st.AMOUNT)), 0 ) < ABS ( art_paid.AMOUNT )
    )
SELECT
    p.center||'p'||p.id AS "Member ID",
	p.fullname AS "Member Name",
	CASE p.status
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS PERSON_STATUS,
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
    CAST(MIN(art.trans_date) AS DATE) AS "Earliest Date of Debt",
    ROUND(SUM(art.open_amount),2)     AS "Total Debt", --  The total amount of the transaction
    -- minus the settlements gives a time-safe open amount for the transaction
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 0 AND 30
            THEN art.open_amount
            ELSE 0
        END),2) AS "0 - 30 Days",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 31 AND 60
            THEN art.open_amount
            ELSE 0
        END),2) AS "31 - 60 Days" ,
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 61 AND 90
            THEN art.open_amount
            ELSE 0
        END),2) AS "61 - 90 Days",
    ROUND(SUM(
        CASE
            WHEN age_days > 90
            THEN art.open_amount
            ELSE 0
        END),2) AS "Over 90 Days"
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
WHERE
    p.center IN ($$scope$$)
GROUP BY
    p.center,
    p.id,
    ar.ar_type,
    ar.balance,
    params.CutDate