SELECT
    p.external_id                                                         AS person_id,
    arm.art_paid_center||'ar'||arm.art_paid_id||'art'||arm.art_paid_subid AS paid_ar_transaction_id
    ,
    arm.art_paying_center||'ar'||arm.art_paying_id||'art'||arm.art_paying_subid AS
    paying_ar_transaction_id,
    arm.amount,
    longtodatec(arm.entry_time,arm.art_paid_center)     AS settlement_time,
    longtodatec(arm.cancelled_time,arm.art_paid_center) AS cancellation_time
FROM
    virginactive.art_match arm
JOIN
    virginactive.account_receivables ar
ON
    ar.center = arm.art_paid_center
AND ar.id = arm.art_paid_id
JOIN
    virginactive.persons p
ON
    p.center =ar.customercenter
AND p.id = ar.customerid
where p.external_id = $$person_id$$