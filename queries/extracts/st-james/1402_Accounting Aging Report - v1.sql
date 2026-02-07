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
                    CAST(extract(epoch FROM timezone('America/New_York',CAST(CURRENT_DATE + interval '1 day' AS TIMESTAMP))) AS bigint)*1000 AS eod_long ) pr
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
            --longtodateTZ(art_paid.TRANS_TIME, 'America/New_York') AS trans_date,
            art_paid.due_date AS trans_date,
            params.CutDate,
            ar.balance,
           -- CAST(extract(days FROM params.CutDate - art_paid.due_date) AS INTEGER) AS age_days,
           params.CutDate - art_paid.due_date as age_days,
            MIN(st.ENTRY_TIME) AS                                                     first_payment,
            ROUND ( art_paid.AMOUNT * COALESCE(1- SUM(st.AMOUNT) /ABS(art_paid.AMOUNT),1), 4 ) AS  open_amount
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
           -- art_paid.AMOUNT < 0
        --AND
         art_paid.ENTRY_TIME < params.CloseLong
        AND art_paid.TRANS_TIME < params.CutDateLong
        and art_paid.due_date < params.cutdate
        GROUP BY
            art_paid.CENTER,
            art_paid.ID,
            art_paid.SUBID,
            ar.balance,
            params.CutDate
       -- HAVING
         --   COALESCE ( ABS(SUM(st.AMOUNT)), 0 ) < ABS ( art_paid.AMOUNT )
    )
SELECT
    c.name                       AS "Club Name",
    p.center||'p'||p.id          AS "Member ID",
    ch.name                      AS "Payment Type - Clearinghouse",    
    p.firstname                  AS "First Name",
    p.lastname                   AS "Last Name",
    CASE p.STATUS
        WHEN 0 THEN 'Lead'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Inactive'
        WHEN 3 THEN 'TemporaryInactive'
        WHEN 4 THEN 'Transferred'
        WHEN 5 THEN 'Duplicate'
        WHEN 6 THEN 'Prospect'
        WHEN 7 THEN 'Deleted'
        WHEN 8 THEN 'Anonymized'
        WHEN 9 THEN 'Contact'
        ELSE 'Undefined'
    END            AS "Member Status",
    email.txtvalue AS "Email",
    sms.txtvalue   AS "Phone",
    STRING_AGG(distinct pr.name,',')     AS "Membership Name(s)",
    ROUND(AVG(CASE WHEN st.st_type > 0 THEN s.subscription_price ELSE 0 END),2)   AS "Membership Dues",
    ar.balance                           AS "Total Balance",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 0 AND 29
            THEN art.open_amount
            ELSE 0
        END),2) AS "Current Balance",
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 30 AND 59
            THEN art.open_amount
            ELSE 0
        END),2) AS "30-Day Balance" ,
    ROUND(SUM(
        CASE
            WHEN age_days BETWEEN 60 AND 89
            THEN art.open_amount
            ELSE 0
        END),2) AS "60-Day Balance",
    ROUND(SUM(
        CASE
            WHEN age_days > 89
            THEN art.open_amount
            ELSE 0
        END ),2)   AS "90+ Day Balance"
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
    PERSON_EXT_ATTRS sms
ON
    sms.name ='_eClub_PhoneSMS'
AND sms.PERSONCENTER = p.center
AND sms.PERSONID =p.id
LEFT JOIN
    payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
AND ar.ar_type = 4
LEFT JOIN
    payment_agreements pa
ON
    pa.center = pac.active_agr_center
AND pa.id = pac.active_agr_id
AND pa.subid = pac.active_agr_subid
LEFT JOIN
    clearinghouses ch
ON
    ch.id = pa.clearinghouse
LEFT JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.state IN (2,4)
LEFT JOIN 
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id 
LEFT JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
WHERE
    c.id IN (:scope)
GROUP BY
    c.name,
    p.center,
    p.id,
    p.firstname,
    p.lastname,
    sms.txtvalue,
    email.txtvalue,
    p.address1,
    p.city,
    p.state,
    ar.balance,
    params.CutDate,
    p.STATUS,
    ch.name
