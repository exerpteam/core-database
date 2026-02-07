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
                    CAST(CURRENT_DATE at TIME zone 'America/New_York' AS DATE) AS cutdate,
                    CAST(extract(epoch FROM timezone('America/New_York',CAST(CURRENT_DATE +
                    interval '1 day' AS TIMESTAMP))) AS bigint)*1000 AS eod_long ) pr
        LEFT JOIN
            REPORT_PERIODS rp
        ON
            rp.end_date = pr.cutdate
        AND rp.SCOPE_ID = 1
        AND rp.scope_type = 'T'
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
        HAVING
            COALESCE ( ABS(SUM(st.AMOUNT)), 0 ) < ABS ( art_paid.AMOUNT )
    )
    ,
    person_payments AS
    (
        SELECT
            ar.customercenter,
            ar.customerid,
            pr.req_date,
            rank() over (partition BY ar.customercenter, ar.customerid ORDER BY pr.state IN (5,6,7,
                                                                                             12,19)
            DESC, pr.req_date DESC, pr.entry_time DESC) AS rnk_rej,
            rank() over (partition BY ar.customercenter, ar.customerid ORDER BY pr.state IN (3,4,18
                                                                                             ) DESC
            , pr.req_date DESC, pr.entry_time DESC) AS rnk_pay,
            pr.xfr_info,
            pr.xfr_date,
            pr.xfr_amount
        FROM
            payment_requests pr
        JOIN
            chelseapiers.account_receivables ar
        ON
            ar.center = pr.center
        AND ar.id = pr.id
    )
SELECT
    c.name                            AS "Location",
    p.center||'p'||p.id                     AS "Member ID",
    p.firstname                       AS "First Name",
    p.lastname                        AS "Last Name",
    phone.txtvalue                    AS "Home Number",
    sms.txtvalue                      AS "Mobile Number",
    email.txtvalue                    AS "Email",
    p.address1                        AS "Address",
    p.city                            AS "City",
    p.state                           AS "State",
    ar.balance                        AS "Past Due Total",
    rej.req_date                      AS "Last Decline Date",
    rej.xfr_info                      AS "Last Decline Reason",
    pay.xfr_date                      AS "Last Payment Date",
    pay.xfr_amount                    AS "Last Payment Amount",
    CAST(MIN(art.trans_date) AS DATE) AS "Date of Debt",
    CASE p.STATUS
        WHEN 0
        THEN 'Lead'
        WHEN 1
        THEN 'Active'
        WHEN 2
        THEN 'Inactive'
        WHEN 3
        THEN 'TemporaryInactive'
        WHEN 4
        THEN 'Transferred'
        WHEN 5
        THEN 'Duplicate'
        WHEN 6
        THEN 'Prospect'
        WHEN 7
        THEN 'Deleted'
        WHEN 8
        THEN 'Anonymized'
        WHEN 9
        THEN 'Contact'
        ELSE 'Undefined'
    END AS "Member Status",
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
            WHEN age_days BETWEEN 91 AND 120
            THEN art.open_amount
            ELSE 0
        END),2) AS "91 - 120 Days",
    ROUND(SUM(
        CASE
            WHEN age_days > 120
            THEN art.open_amount
            ELSE 0
        END ),2) AS "Over 120 Days"
FROM
    art_open_amount art
CROSS JOIN
    params
JOIN
    centers c
ON
    c.id = art.center
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
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.name ='_eClub_Email'
AND email.PERSONCENTER = p.center
AND email.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS phone
ON
    phone.name ='_eClub_PhoneHome'
AND phone.PERSONCENTER = p.center
AND phone.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS sms
ON
    sms.name ='_eClub_PhoneSMS'
AND sms.PERSONCENTER = p.center
AND sms.PERSONID =p.id
LEFT JOIN
    person_payments rej
ON
    rej.customercenter = p.center
AND rej.customerid = p.id
AND rej.rnk_rej = 1
LEFT JOIN
    person_payments pay
ON
    pay.customercenter = p.center
AND pay.customerid = p.id
AND pay.rnk_pay = 1
WHERE
    c.id IN ($$scope$$)
GROUP BY
    c.name,
    p.center,
	p.id,
    p.firstname,
    p.lastname,
    phone.txtvalue,
    sms.txtvalue,
    email.txtvalue,
    p.address1,
    p.city,
    p.state,
    rej.req_date,
    rej.xfr_info,
    pay.xfr_date,
    pay.xfr_amount,
    ar.balance,
    params.CutDate,
    p.STATUS