-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            getendofday((:cut_off)::date::varchar, 100)                       AS cut_off_date,
            getendofday(((:cut_off)::date - interval '1' YEAR)::date::varchar, 100) AS year_ago_date
    )
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
    art.text      AS "Conversion"
FROM
    ACCOUNT_RECEIVABLES ar
    cross join params
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
    art.center=art_match_paid.art_paying_center
AND art.id=art_match_paid.art_paying_id
AND art.subid=art_match_paid.art_paying_subid
AND art_match_paid.cancelled_time IS NULL
LEFT JOIN
    AR_TRANS art_paid
ON
    art_match_paid.art_paid_center=art_paid.center
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
        AND art_match_paid IS NULL)
    OR  (
            art_paying.TRANS_TIME > params.cut_off_date
        OR  art_paid.TRANS_TIME > params.cut_off_date )
    OR  art.unsettled_amount != 0)
AND ar.CENTER IN (:scope)
AND ar.ar_type IN (1,4,5)
AND (
        ar.BALANCE != 0
    OR  ar.LAST_ENTRY_TIME >= params.year_ago_date)
AND art.amount != 0
    --  AND p.center||'p'||p.id='6009p4608'
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
    i.text
ORDER BY
    p.center,
    p.id,
    ar.AR_TYPE