WITH dateselect AS
(
    /*+ materialize */
    SELECT
          $$FromDateInput$$                                                                                 AS FromDateInput,
            $$ToDateInput$$                                                                                 AS ToDateInput,
            datetolongTZ(TO_CHAR($$FromDateInput$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS FromDate,
            (datetolongTZ(TO_CHAR($$ToDateInput$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS ToDate
    FROM
        dual ) 
, 

params AS
(
    /*+ materialize */

select CAST(FromDate AS NUMBER) FromDate,
CAST(ToDate AS NUMBER) ToDate
from dateselect
)

,
am_debit AS
(
    /*+ materialize */
    SELECT
        acc.name                             AS acc_name,
        art.center                           AS art_center,
        art.id                               AS art_id,
        art.subid                            AS art_subid,
        art.amount                           AS art_amount,
        NVL(am_paying.amount,am_paid.amount) AS am_amount,
        NVL(am_paying.id,am_paid.id)         AS am_id,
        art2.amount                          AS art2_amount,
        art2.text                            AS art2_text,
        art2.REF_TYPE                        AS art2_REF_TYPE,
        art2.REF_CENTER                      AS art2_REF_CENTER,
        art2.REF_ID                          AS art2_REF_ID,
        art2.REF_SUBID                       AS art2_REF_SUBID
    FROM
        PUREGYM.ACCOUNTS acc
    CROSS JOIN
        params
    JOIN
        PUREGYM.ACCOUNT_TRANS act
    ON
        (
            act.DEBIT_ACCOUNTCENTER = acc.center
        AND act.DEBIT_ACCOUNTID = acc.id )
    JOIN
        PUREGYM.AR_TRANS art
    ON
        art.REF_TYPE = 'ACCOUNT_TRANS'
    AND art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid
    LEFT JOIN
        PUREGYM.ART_MATCH am_paying
    ON
        art.amount > 0
    AND am_paying.ENTRY_TIME < params.ToDate
    AND (
            am_paying.CANCELLED_TIME IS NULL
        OR  am_paying.CANCELLED_TIME > params.ToDate )
    AND am_paying.ART_PAYING_CENTER = art.center
    AND am_paying.ART_PAYING_id = art.id
    AND am_paying.ART_PAYING_subid = art.subid
    LEFT JOIN
        PUREGYM.ART_MATCH am_paid
    ON
        art.amount <0
    AND am_paid.ENTRY_TIME < params.ToDate
    AND (
            am_paid.CANCELLED_TIME IS NULL
        OR  am_paid.CANCELLED_TIME > params.ToDate )
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
    OR  (
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
    AND act.amount <> 0 )

select * from am_debit